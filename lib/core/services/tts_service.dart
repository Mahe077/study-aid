import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/domain/models/tts_chunk.dart';
import '../../features/notes/domain/models/tts_config.dart';
import '../../features/notes/domain/models/tts_state.dart';
import 'text_chunker.dart';
import 'openai_tts_client.dart';
import 'audio_cache_service.dart';
import 'audio_queue_manager.dart';
import 'audio_player_service.dart';

/// Main TTS service that orchestrates text-to-speech functionality
class TtsService {
  final TextChunker _textChunker;
  final OpenAITtsClient _ttsClient;
  final AudioCacheService _cacheService;
  final AudioQueueManager _queueManager;
  final AudioPlayerService _playerService;

  TtsState _state = const TtsState();
  TtsConfig _config = const TtsConfig();
  List<TtsChunk> _chunks = [];
  String _normalizedTitle = '';
  final Map<int, Duration> _chunkDurations = {};
  final Map<String, String> _noteContentHashes = {};
  String _contentHash = '';
  Duration _lastPosition = Duration.zero;
  bool _forceCompleted = false;

  StreamSubscription? _completionSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;

  final _stateController = StreamController<TtsState>.broadcast();

  int _generationId = 0;
  Completer<void>? _generationComplete;

  Note? _lastNote;
  String? _lastTextTitle;
  String? _lastTextContent;
  String? _lastNoteId;
  bool _lastWasText = false;

  /// Stream of TTS state changes
  Stream<TtsState> get stateStream => _stateController.stream;

  /// Current TTS state
  TtsState get state => _state;

  /// Current TTS configuration
  TtsConfig get config => _config;

  TtsService({
    TextChunker? textChunker,
    OpenAITtsClient? ttsClient,
    AudioCacheService? cacheService,
    AudioQueueManager? queueManager,
    AudioPlayerService? playerService,
  })  : _textChunker = textChunker ?? TextChunker(),
        _ttsClient = ttsClient ?? OpenAITtsClient(),
        _cacheService = cacheService ?? AudioCacheService(),
        _queueManager = queueManager ?? AudioQueueManager(),
        _playerService = playerService ?? AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    print('🎯 TtsService: Setting up listeners');
    
    // Listen for audio completion to auto-advance
    _completionSubscription = _playerService.onCompletion.listen((_) async {
      print('🎯 TtsService: onCompletion event received');
      await _onAudioCompleted();
    });

    // Listen for position changes to update state
    _positionSubscription = _playerService.positionStream.listen((position) {
      // CRITICAL: Don't override completed, error, or idle states
      if (_state.status == TtsStatus.completed ||
          _state.status == TtsStatus.error ||
          _state.status == TtsStatus.idle) {
        _lastPosition = position;
        return; // Early return to prevent state updates
      }
      
      // Transition from loading to playing when audio starts
      if (_state.status == TtsStatus.loading && position > Duration.zero) {
        print('🎯 TtsService: Loading -> Playing');
        _updateState(_state.copyWith(status: TtsStatus.playing));
      }
      
      _updateState(_state.copyWith(
        currentPosition: position,
        cumulativeCompletedDuration: _getCompletedDuration(_queueManager.currentIndex),
        estimatedTotalDuration: _estimateTotalDuration(),
      ));

      _lastPosition = position;
    });

    // Listen for duration updates
    _durationSubscription = _playerService.durationStream.listen((duration) {
      if (duration == null || duration <= Duration.zero) return;
      
      // Don't override terminal states
      if (_state.status == TtsStatus.completed ||
          _state.status == TtsStatus.error ||
          _state.status == TtsStatus.idle) {
        return;
      }
      
      _chunkDurations[_queueManager.currentIndex] = duration;
      
      final nextStatus = _playerService.isPlaying ? TtsStatus.playing : _state.status;
      _updateState(_state.copyWith(
        status: nextStatus,
        totalDuration: duration,
        estimatedTotalDuration: _estimateTotalDuration(),
      ));
    });

    // Keep TTS state in sync with underlying audio player
    _playerStateSubscription = _playerService.playerStateStream.listen((state) {
      // Don't override terminal states
      if (_state.status == TtsStatus.completed || 
          _state.status == TtsStatus.error || 
          _state.status == TtsStatus.idle) {
        return;
      }

      // Update play/pause state
      if (state.playing && _state.status != TtsStatus.loading) {
        if (_state.status != TtsStatus.playing) {
          _updateState(_state.copyWith(status: TtsStatus.playing));
        }
      } else if (!state.playing && 
                 _state.status == TtsStatus.playing &&
                 state.processingState != ProcessingState.completed) {
        // Only change to paused if not completing
        _updateState(_state.copyWith(status: TtsStatus.paused));
      }
    });
  }

  /// Initializes TTS for a note
  Future<void> initialize(Note note, TtsConfig config) async {
    _lastNote = note;
    _lastWasText = false;
    _lastTextTitle = null;
    _lastTextContent = null;
    _lastNoteId = note.id;
    _forceCompleted = false;

    await _initializeInternal(
      title: note.title,
      content: note.content,
      noteId: note.id,
      config: config,
    );
  }

  /// Initializes TTS from raw text content (for multi-note scenarios)
  Future<void> initializeFromText(
    String title,
    String content,
    String noteId,
    TtsConfig config,
  ) async {
    _lastWasText = true;
    _lastTextTitle = title;
    _lastTextContent = content;
    _lastNoteId = noteId;
    _lastNote = null;
    _forceCompleted = false;

    await _initializeInternal(
      title: title,
      content: content,
      noteId: noteId,
      config: config,
    );
  }

  Future<void> _initializeInternal({
    required String title,
    required String content,
    required String noteId,
    required TtsConfig config,
  }) async {
    final currentRunId = ++_generationId;
    if (_generationComplete != null && !_generationComplete!.isCompleted) {
      _generationComplete!.complete();
    }
    _generationComplete = Completer<void>();

    try {
      await _playerService.stop();
      _queueManager.clear();
      _chunkDurations.clear();

      _updateState(TtsState(
        status: TtsStatus.loading,
        noteId: noteId,
        currentChunkIndex: 0,
        totalChunks: 0,
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
        cumulativeCompletedDuration: Duration.zero,
        estimatedTotalDuration: Duration.zero,
      ));

      _config = config;

      _chunks = _textChunker.chunkText(
        title: title,
        content: content,
      );

      _normalizedTitle = _textChunker.normalizeTitle(title);
      _contentHash = _computeContentHash(title, content);
      _lastPosition = Duration.zero;
      final previousHash = _noteContentHashes[noteId];
      if (previousHash != null && previousHash != _contentHash) {
        await _cacheService.clearNoteCache(noteId);
      }
      _noteContentHashes[noteId] = _contentHash;

      _updateState(_state.copyWith(totalChunks: _chunks.length));

      if (_chunks.isEmpty) {
        if (_generationComplete != null && !_generationComplete!.isCompleted) {
          _generationComplete!.complete();
        }
        return;
      }

      final firstPath = await _generateAudioForChunk(
        noteId: noteId,
        chunkIndex: 0,
        runId: currentRunId,
      );
      if (firstPath == null || currentRunId != _generationId) return;

      _queueManager.initialize([firstPath]);
      await _playCurrentChunk();
      _preloadNextChunkIfNeeded();

      if (_chunks.length == 1) {
        if (_generationComplete != null && !_generationComplete!.isCompleted) {
          _generationComplete!.complete();
        }
        return;
      }

      // Continue generating remaining chunks in the background
      unawaited(_generateRemainingChunks(
        noteId: noteId,
        startIndex: 1,
        runId: currentRunId,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: TtsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<String?> _generateAudioForChunk({
    required String noteId,
    required int chunkIndex,
    required int runId,
  }) async {
    if (runId != _generationId) return null;
    final chunk = _chunks[chunkIndex];

    String? audioPath = await _cacheService.getCachedAudio(
      noteId: noteId,
      chunkIndex: chunk.index,
      voice: _config.voice.name,
      speed: _config.speed,
      contentHash: _contentHash,
    );

    if (audioPath == null) {
      final text = chunk.getFormattedText(_normalizedTitle);
      audioPath = await _ttsClient.generateSpeech(
        text: text,
        voice: _config.voice,
        speed: _config.speed,
        noteId: noteId,
        chunkIndex: chunk.index,
        contentHash: _contentHash,
      );
    }

    if (runId != _generationId) return null;
    return audioPath;
  }

  Future<void> _generateRemainingChunks({
    required String noteId,
    required int startIndex,
    required int runId,
  }) async {
    try {
      for (int i = startIndex; i < _chunks.length; i++) {
        if (runId != _generationId) return;

        final audioPath = await _generateAudioForChunk(
          noteId: noteId,
          chunkIndex: i,
          runId: runId,
        );

        if (audioPath == null || runId != _generationId) return;
        _queueManager.addPath(audioPath);
      }
    } catch (e) {
      if (runId == _generationId) {
        _updateState(_state.copyWith(
          status: TtsStatus.error,
          errorMessage: e.toString(),
        ));
      }
    } finally {
      if (runId == _generationId &&
          _generationComplete != null &&
          !_generationComplete!.isCompleted) {
        _generationComplete!.complete();
      }
    }
  }

  /// Plays the current chunk
  Future<void> _playCurrentChunk() async {
    final audioPath = _queueManager.currentPath;
    if (audioPath == null) return;

    await _playerService.play(audioPath);

    _forceCompleted = false;
    _updateState(_state.copyWith(
      status: TtsStatus.playing,
      currentChunkIndex: _queueManager.currentIndex,
      totalChunks: _chunks.length,
      totalDuration: Duration.zero,
      currentPosition: Duration.zero,
      cumulativeCompletedDuration: _getCompletedDuration(_queueManager.currentIndex),
      estimatedTotalDuration: _estimateTotalDuration(),
    ));

    final duration = await _waitForDuration();
    if (duration > Duration.zero) {
      _chunkDurations[_queueManager.currentIndex] = duration;
    }

    _updateState(_state.copyWith(
      currentChunkIndex: _queueManager.currentIndex,
      totalChunks: _chunks.length,
      totalDuration: duration,
      currentPosition: Duration.zero,
      cumulativeCompletedDuration: _getCompletedDuration(_queueManager.currentIndex),
      estimatedTotalDuration: _estimateTotalDuration(),
    ));
  }

  /// Waits for audio duration to be available
  Future<Duration> _waitForDuration() async {
    // Wait up to 5 seconds for duration to be available
    for (int i = 0; i < 50; i++) {
      final duration = _playerService.duration;
      if (duration != null && duration > Duration.zero) {
        return duration;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return Duration.zero;
  }

  /// Preloads next chunk if needed
  void _preloadNextChunkIfNeeded() {
    if (_queueManager.shouldPreloadNext()) {
      final nextPath = _queueManager.nextPath;
      if (nextPath != null) {
        _playerService.preload(nextPath);
        _queueManager.markNextAsPreloaded();
      }
    }
  }

  /// Called when current audio completes
  Future<void> _onAudioCompleted() async {
    print('🎯 TtsService: _onAudioCompleted called');
    
    // Check if this is the final chunk
    final isFinalChunk = !_queueManager.hasNext && 
                         _queueManager.totalItems >= _chunks.length;
    
    print('🎯 isFinalChunk: $isFinalChunk, continuousPlay: ${_config.continuousPlay}');
    
    // Complete if continuous play is off OR this is the final chunk
    if (!_config.continuousPlay || isFinalChunk) {
      final finalDuration = _state.totalDuration > Duration.zero 
          ? _state.totalDuration 
          : _lastPosition;
      
      print('🎯 Setting status to COMPLETED (duration: $finalDuration)');
      _setCompleted(finalDuration);
      return;
    }

    // Wait for next chunk if it's still being generated
    if (!_queueManager.hasNext && _queueManager.totalItems < _chunks.length) {
      print('🎯 Waiting for next chunk...');
      _updateState(_state.copyWith(status: TtsStatus.loading));

      final hasNext = await _waitForNextAvailable();
      if (!hasNext) {
        final finalDuration = _state.totalDuration > Duration.zero 
            ? _state.totalDuration 
            : _lastPosition;
        print('🎯 No next chunk, completing');
        _setCompleted(finalDuration);
        return;
      }
    }

    // Move to next chunk or complete
    if (_queueManager.hasNext) {
      print('🎯 Moving to next chunk');
      _queueManager.next();
      await _playCurrentChunk();
      _preloadNextChunkIfNeeded();
    } else {
      final finalDuration = _state.totalDuration > Duration.zero 
          ? _state.totalDuration 
          : _lastPosition;
      print('🎯 No more chunks, completing');
      _setCompleted(finalDuration);
    }
  }

  Future<bool> _waitForNextAvailable() async {
    if (_queueManager.hasNext) return true;
    final generationComplete = _generationComplete;
    if (generationComplete == null) return false;

    await Future.any([
      _queueManager.queueChangedStream.first,
      generationComplete.future,
    ]);

    return _queueManager.hasNext;
  }

  /// Plays audio
  Future<void> play() async {
    if (_state.status == TtsStatus.paused) {
      await _playerService.resume();
      _updateState(_state.copyWith(status: TtsStatus.playing));
    } else if (_state.status == TtsStatus.completed) {
      await restart();
    }
  }

  /// Stops playback and clears current session
  Future<void> stop() async {
    _generationId++;
    if (_generationComplete != null && !_generationComplete!.isCompleted) {
      _generationComplete!.complete();
    }
    await _playerService.stop();
    _queueManager.clear();
    _chunkDurations.clear();
    _forceCompleted = false;
    _updateState(const TtsState(status: TtsStatus.idle));
  }

  /// Pauses audio
  Future<void> pause() async {
    if (_state.status == TtsStatus.playing) {
      await _playerService.pause();
      _updateState(_state.copyWith(status: TtsStatus.paused));
    }
  }

  /// Restarts from beginning
  Future<void> restart() async {
    _queueManager.restart();
    _forceCompleted = false;
    await _playCurrentChunk();
    _preloadNextChunkIfNeeded();
  }

  /// Seeks forward by duration
  Future<void> seekForward(Duration duration) async {
    final newPosition = _playerService.position + duration;
    final maxDuration = _playerService.duration ?? Duration.zero;

    if (newPosition < maxDuration) {
      await _playerService.seek(newPosition);
    } else if (_queueManager.hasNext) {
      // Jump to next chunk
      _queueManager.next();
      await _playCurrentChunk();
      _preloadNextChunkIfNeeded();
    }
  }

  /// Seeks backward by duration
  Future<void> seekBackward(Duration duration) async {
    final newPosition = _playerService.position - duration;

    if (newPosition > Duration.zero) {
      await _playerService.seek(newPosition);
    } else if (_queueManager.hasPrevious) {
      // Jump to previous chunk
      _queueManager.previous();
      await _playCurrentChunk();
    } else {
      await _playerService.seek(Duration.zero);
    }
  }

  /// Changes playback speed
  Future<void> changeSpeed(double speed) async {
    if (speed == _config.speed) return;

    _config = _config.copyWith(speed: speed);

    // Regenerate audio with new speed
    if (_state.noteId != null) {
      await _cacheService.clearNoteCache(_state.noteId!);
      await _restartWithCurrentInput();
    }

    await _playerService.setSpeed(speed);
  }

  /// Changes voice
  Future<void> changeVoice(TtsVoice voice) async {
    if (voice == _config.voice) return;

    _config = _config.copyWith(voice: voice);

    // Regenerate audio with new voice
    if (_state.noteId != null) {
      await _cacheService.clearNoteCache(_state.noteId!);
      await _restartWithCurrentInput();
    }
  }

  /// Retries generation from the last input
  Future<void> retry() async {
    await _restartWithCurrentInput();
  }

  Future<void> _restartWithCurrentInput() async {
    if (_lastWasText &&
        _lastTextTitle != null &&
        _lastTextContent != null &&
        _lastNoteId != null) {
      await _initializeInternal(
        title: _lastTextTitle!,
        content: _lastTextContent!,
        noteId: _lastNoteId!,
        config: _config,
      );
      return;
    }

    if (_lastNote != null) {
      await _initializeInternal(
        title: _lastNote!.title,
        content: _lastNote!.content,
        noteId: _lastNote!.id,
        config: _config,
      );
    }
  }

  Duration _getCompletedDuration(int currentIndex) {
    if (_chunkDurations.isEmpty) return Duration.zero;
    int totalMs = 0;
    _chunkDurations.forEach((index, duration) {
      if (index < currentIndex) {
        totalMs += duration.inMilliseconds;
      }
    });
    return Duration(milliseconds: totalMs);
  }

  Duration _estimateTotalDuration() {
    if (_chunks.isEmpty || _chunkDurations.isEmpty) return Duration.zero;
    int totalKnownMs = 0;
    int count = 0;
    for (final duration in _chunkDurations.values) {
      if (duration > Duration.zero) {
        totalKnownMs += duration.inMilliseconds;
        count++;
      }
    }
    if (count == 0) return Duration.zero;
    final avgMs = totalKnownMs ~/ count;
    return Duration(milliseconds: avgMs * _chunks.length);
  }

  String _computeContentHash(String title, String content) {
    final input = '$title\n$content';
    int hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }

  /// Updates state and notifies listeners
  void _updateState(TtsState newState) {
    if (_forceCompleted && newState.status != TtsStatus.completed) {
      return;
    }
    _state = newState;
    _stateController.add(_state);
  }

  void _setCompleted(Duration finalDuration) {
    _forceCompleted = true;
    _updateState(_state.copyWith(
      status: TtsStatus.completed,
      totalDuration: finalDuration,
      currentPosition: finalDuration,
    ));
  }

  /// Disposes the service
  Future<void> dispose() async {
    await _completionSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _stateController.close();
    await _playerService.dispose();
    _queueManager.dispose();
    _ttsClient.dispose();
  }
}

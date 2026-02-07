import 'dart:async';
import 'package:just_audio/just_audio.dart';

/// Service for playing audio using just_audio
/// 
/// FIXED: Detects completion when position resets from end to zero
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;

  final _completionController = StreamController<void>.broadcast();
  
  bool _hasEmittedCompletion = false;
  String? _currentFilePath;
  Duration _lastPosition = Duration.zero;
  Duration _lastKnownDuration = Duration.zero;
  bool _wasNearEnd = false;

  /// Stream that emits when the current audio completes
  Stream<void> get onCompletion => _completionController.stream;

  /// Stream of current playback position
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of duration
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of playback state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Current playback position
  Duration get position => _player.position;

  /// Total duration of current audio
  Duration? get duration => _player.duration;

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Current playback speed
  double get speed => _player.speed;

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    // Track duration
    _durationSubscription = _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        _lastKnownDuration = dur;
      }
    });

    // Monitor position - this is KEY to detecting completion
    _positionSubscription = _player.positionStream.listen((position) {
      final dur = _player.duration ?? _lastKnownDuration;
      
      // Check if we're near the end
      if (dur > Duration.zero) {
        _wasNearEnd = position >= dur - const Duration(milliseconds: 500);
      }
      
      // CRITICAL FIX: Detect position reset from end to zero
      // This is what happens in your logs: 10s/10s -> 0s/10s
      final positionResetToZero = position == Duration.zero && 
                                  _lastPosition > Duration.zero &&
                                  _wasNearEnd;
      
      // Also check if we're at the end and stopped
      final atEndAndStopped = dur > Duration.zero &&
                             position >= dur - const Duration(milliseconds: 300) &&
                             !_player.playing;
      
      if ((positionResetToZero || atEndAndStopped) && !_hasEmittedCompletion) {
        print('🎵 AudioPlayerService: Completion detected! (reset: $positionResetToZero, atEnd: $atEndAndStopped)');
        _hasEmittedCompletion = true;
        _wasNearEnd = false;
        _completionController.add(null);
      }
      
      _lastPosition = position;
    });

    // Backup completion detection via player state
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && !_hasEmittedCompletion) {
        print('🎵 AudioPlayerService: Completion detected via ProcessingState.completed');
        _hasEmittedCompletion = true;
        _wasNearEnd = false;
        _completionController.add(null);
      }
    });
  }

  /// Loads and plays an audio file
  Future<void> play(String filePath) async {
    final isNewFile = _currentFilePath != filePath;
    _currentFilePath = filePath;
    
    if (isNewFile || _hasEmittedCompletion) {
      _hasEmittedCompletion = false;
      _lastPosition = Duration.zero;
      _lastKnownDuration = Duration.zero;
      _wasNearEnd = false;
    }
    
    await _player.setFilePath(filePath);
    await _player.play();
  }

  /// Pauses playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resumes playback
  Future<void> resume() async {
    if (_hasEmittedCompletion) {
      _hasEmittedCompletion = false;
      _wasNearEnd = false;
    }
    await _player.play();
  }

  /// Stops playback
  Future<void> stop() async {
    _hasEmittedCompletion = false;
    _currentFilePath = null;
    _lastPosition = Duration.zero;
    _lastKnownDuration = Duration.zero;
    _wasNearEnd = false;
    await _player.stop();
  }

  /// Seeks to a specific position
  Future<void> seek(Duration position) async {
    final dur = duration ?? _lastKnownDuration;
    
    // If seeking away from the end, reset completion flag
    if (position < dur - const Duration(milliseconds: 500)) {
      _hasEmittedCompletion = false;
      _wasNearEnd = false;
    }
    
    await _player.seek(position);
  }

  /// Seeks forward by the given duration
  Future<void> seekForward(Duration duration) async {
    final newPosition = position + duration;
    final maxPosition = this.duration ?? _lastKnownDuration;

    if (newPosition < maxPosition) {
      await seek(newPosition);
    } else {
      await seek(maxPosition);
    }
  }

  /// Seeks backward by the given duration
  Future<void> seekBackward(Duration duration) async {
    final newPosition = position - duration;

    if (newPosition > Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  /// Sets playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Preloads an audio file without playing
  Future<void> preload(String filePath) async {
    // Just_audio doesn't have explicit preload
  }

  /// Disposes the audio player
  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _completionController.close();
    await _player.dispose();
  }
}

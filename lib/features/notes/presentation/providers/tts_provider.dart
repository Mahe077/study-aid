import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/tts_service.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/models/tts_state.dart';
import '../../../notes/domain/models/tts_config.dart';
import 'tts_settings_provider.dart';

/// Provider for TTS service instance
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();

  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for TTS playback state
final ttsPlaybackProvider =
    StateNotifierProvider<TtsPlaybackNotifier, TtsState>((ref) {
  final service = ref.watch(ttsServiceProvider);
  final settings = ref.watch(ttsSettingsProvider);

  return TtsPlaybackNotifier(service, settings, ref);
});

/// Notifier for TTS playback state
class TtsPlaybackNotifier extends StateNotifier<TtsState> {
  final TtsService _service;
  final TtsConfig _config;
  final Ref _ref;
  StreamSubscription? _statusSubscription;
  bool _lockCompleted = false;

  TtsPlaybackNotifier(this._service, this._config, this._ref)
      : super(const TtsState()) {
    // Listen to service state changes
    _statusSubscription = _service.stateStream.listen((newState) {
      if (mounted) {
        if (_lockCompleted && newState.status != TtsStatus.completed) {
          return;
        }
        state = newState;
        if (newState.status == TtsStatus.completed) {
          _lockCompleted = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  /// Initializes TTS for a note
  Future<void> initialize(Note note) async {
    _lockCompleted = false;
    await _service.initialize(note, _config);
  }

  /// Initializes TTS for multiple notes (combines them into a single TTS session)
  Future<void> initializeMultipleNotes(List<Note> notes, String topicId) async {
    if (notes.isEmpty) return;
    _lockCompleted = false;

    // Combine all notes into a single text
    final StringBuffer combinedContent = StringBuffer();
    for (final note in notes) {
      if (note.content.trim().isNotEmpty) {
        combinedContent.writeln('${note.title}.\n');
        combinedContent.writeln('${note.content}\n\n');
      }
    }

    final title = 'Notes Playback';
    final content = combinedContent.toString();

    // Use the topic ID as the note ID for caching purposes
    await _service.initializeFromText(title, content, 'multi_notes_$topicId', _config);
  }

  /// Plays audio
  Future<void> play() async {
    _lockCompleted = false;
    await _service.play();
  }

  /// Stops audio and clears session
  Future<void> stop() async {
    _lockCompleted = false;
    await _service.stop();
  }

  /// Pauses audio
  Future<void> pause() async {
    await _service.pause();
  }

  /// Toggles play/pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Restarts from beginning
  Future<void> restart() async {
    _lockCompleted = false;
    await _service.restart();
  }

  /// Seeks forward by 15 seconds
  Future<void> seekForward() async {
    await _service.seekForward(const Duration(seconds: 10));
  }

  /// Seeks backward by 15 seconds
  Future<void> seekBackward() async {
    await _service.seekBackward(const Duration(seconds: 10));
  }

  /// Changes playback speed
  Future<void> changeSpeed(double speed) async {
    // Update settings
    await _ref.read(ttsSettingsProvider.notifier).setSpeed(speed);

    // Update service and regenerate
    await _service.changeSpeed(speed);

    // Re-initialize with new speed
    if (state.noteId != null) {
      // Will need to pass the note again - this should be handled by the UI
    }
  }

  /// Changes voice
  Future<void> changeVoice(TtsVoice voice) async {
    // Update settings
    await _ref.read(ttsSettingsProvider.notifier).setVoice(voice);

    // Update service and regenerate
    await _service.changeVoice(voice);

    // Re-initialize with new voice
    if (state.noteId != null) {
      // Will need to pass the note again - this should be handled by the UI
    }
  }

  /// Toggles continuous play
  Future<void> toggleContinuousPlay() async {
    final newValue = !_config.continuousPlay;
    await _ref.read(ttsSettingsProvider.notifier).setContinuousPlay(newValue);
  }

  /// Saves current playback position
  Future<void> savePosition() async {
    if (state.noteId != null) {
      await _ref.read(ttsSettingsProvider.notifier).saveLastPosition(
            state.noteId!,
            state.currentChunkIndex,
            state.currentPosition,
          );
    }
  }

  /// Clears error state
  void clearError() {
    state = state.clearError();
  }

  /// Retries TTS generation from the last input
  Future<void> retry() async {
    _lockCompleted = false;
    await _service.retry();
  }
}

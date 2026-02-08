import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_aid/features/notes/domain/models/tts_config.dart';

/// Provider for TTS settings persistence
final ttsSettingsProvider =
    StateNotifierProvider<TtsSettingsNotifier, TtsConfig>((ref) {
  return TtsSettingsNotifier();
});

/// Notifier for TTS settings
class TtsSettingsNotifier extends StateNotifier<TtsConfig> {
  static const String _keyVoice = 'tts_voice';
  static const String _keySpeed = 'tts_speed';
  static const String _keyContinuousPlay = 'tts_continuous_play';

  TtsSettingsNotifier() : super(const TtsConfig()) {
    _loadSettings();
  }

  /// Loads settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final voiceName = prefs.getString(_keyVoice);
    final speed = prefs.getDouble(_keySpeed) ?? 1.0;
    final continuousPlay = prefs.getBool(_keyContinuousPlay) ?? true;

    final voice = voiceName != null
        ? TtsVoice.values.firstWhere(
            (v) => v.name == voiceName,
            orElse: () => TtsVoice.alloy,
          )
        : TtsVoice.alloy;

    state = TtsConfig(
      voice: voice,
      speed: speed,
      continuousPlay: continuousPlay,
    );
  }

  /// Updates voice setting
  Future<void> setVoice(TtsVoice voice) async {
    state = state.copyWith(voice: voice);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVoice, voice.name);
  }

  /// Updates speed setting
  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySpeed, speed);
  }

  /// Updates continuous play setting
  Future<void> setContinuousPlay(bool enabled) async {
    state = state.copyWith(continuousPlay: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyContinuousPlay, enabled);
  }

  /// Saves last playback position for a note
  Future<void> saveLastPosition(String noteId, int chunkIndex, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tts_position_${noteId}_chunk', chunkIndex);
    await prefs.setInt('tts_position_${noteId}_seconds', position.inSeconds);
  }

  /// Gets last playback position for a note
  Future<({int chunkIndex, Duration position})?> getLastPosition(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final chunkIndex = prefs.getInt('tts_position_${noteId}_chunk');
    final seconds = prefs.getInt('tts_position_${noteId}_seconds');

    if (chunkIndex != null && seconds != null) {
      return (chunkIndex: chunkIndex, position: Duration(seconds: seconds));
    }

    return null;
  }

  /// Clears last position for a note  
  Future<void> clearLastPosition(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tts_position_${noteId}_chunk');
    await prefs.remove('tts_position_${noteId}_seconds');
  }
}

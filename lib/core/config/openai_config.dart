/// Configuration for OpenAI API
class OpenAIConfig {
  /// OpenAI API key - should be set via environment variable or secure storage
  static const String apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  /// OpenAI Text-to-Speech endpoint
  static const String ttsEndpoint = 'https://api.openai.com/v1/audio/speech';

  /// TTS model to use
  /// - 'tts-1': Faster, lower latency
  /// - 'tts-1-hd': Higher quality audio
  static const String model = 'tts-1';

  /// Maximum characters per chunk (OpenAI limit is 4096)
  static const int maxCharsPerChunk = 4000;

  /// HTTP request timeout
  static const Duration requestTimeout = Duration(seconds: 60);

  /// Whether API key is configured
  static bool get isConfigured => apiKey.isNotEmpty;
}

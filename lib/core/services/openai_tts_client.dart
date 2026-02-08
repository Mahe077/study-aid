import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/openai_config.dart';
import '../../features/notes/domain/models/tts_config.dart';

/// Exception thrown when OpenAI TTS API calls fail
class TtsApiException implements Exception {
  final String message;
  final int? statusCode;

  TtsApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'TtsApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Client for OpenAI Text-to-Speech API
class OpenAITtsClient {
  final http.Client _httpClient;
  final String _apiKey;

  OpenAITtsClient({
    http.Client? httpClient,
    String? apiKey,
  })  : _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey ?? OpenAIConfig.apiKey {
    if (_apiKey.isEmpty) {
      throw TtsApiException('OpenAI API key not configured');
    }
  }

  /// Generates speech from text using OpenAI TTS API
  /// Returns the path to the saved audio file
  Future<String> generateSpeech({
    required String text,
    required TtsVoice voice,
    required double speed,
    required String noteId,
    required int chunkIndex,
    String? contentHash,
  }) async {
    try {
      // Make API request
      final response = await _httpClient
          .post(
            Uri.parse(OpenAIConfig.ttsEndpoint),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: _buildRequestBody(text, voice, speed),
          )
          .timeout(OpenAIConfig.requestTimeout);

      // Check response status
      if (response.statusCode != 200) {
        final error = _parseErrorResponse(response);
        throw TtsApiException(error, response.statusCode);
      }

      // Save audio to file
      final audioBytes = response.bodyBytes;
      final filePath = await _saveAudioFile(
        audioBytes,
        noteId,
        chunkIndex,
        voice,
        speed,
        contentHash,
      );

      return filePath;
    } on http.ClientException catch (e) {
      throw TtsApiException('Network error: ${e.message}');
    } on TimeoutException {
      throw TtsApiException('Request timeout');
    } on TtsApiException {
      rethrow;
    } catch (e) {
      throw TtsApiException('Unexpected error: $e');
    }
  }

  /// Builds JSON request body for OpenAI TTS API
  String _buildRequestBody(String text, TtsVoice voice, double speed) {
    // Escape special characters in text
    final escapedText = text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    return '''
{
  "model": "${OpenAIConfig.model}",
  "input": "$escapedText",
  "voice": "${voice.name}",
  "speed": $speed
}
''';
  }

  /// Parses error response from API
  String _parseErrorResponse(http.Response response) {
    try {
      // Try to extract error message from response body
      final body = response.body;
      if (body.contains('error')) {
        // Simple extraction - could use json.decode for more robust parsing
        return 'API error: ${response.statusCode} - ${body.substring(0, body.length > 100 ? 100 : body.length)}';
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return 'API error: ${response.statusCode}';
  }

  /// Saves audio bytes to file
  Future<String> _saveAudioFile(
    Uint8List audioBytes,
    String noteId,
    int chunkIndex,
    TtsVoice voice,
    double speed,
    String? contentHash,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final ttsDir = Directory('${directory.path}/tts_cache');

    // Create directory if it doesn't exist
    if (!await ttsDir.exists()) {
      await ttsDir.create(recursive: true);
    }

    // Generate filename with cache key
    final speedStr = speed.toStringAsFixed(1);
    final hashPart =
        (contentHash == null || contentHash.isEmpty) ? '' : '_$contentHash';
    final filename =
        '${noteId}_${chunkIndex}_${voice.name}_$speedStr$hashPart.mp3';
    final file = File('${ttsDir.path}/$filename');

    // Write audio data
    await file.writeAsBytes(audioBytes);

    return file.path;
  }

  /// Disposes the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

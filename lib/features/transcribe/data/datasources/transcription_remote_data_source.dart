import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:study_aid/core/config/azure_config.dart';
import 'package:study_aid/core/error/exceptions.dart';

abstract class TranscriptionRemoteDataSource {
  Future<String> startTranscription(String filePath);
}

class TranscriptionRemoteDataSourceImpl
    implements TranscriptionRemoteDataSource {
  final http.Client client;

  TranscriptionRemoteDataSourceImpl(this.client);

  @override
  Future<String> startTranscription(String localMp3Path) async {
    final uri = Uri.parse(AzureConfig.sttEndpoint);

    final headers = {
      'Ocp-Apim-Subscription-Key': AzureConfig.sttSubscriptionKey,
      'Accept': 'application/json',
    };

    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Attach the audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        localMp3Path,
        contentType: MediaType('audio', 'mpeg'),
      ));

      request.fields['definition'] = '''
      {
        "locales": ["en-US"]
      }
      ''';

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return _parseTranscriptionResponse(response.body);
      } else if (response.statusCode == 202) {
        // Handle the expected 202 response with polling
        final location = streamedResponse.headers['operation-location'];
        if (location != null) {
          return await _pollForTranscription(location, headers);
        } else {
          throw ServerException('Operation location not found in 202 response');
        }
      } else {
        throw ServerException(
            'Transcription failed: ${response.body}, Status: ${response.statusCode}');
      }
    } on SocketException {
      throw ServerException('No Internet Connection');
    } catch (e) {
      throw ServerException('Unexpected Error: $e');
    }
  }

  Future<String> _pollForTranscription(
      String locationUrl, Map<String, String> headers) async {
    int retries = 0;
    const maxRetries = 20; // Try for ~40 seconds (2s interval)

    while (retries < maxRetries) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final response =
            await client.get(Uri.parse(locationUrl), headers: headers);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final status = jsonResponse['status'];

          if (status == 'Succeeded') {
            return _parseTranscriptionResponse(response.body);
          } else if (status == 'Failed') {
            throw ServerException('Transcription processing failed.');
          }
          // If 'Running' or 'NotStarted', continue loop
        } else {
          throw ServerException(
              'Polling failed: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        throw ServerException('Error during polling: $e');
      }
      retries++;
    }
    throw ServerException('Transcription timed out.');
  }

  String _parseTranscriptionResponse(String jsonBody) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonBody);
      // Check for 'combinedRecognizedPhrases' (standard Azure output)
      if (json.containsKey('combinedRecognizedPhrases')) {
        final List<dynamic> phrases = json['combinedRecognizedPhrases'];
        if (phrases.isNotEmpty) {
          return phrases[0]['display'] ?? '';
        }
      }
      // Fallback or other format check if needed
      return jsonBody; // Return raw if parsing fails, better than crashing
    } catch (e) {
      return jsonBody; // Not valid JSON?
    }
  }
}

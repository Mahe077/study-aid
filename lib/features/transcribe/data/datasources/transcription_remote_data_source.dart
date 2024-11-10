import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    final uri = Uri.parse(
        'https://eastus.api.cognitive.microsoft.com/speechtotext/transcriptions:transcribe?api-version=2024-05-15-preview');

    final headers = {
      'Ocp-Apim-Subscription-Key': 'eb0ee53d9df54ebf861cfef6ba990e6b',
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

      if (response.statusCode == 202) {
        // Handle the expected 202 response
        final location = streamedResponse.headers['operation-location'];
        if (location != null) {
          return location; // Return the URL to check the status
        } else {
          throw ServerException('Operation location not found');
        }
      } else if (response.statusCode == 200) {
        return response.body;
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
}

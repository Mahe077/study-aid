import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/features/transcribe/data/datasources/transcription_remote_data_source.dart';
import 'package:study_aid/features/transcribe/domain/entities/transcription.dart';
import 'package:study_aid/features/transcribe/domain/repositories/transcription_repository.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final TranscriptionRemoteDataSource remoteDataSource;

  TranscriptionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Transcription> startTranscription(String filePath) async {
    try {
      final responseBody = await remoteDataSource.startTranscription(filePath);
      final transcriptionText = _parseTranscription(responseBody);
      Logger().d("tranciption:: $transcriptionText");
      // Return the final transcription object
      return Transcription(text: transcriptionText, isCompleted: true);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Helper function to parse the response body and extract the transcription text
  String _parseTranscription(String responseBody) {
    final json = jsonDecode(responseBody);

    // Check if 'combinedPhrases' exist and extract its content
    if (json.containsKey('combinedPhrases')) {
      return json['combinedPhrases'][0]['text'] as String;
    } else {
      if (json.containsKey('phrases')) {
        final phrases = json['phrases'] as List;
        return phrases.map((e) => e['text'] as String).join(' ');
      } else {
        return '';
      }
    }
  }
}

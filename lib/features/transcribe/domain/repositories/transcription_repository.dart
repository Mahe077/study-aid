import 'package:study_aid/features/transcribe/domain/entities/transcription.dart';

abstract class TranscriptionRepository {
  Future<Transcription> startTranscription(String filePath);
}

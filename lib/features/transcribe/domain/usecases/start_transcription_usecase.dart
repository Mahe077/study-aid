import 'package:study_aid/features/transcribe/domain/entities/transcription.dart';
import 'package:study_aid/features/transcribe/domain/repositories/transcription_repository.dart';

class StartTranscriptionUseCase {
  final TranscriptionRepository repository;

  StartTranscriptionUseCase(this.repository);

  Future<Transcription> call(String filePath) {
    return repository.startTranscription(filePath);
  }
}

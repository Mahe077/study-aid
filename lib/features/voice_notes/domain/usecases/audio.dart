import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/domain/repository/audio_repository.dart';

class SyncAudioRecordingsUseCase {
  final AudioRecordingRepository repository;

  SyncAudioRecordingsUseCase(this.repository);

  Future<void> call() async {
    final result = await repository.syncAudioRecordings();
    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}

class CreateAudioRecording {
  final AudioRecordingRepository repository;

  CreateAudioRecording(this.repository);

  Future<Either<Failure, AudioRecording>> call(
      AudioRecording audioRecording, String topicId) async {
    final result =
        await repository.createAudioRecording(audioRecording, topicId);
    return result.fold(
      (failure) => Left(failure),
      (audioRecording) => Right(audioRecording),
    );
  }
}

class UpdateAudioRecording {
  final AudioRecordingRepository repository;

  UpdateAudioRecording(this.repository);

  Future<Either<Failure, AudioRecording>> call(
      AudioRecording audioRecording, String topicId) async {
    final result =
        await repository.updateAudioRecording(audioRecording, topicId);
    return result.fold(
      (failure) => Left(failure),
      (audioRecording) => Right(audioRecording),
    );
  }
}

class DeleteAudioRecording {
  final AudioRecordingRepository repository;

  DeleteAudioRecording(this.repository);

  Future<void> call(String noteId) async {
    return repository.deleteAudioRecording(noteId);
  }
}

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

  Future<Either<Failure, Tuple2<AudioRecording, String>>> call(
      AudioRecording audioRecording,
      String topicId,
      String userId,
      bool isTranscribe) async {
    final result = await repository.createAudioRecording(
        audioRecording, topicId, userId, isTranscribe);
    return result.fold(
      (failure) => Left(failure),
      (R) => Right(R),
    );
  }
}

class UpdateAudioRecording {
  final AudioRecordingRepository repository;

  UpdateAudioRecording(this.repository);

  Future<Either<Failure, AudioRecording>> call(
      AudioRecording audioRecording, String topicId, String userId) async {
    final result =
        await repository.updateAudioRecording(audioRecording, topicId, userId);
    return result.fold(
      (failure) => Left(failure),
      (audioRecording) => Right(audioRecording),
    );
  }
}

class DeleteAudioRecording {
  final AudioRecordingRepository repository;

  DeleteAudioRecording(this.repository);

  Future<void> call(String parentId, String audioId, String userId) async {
    return repository.deleteAudioRecording(parentId, audioId, userId);
  }
}

// class PlayAudio {
//   final AudioRepository repository;

//   PlayAudio(this.repository);

//   Future<void> call(String filePath) async {
//     await repository.play(filePath);
//   }
// }

// class PauseAudio {
//   final AudioRepository repository;

//   PauseAudio(this.repository);

//   Future<void> call() async {
//     await repository.pause();
//   }
// }

// class StopAudio {
//   final AudioRepository repository;

//   StopAudio(this.repository);

//   Future<void> call() async {
//     await repository.stop();
//   }
// }

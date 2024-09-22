import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

abstract class AudioRecordingRepository {
  Future<Either<Failure, AudioRecording>> createAudioRecording(
      AudioRecording note, String topicId);
  Future<Either<Failure, AudioRecording>> updateAudioRecording(
      AudioRecording note, String topicId);
  Future<void> deleteAudioRecording(String noteId);
  Future<Either<Failure, PaginatedObj<AudioRecording>>> fetchAudioRecordings(
      String topicId, int limit, int startAfter);
  Future<Either<Failure, void>> syncAudioRecordings();
  Future<Either<Failure, void>> updateAudioRecordingOfParent(
      String parentId, String noteId);
}

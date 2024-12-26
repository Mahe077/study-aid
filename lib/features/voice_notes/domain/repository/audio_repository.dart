import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

abstract class AudioRecordingRepository {
  Future<Either<Failure, Tuple2<AudioRecording, String>>> createAudioRecording(
      AudioRecording audio, String topicId, String userId, bool isTranscribe);
  Future<Either<Failure, AudioRecording>> updateAudioRecording(
      AudioRecording audio, String topicId, String userId);
  Future<void> deleteAudioRecording(
      String parentId, String audioId, String userId);
  Future<Either<Failure, PaginatedObj<AudioRecording>>> fetchAudioRecordings(
      String topicId, int limit, int startAfter, String sortBy);
  Future<Either<Failure, void>> syncAudioRecordings();
  Future<Either<Failure, void>> updateAudioRecordingOfParent(
      String parentId, String audioId);
  // Future<File?> downloadFile(String url, String filePath);
  Future<Either<Failure, AudioRecording?>> getAudio(String audioId);
  Future<Either<Failure, void>> updateAudioOfParent(
      String parentId, String audioId);
  Future<Either<Failure, List<AudioRecording>>> search(
      String query, String userId);
}

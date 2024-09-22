import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, AudioRecordingModel>> createAudioRecording(
      AudioRecordingModel audio);
  Future<Either<Failure, AudioRecordingModel>> updateAudioRecording(
      AudioRecordingModel audio);
  Future<Either<Failure, void>> deleteAudioRecording(String audioId);
  Future<Either<Failure, void>> fetchAllAudioRecordings();
  Future<Either<Failure, AudioRecordingModel>> getAudioRecordingById(
      String parentId);
  Future<bool> audioExists(String audioId);
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> audioExists(String audioId) async {
    try {
      final docRef = _firestore.collection('audios').doc(audioId);
      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } on Exception catch (e) {
      throw Exception('Error checking audio existence: $e');
    }
  }

  @override
  Future<Either<Failure, AudioRecordingModel>> createAudioRecording(
      AudioRecordingModel audio) async {
    try {
      final docRef = _firestore.collection('audios').doc();
      final topicWithId =
          audio.copyWith(id: docRef.id, syncStatus: ConstantStrings.synced);
      await docRef.set(topicWithId.toFirestore());
      return Right(topicWithId);
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    } on Exception catch (e) {
      throw Exception('Error in creating a audio: $e');
    }
  }

  @override
  Future<Either<Failure, void>> deleteAudioRecording(String audioId) async {
    try {
      await _firestore.collection('audios').doc(audioId).delete();
      return const Right(null);
    } catch (e) {
      throw Exception('Error in deleting the audio: $e');
    }
  }

  @override
  Future<Either<Failure, void>> fetchAllAudioRecordings() {
    // TODO: implement fetchAllAudios
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AudioRecordingModel>> getAudioRecordingById(
      String parentId) async {
    try {
      final querySnapshot =
          await _firestore.collection('audios').doc(parentId).get();
      return Right(AudioRecordingModel.fromFirestore(querySnapshot));
    } catch (e) {
      throw Exception('Error in updating a audio: $e');
    }
  }

  @override
  Future<Either<Failure, AudioRecordingModel>> updateAudioRecording(
      AudioRecordingModel audio) async {
    try {
      await _firestore.collection('audios').doc(audio.id).update(
          audio.copyWith(syncStatus: ConstantStrings.synced).toFirestore());
      return Right(audio.copyWith(syncStatus: ConstantStrings.synced));
    } on Exception catch (e) {
      throw Exception('Error in updating a audio: $e');
    }
  }
}

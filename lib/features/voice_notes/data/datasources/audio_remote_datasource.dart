import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
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

      String localFilePath = audio.localpath;
      File audioFile = File(localFilePath);
      if (!audioFile.existsSync()) {
        return Left(Failure('Local file does not exist: $localFilePath'));
      }

      // Firebase storage reference
      final storageRef =
          FirebaseStorage.instance.ref(); //TODO: get firebase storage

      // Reference to the folder where the file will be stored
      String filename = localFilePath.split('/').last; // Get only the file name
      Reference audiosRef = storageRef.child("Audio/$filename");

      try {
        // Upload the audio file to Firebase Storage
        await audiosRef.putFile(audioFile);

        //You can retrieve the download URL if needed
        String downloadUrl = await audiosRef.getDownloadURL();

        final audioWithId = audio.copyWith(
            id: docRef.id,
            syncStatus: ConstantStrings.synced,
            url: downloadUrl);
        await docRef.set(audioWithId.toFirestore());

        return Right(audioWithId);
      } on FirebaseException catch (e) {
        return Left(Failure('Failed to upload audio: ${e.message}'));
      }
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

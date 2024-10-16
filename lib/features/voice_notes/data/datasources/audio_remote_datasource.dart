import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';
import 'package:http/http.dart' as http;

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
  Future<File?> downloadFile(String url, String filePath, {int retries = 3});
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

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
      var storageRef = _storage.ref();

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

  @override
  Future<File?> downloadFile(String url, String filePath,
      {int retries = 3}) async {
    int attempts = 0;
    while (attempts < retries) {
      attempts++;
      try {
        final uri = Uri.parse(url);
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 60)); // Adjusted timeout

        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          Logger().d("File downloaded successfully: $filePath");
          return file;
        } else {
          Logger().e(
              "Failed to download file. Status code: ${response.statusCode}");
        }
      } on TimeoutException catch (e) {
        Logger().e("Attempt $attempts: File download timed out: $e");
      } on SocketException catch (e) {
        Logger().e("No internet connection or server is unreachable: $e");
      } on HandshakeException catch (e) {
        Logger().e("SSL Handshake failed: $e");
      } catch (e) {
        Logger().e("Error downloading file: $e");
      }

      // If we exhausted the retries
      if (attempts >= retries) {
        Logger().e("Failed to download file after $attempts attempts.");
        break;
      }
      // Delay between retries
      await Future.delayed(const Duration(seconds: 5));
    }

    return null;
    // Return null if download fails
    //   var storageRef = _storage.ref();
    //   try {
    //     final chlidRef = storageRef.child(url);

    //     final file = File(filePath);

    //     final downloadTask = chlidRef.writeToFile(file);

    //     // Wait for the task to complete
    //     final taskSnapshot = await downloadTask;

    //     // Check if the download was successful
    //     if (taskSnapshot.state == TaskState.success) {
    //       Logger().d("File downloaded successfully to $filePath");
    //       return file; // Return the file after successful download
    //     } else {
    //       Logger().d(
    //           "Failed to download the file: Task state is ${taskSnapshot.state}");
    //       return null; // Return null in case of failure
    //     }
    //   } catch (e) {
    //     Logger().d("Error downloading file: $e");
    //   }
    //   return null;
  }
}

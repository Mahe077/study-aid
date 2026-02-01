import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/features/transcribe/domain/usecases/start_transcription_usecase.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';
import 'package:http/http.dart' as http;

abstract class RemoteDataSource {
  Future<Either<Failure, Tuple2<AudioRecordingModel, String>>>
      createAudioRecording(AudioRecordingModel audio, bool isTranscribe);
  Future<Either<Failure, AudioRecordingModel>> updateAudioRecording(
      AudioRecordingModel audio);
  Future<Either<Failure, void>> deleteAudioRecording(String audioId);
  Future<Either<Failure, void>> fetchAllAudioRecordings();
  Future<Either<Failure, AudioRecordingModel>> getAudioRecordingById(
      String parentId);
  Future<bool> audioExists(String audioId);
  Future<File?> downloadFile(String url, String filePath, {int retries = 3});
  Future<Either<Failure, List<AudioRecordingModel>>> searchFromRemote(
      String query, String userId);
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final StartTranscriptionUseCase transcribeAudioUseCase;

  RemoteDataSourceImpl(this.transcribeAudioUseCase);

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
  Future<Either<Failure, Tuple2<AudioRecordingModel, String>>>
      createAudioRecording(AudioRecordingModel audio, bool isTranscribe) async {
    try {
      final docRef = _firestore.collection('audios').doc();

      String localFilePath = audio.localpath;
      File audioFile = File(localFilePath);
      if (!await audioFile.exists()) {
        return Left(Failure('Local file does not exist: $localFilePath'));
      }

      // Upload the audio file to Firebase Storage and get the download URL
      final uploadResult = await _uploadAudioToFirebase(audioFile);
      return uploadResult.fold(
        (failure) => Left(failure), // Return the failure if upload fails
        (downloadUrl) async {
          // Create the audio recording with the download URL
          final audioWithId = audio.copyWith(
            id: docRef.id,
            syncStatus: ConstantStrings.synced,
            url: downloadUrl,
          );

          await docRef.set(audioWithId.toFirestore());

          String transcribeText =
              ''; // Call transcription if isTranscribe is true
          if (isTranscribe) {
            transcribeText =
                await _handleTranscription(localFilePath, audioWithId.id);
          }

          return Right(Tuple2(audioWithId, transcribeText));
        },
      );
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    } on Exception catch (e) {
      throw Exception('Error in creating an audio: $e');
    }
  }

  /// Handle transcription using the local MP3 file.
  Future<String> _handleTranscription(String mp3File, String audioId) async {
    try {
      final transcriptionResult = await transcribeAudioUseCase.call(mp3File);
      Logger().d("Transcription for $audioId: ${transcriptionResult.text}");
      return transcriptionResult.text;
      // TODO: Save transcription result as a note in Firestore if needed
    } catch (e) {
      Logger().e('Transcription failed: $e');
    }
    return '';
  }

  Future<Either<Failure, String>> _uploadAudioToFirebase(File audioFile) async {
    try {
      var storageRef = _storage.ref();

      // Reference to the folder where the file will be stored
      String filename =
          audioFile.path.split('/').last; // Get only the file name
      Reference audiosRef = storageRef.child("Audio/$filename");

      // Upload the audio file to Firebase Storage with a timeout
      await audiosRef.putFile(audioFile).timeout(const Duration(seconds: 60));

      // Retrieve the download URL
      String downloadUrl = await audiosRef.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(Failure('Failed to upload audio: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAudioRecording(String audioId) async {
    try {
      final audioResult = await getAudioRecordingById(audioId);
      audioResult.fold(
        (failure) => throw Exception('Audio not found: ${failure.message}'),
        (audio) async {
          final deleteFileResult = await _deleteAudioFile(audio.url);
          if (deleteFileResult.isLeft()) {
            return deleteFileResult; // Return error if file deletion fails
          }
        },
      );

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

      if (querySnapshot.exists && querySnapshot.data() != null) {
        final audio = AudioRecordingModel.fromFirestore(querySnapshot);
        return Right(audio);
      } else {
        return Left(ServerFailure('Audio not found'));
      }
    } catch (e) {
      throw Exception('Error in fetching a audio: $e');
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
      {int retries = 3,
      Duration retryDelay = const Duration(seconds: 5)}) async {
    int attempts = 0;
    while (attempts < retries) {
      attempts++;
      try {
        // Validate URL
        final uri = Uri.tryParse(url);
        if (uri == null || !uri.isAbsolute) {
          Logger().e("Invalid URL: $url");
          return null;
        }

        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 60)); // Adjusted timeout

        if (response.statusCode == 200) {
          final fullFilePath = await getAudioFilePath(filePath);
          final file = File(fullFilePath);

          await file.writeAsBytes(response.bodyBytes);
          Logger().d("File downloaded successfully: $fullFilePath");
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
      if (attempts < retries) {
        Logger().d("Retrying in ${retryDelay.inSeconds} seconds...");
        await Future.delayed(retryDelay);
      } else {
        Logger().e("Failed to download file after $attempts attempts.");
      }
    }
    return null;
  }

  Future<Either<Failure, void>> _deleteAudioFile(String audioUrl) async {
    try {
      // Create a reference to the audio file in Firebase Storage using the URL
      final storageRef = _storage.refFromURL(audioUrl);

      // Delete the audio file from Firebase Storage
      await storageRef.delete();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure('Failed to delete audio file: ${e.message}'));
    } catch (e) {
      return Left(Failure('Error in deleting audio file: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AudioRecordingModel>>> searchFromRemote(
      String query, String userId) async {
    query = query.toLowerCase();
    try {
      //   final lowerCaseQuery = query.toLowerCase();

      final audiosSnapshot = await _firestore
          .collection('audios')
          .where('userId', isEqualTo: userId)
          .where('tags', arrayContainsAny: [query]).get();

      // Query for documents where the 'title' matches the query
      final titleQuerySnapshot = await _firestore
          .collection('audios')
          .where('userId', isEqualTo: userId)
          .where('titleLowerCase',
              isGreaterThanOrEqualTo: query, isLessThan: '$query\uf8ff')
          .get();

      // Combine the results, removing duplicates
      final Map<String, DocumentSnapshot> uniqueDocs = {};

      // Add docs from tags search to the map
      for (var doc in audiosSnapshot.docs) {
        uniqueDocs[doc.id] = doc;
      }

      // Add docs from title search to the map (duplicate IDs will be ignored)
      for (var doc in titleQuerySnapshot.docs) {
        uniqueDocs[doc.id] = doc;
      }

      final audios = uniqueDocs.values
          .map((doc) => AudioRecordingModel.fromFirestore(doc))
          .toList();
      return Right(audios);
    } catch (e) {
      throw Exception('Error in fetching audios from tags: $e');
    }
  }
}

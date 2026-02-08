import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/files/data/models/file_model.dart';

abstract class FileRemoteDataSource {
  Future<Either<Failure, FileModel>> createFile(FileModel file);
  Future<Either<Failure, FileModel>> upsertFile(FileModel file);
  Future<Either<Failure, FileModel>> updateFile(FileModel file);
  Future<Either<Failure, void>> deleteFile(String fileId);
  Future<Either<Failure, FileModel>> getFileById(String fileId);
  Future<bool> fileExists(String fileId);
  Future<bool> storageFileExists(String fileUrl);
  Future<Either<Failure, List<FileModel>>> searchFromRemote(
      String query, String userId);
  Future<String> uploadFileToStorage(
      Uint8List bytes, String fileName, String userId, String topicId);
}

class FileRemoteDataSourceImpl extends FileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<bool> fileExists(String fileId) async {
    try {
      final docRef = _firestore.collection('files').doc(fileId);
      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } on Exception catch (e) {
      throw Exception('Error checking file existence: $e');
    }
  }

  @override
  Future<bool> storageFileExists(String fileUrl) async {
    if (fileUrl.isEmpty) return false;
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> uploadFileToStorage(
      Uint8List bytes, String fileName, String userId, String topicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'files/$userId/$topicId/${timestamp}_$fileName';
      final ref = _storage.ref().child(path);

      await ref.putData(bytes).timeout(const Duration(seconds: 60));
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw ServerException('File upload failed: $e');
    }
  }

  @override
  Future<Either<Failure, FileModel>> createFile(FileModel file) async {
    try {
      final docRef = _firestore.collection('files').doc();
      final fileWithId = file.copyWith(
        id: docRef.id,
        syncStatus: ConstantStrings.synced,
      );
      await docRef.set(fileWithId.toFirestore());
      return Right(fileWithId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firestore error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error creating file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileModel>> upsertFile(FileModel file) async {
    try {
      final fileWithStatus = file.copyWith(
        syncStatus: ConstantStrings.synced,
      );
      await _firestore
          .collection('files')
          .doc(fileWithStatus.id)
          .set(fileWithStatus.toFirestore());
      return Right(fileWithStatus);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firestore error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error upserting file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String fileId) async {
    try {
      final fileResult = await getFileById(fileId);
      
      await fileResult.fold(
        (failure) => throw Exception('File not found: ${failure.message}'),
        (file) async {
          // Delete from Storage
          if (file.fileUrl.isNotEmpty) {
            try {
              final ref = _storage.refFromURL(file.fileUrl);
              await ref.delete();
            } catch (e) {
              // File might already be deleted, continue
            }
          }
        },
      );

      await _firestore.collection('files').doc(fileId).delete();
      return const Right(null);
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  @override
  Future<Either<Failure, FileModel>> getFileById(String fileId) async {
    try {
      final docSnapshot =
          await _firestore.collection('files').doc(fileId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final file = FileModel.fromFirestore(docSnapshot);
        return Right(file);
      } else {
        return Left(ServerFailure('File not found'));
      }
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firestore error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error fetching file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileModel>> updateFile(FileModel file) async {
    try {
      final updatedFile = file.copyWith(
        syncStatus: ConstantStrings.synced,
      );

      await _firestore
          .collection('files')
          .doc(file.id)
          .update(updatedFile.toFirestore());

      return Right(updatedFile);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firestore error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error updating file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FileModel>>> searchFromRemote(
      String query, String userId) async {
    query = query.toLowerCase();
    try {
      final snapshot = await _firestore
          .collection('files')
          .where('userId', isEqualTo: userId)
          .where('fileName', isGreaterThanOrEqualTo: query)
          .where('fileName', isLessThan: '$query\uf8ff')
          .get();

      final files =
          snapshot.docs.map((doc) => FileModel.fromFirestore(doc)).toList();
      return Right(files);
    } catch (e) {
      throw Exception('Error searching files: $e');
    }
  }
}

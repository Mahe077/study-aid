import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/notes/data/models/note.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, NoteModel>> createNote(NoteModel note);
  Future<Either<Failure, NoteModel>> updateNote(NoteModel note);
  Future<Either<Failure, void>> deleteNote(String noteId);
  Future<Either<Failure, void>> fetchAllNotes();
  Future<Either<Failure, NoteModel>> getNoteById(String parentId);
  Future<bool> noteExists(String noteId);
  Future<Either<Failure, List<NoteModel>>> searchFromRemote(
      String query, String userId);
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<bool> noteExists(String noteId) async {
    try {
      final docRef = _firestore.collection('notes').doc(noteId);
      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } on Exception catch (e) {
      throw Exception('Error checking note existence: $e');
    }
  }

  @override
  Future<Either<Failure, NoteModel>> createNote(NoteModel note) async {
    try {
      final docRef = _firestore.collection('notes').doc();
      Map<String, String> content = await uploadImage(note.contentJson);

      final updatedContentJson = content['updatedContentJson'];

      final topicWithId = note.copyWith(
        id: docRef.id,
        syncStatus: ConstantStrings.synced,
        contentJson: updatedContentJson,
      );
      await docRef.set(topicWithId.toFirestore());
      return Right(topicWithId);
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    } on Exception catch (e) {
      throw Exception('Error in creating a note: $e');
    }
  }

  Future<String?> uploadImagetoFirebaseStorage(String imagePath) async {
    if (imagePath.isEmpty) return null;

    final storageRef = _storage.ref();
    final fileRef =
        storageRef.child('Images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await fileRef.putFile(File(imagePath)).timeout(const Duration(seconds: 60));
    final downloadUrl = await fileRef.getDownloadURL();
    return downloadUrl;
  }

  Future<Map<String, String>> uploadImage(String contentJson) async {
    List<dynamic> contentList = jsonDecode(contentJson);
    bool imageUploaded = false;

    for (var item in contentList) {
      if (item['insert'] is Map && item['insert'].containsKey('image')) {
        String imagePath = item['insert']['image'];

        // Check if the image is already hosted on Firebase.
        bool isFirebaseImage =
            imagePath.startsWith('https://firebasestorage.googleapis.com');

        if (!isFirebaseImage) {
          // Upload the local image to Firebase Storage.
          String? uploadedUrl = await uploadImagetoFirebaseStorage(imagePath);

          // Replace the local path with the uploaded Firebase URL.
          if (uploadedUrl != null) {
            item['insert'] = {'image': uploadedUrl};
            imageUploaded = true;
          }
        }
      }
    }

    if (imageUploaded) {
      contentJson = jsonEncode(contentList);
    }

    // Logger().d("updatedContentJson:: $contentJson");

    return {
      'updatedContentJson': contentJson,
    };
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      final noteResult = await getNoteById(noteId);
      noteResult.fold(
        (failure) => throw Exception('Note not found: ${failure.message}'),
        (note) async {
          await _deleteImagesFromContent(note.contentJson);
        },
      );

      await _firestore.collection('notes').doc(noteId).delete();
      return const Right(null);
    } catch (e) {
      throw Exception('Error in deleting the note: $e');
    }
  }

  @override
  Future<Either<Failure, void>> fetchAllNotes() {
    // TODO: implement fetchAllNotes
    throw UnimplementedError();
  }

  Future<void> _deleteImagesFromContent(String contentJson) async {
    List<dynamic> contentList = jsonDecode(contentJson);

    for (var item in contentList) {
      if (item['insert'] is Map && item['insert'].containsKey('image')) {
        final imageUrl = item['insert']['image'];

        // Check if it's a Firebase Storage URL and delete it.
        if (imageUrl.startsWith('https://firebasestorage.googleapis.com/')) {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      }
    }
  }

  @override
  Future<Either<Failure, NoteModel>> getNoteById(String parentId) async {
    try {
      final docSnapshot =
          await _firestore.collection('notes').doc(parentId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final note = NoteModel.fromFirestore(docSnapshot);
        return Right(note);
      } else {
        return Left(ServerFailure('Note not found'));
      }
    } catch (e) {
      throw Exception('Error in fetching a note: $e');
    }
  }

  @override
  Future<Either<Failure, NoteModel>> updateNote(NoteModel note) async {
    try {
      Map<String, String> content = await uploadImage(note.contentJson);

      // Extract content safely from the returned Map
      final updatedContentJson =
          content['updatedContentJson'] ?? note.contentJson;

      final updatedNote = note.copyWith(
        syncStatus: ConstantStrings.synced,
        contentJson: updatedContentJson,
      );

      await _firestore
          .collection('notes')
          .doc(note.id)
          .update(updatedNote.toFirestore());

      return Right(note.copyWith(syncStatus: ConstantStrings.synced));
    } on Exception catch (e) {
      throw Exception('Error in updating a note: $e');
    }
  }

  @override
  Future<Either<Failure, List<NoteModel>>> searchFromRemote(
      String query, String userId) async {
    query = query.toLowerCase();
    try {
      // Query for documents where the 'tags' array contains the query
      final notesSnapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('tags', arrayContainsAny: [query]).get();

      // Query for documents where the 'title' matches the query
      final titleQuerySnapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('titleLowerCase',
              isGreaterThanOrEqualTo: query, isLessThan: '$query\uf8ff')
          .get();

      final Map<String, DocumentSnapshot> uniqueDocs = {};

      // Add docs from tags search to the map
      for (var doc in notesSnapshot.docs) {
        uniqueDocs[doc.id] = doc;
      }

      // Add docs from title search to the map (duplicate IDs will be ignored)
      for (var doc in titleQuerySnapshot.docs) {
        uniqueDocs[doc.id] = doc;
      }

      final notes =
          uniqueDocs.values.map((doc) => NoteModel.fromFirestore(doc)).toList();
      return Right(notes);
    } catch (e) {
      throw Exception('Error in fetching notes from tags: $e');
    }
  }
}

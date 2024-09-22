import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/notes/data/models/note.dart';
import 'package:study_aid/features/notes/data/models/note.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, NoteModel>> createNote(NoteModel note);
  Future<Either<Failure, NoteModel>> updateNote(NoteModel note);
  Future<Either<Failure, void>> deleteNote(String noteId);
  Future<Either<Failure, void>> fetchAllNotes();
  Future<Either<Failure, NoteModel>> getNoteById(String parentId);
  Future<bool> noteExists(String noteId);
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final topicWithId =
          note.copyWith(id: docRef.id, syncStatus: ConstantStrings.synced);
      await docRef.set(topicWithId.toFirestore());
      return Right(topicWithId);
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    } on Exception catch (e) {
      throw Exception('Error in creating a note: $e');
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
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

  @override
  Future<Either<Failure, NoteModel>> getNoteById(String parentId) async {
    try {
      final querySnapshot =
          await _firestore.collection('notes').doc(parentId).get();
      return Right(NoteModel.fromFirestore(querySnapshot));
    } catch (e) {
      throw Exception('Error in updating a note: $e');
    }
  }

  @override
  Future<Either<Failure, NoteModel>> updateNote(NoteModel note) async {
    try {
      await _firestore.collection('notes').doc(note.id).update(
          note.copyWith(syncStatus: ConstantStrings.synced).toFirestore());
      return Right(note.copyWith(syncStatus: ConstantStrings.synced));
    } on Exception catch (e) {
      throw Exception('Error in updating a note: $e');
    }
  }
}

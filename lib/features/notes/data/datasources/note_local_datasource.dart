import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/notes/data/models/note.dart';

abstract class LocalDataSource {
  Future<void> createNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String noteId);
  Future<Either<Failure, PaginatedObj<NoteModel>>> fetchPeginatedNotes(
      int limit, List<dynamic> noteRefs, int startAfter, String sortBy);
  Future<NoteModel?> getCachedNote(String noteId);
  Future<List<NoteModel>> fetchAllNotes();
  bool noteExists(String noteId);
  Future<List<NoteModel>> searchFromLocal(String query);
}

class LocalDataSourceImpl extends LocalDataSource {
  final Box<NoteModel> _noteBox;

  LocalDataSourceImpl(this._noteBox);

  @override
  Future<Either<Failure, PaginatedObj<NoteModel>>> fetchPeginatedNotes(
      int limit, List<dynamic> noteRefs, int startAfter, String sortBy) async {
    try {
      int startIndex = startAfter;
      int endIndex = startIndex + limit;

      printNoteBoxContents();

      List<Future<NoteModel?>> futureNotes = noteRefs.map((noteId) {
        return getCachedNote(noteId);
      }).toList();

      List<NoteModel?> notes = await Future.wait(futureNotes);

      List<NoteModel> nonNullNotes =
          notes.where((note) => note != null).cast<NoteModel>().toList();

      if (sortBy == 'updatedDate') {
        nonNullNotes.sort(
            (a, b) => b.updatedDate.compareTo(a.updatedDate)); // Descending
      } else if (sortBy == 'createdDate') {
        nonNullNotes.sort(
            (a, b) => b.createdDate.compareTo(a.createdDate)); // Descending
      } else if (sortBy == 'title') {
        nonNullNotes.sort((a, b) => a.titleLowerCase
            .compareTo(b.titleLowerCase)); // Ascending alphabetical order
      }

      final hasmore = notes.length > endIndex ? true : false;

      return Right(PaginatedObj(
          items: hasmore
              ? nonNullNotes.sublist(startIndex, endIndex)
              : nonNullNotes.sublist(startIndex),
          hasMore: hasmore,
          lastDocument: hasmore ? endIndex : notes.length));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<NoteModel?> getCachedNote(String noteId) async {
    try {
      printNoteBoxContents();
      return _noteBox.get(noteId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<NoteModel>> fetchAllNotes() async {
    return _noteBox.values.toList();
  }

  @override
  Future<void> createNote(NoteModel note) async {
    await _noteBox.put(note.id, note);
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _noteBox.delete(noteId);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await _noteBox.put(note.id, note);
  }

  @override
  bool noteExists(String noteId) {
    return _noteBox.containsKey(noteId);
  }

  void printNoteBoxContents() {
    // Assuming _topicBox is your Hive box
    var allKeys = _noteBox.keys;
    Logger().d('All keys in topicBox: $allKeys');

    var allTopics = _noteBox.values.toList();
    if (kDebugMode) {
      print('All items in topicBox:');
    }
    for (var i = 0; i < allTopics.length; i++) {
      if (kDebugMode) {
        print('Item $i: ${allTopics[i]} -> ${allTopics[i].id} ');
      }
    }
  }

  @override
  Future<List<NoteModel>> searchFromLocal(String query) async {
    final lowerCaseQuery = query.toLowerCase();

    // Fetch all local notes
    final notes = _noteBox.values
        .where((note) =>
            note.tags
                .any((tag) => tag.toLowerCase().contains(lowerCaseQuery)) ||
            (note.titleLowerCase.contains(lowerCaseQuery)))
        .toList();

    return notes;
  }
}

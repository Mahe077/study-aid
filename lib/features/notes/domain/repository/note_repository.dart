import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<Either<Failure, Note>> createNote(Note note, String topicId);
  Future<Either<Failure, Note>> updateNote(Note note, String topicId);
  Future<void> deleteNote(String noteId);
  Future<Either<Failure, PaginatedObj<Note>>> fetchNotes(
      String topicId, int limit, int startAfter);
  Future<Either<Failure, void>> syncNotes();
  Future<Either<Failure, void>> updateNoteOfParent(
      String parentId, String noteId);
}

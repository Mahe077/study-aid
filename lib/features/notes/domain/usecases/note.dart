import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';

class SyncNotesUseCase {
  final NoteRepository repository;

  SyncNotesUseCase(this.repository);

  Future<void> call() async {
    final result = await repository.syncNotes();
    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}

class CreateNote {
  final NoteRepository repository;

  CreateNote(this.repository);

  Future<Either<Failure, Note>> call(
      Note note, String topicId, String userId) async {
    final result = await repository.createNote(note, topicId, userId);
    return result.fold(
      (failure) => Left(failure),
      (note) => Right(note),
    );
  }
}

class UpdateNote {
  final NoteRepository repository;

  UpdateNote(this.repository);

  Future<Either<Failure, Note>> call(
      Note note, String topicId, String userId) async {
    final result = await repository.updateNote(note, topicId, userId);
    return result.fold(
      (failure) => Left(failure),
      (note) => Right(note),
    );
  }
}

class DeleteNote {
  final NoteRepository repository;

  DeleteNote(this.repository);

  Future<void> call(String parentId, String noteId, String userId) async {
    return repository.deleteNote(parentId, noteId, userId);
  }
}

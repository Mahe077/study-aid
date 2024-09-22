import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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

  Future<Either<Failure, Note>> call(Note note, String topicId) async {
    final result = await repository.createNote(note, topicId);
    return result.fold(
      (failure) => Left(failure),
      (note) => Right(note),
    );
  }
}

class UpdateNote {
  final NoteRepository repository;

  UpdateNote(this.repository);

  Future<Either<Failure, Note>> call(Note note, String topicId) async {
    final result = await repository.updateNote(note, topicId);
    return result.fold(
      (failure) => Left(failure),
      (note) => Right(note),
    );
  }
}

class DeleteNote {
  final NoteRepository repository;

  DeleteNote(this.repository);

  Future<void> call(String noteId) async {
    return repository.deleteNote(noteId);
  }
}

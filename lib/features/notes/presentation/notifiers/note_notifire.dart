import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/recentItem_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';

class NotesState {
  final List<Note> notes;
  final bool hasMore;
  final int lastDocument;

  NotesState({
    required this.notes,
    this.hasMore = true,
    required this.lastDocument,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? hasMore,
    required int lastDocument,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument,
    );
  }
}

class NotesNotifier extends StateNotifier<AsyncValue<NotesState>> {
  final NoteRepository repository;
  final String topicId;
  final Ref _ref;
  final String sortBy;

  NotesNotifier(this.repository, this.topicId, this._ref, this.sortBy)
      : super(const AsyncValue.loading()) {
    _loadInitialNotes();
  }

  Future<void> _loadInitialNotes() async {
    try {
      final result = await repository.fetchNotes(topicId, 5, 0, sortBy);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          state = AsyncValue.data(
            NotesState(
              notes: paginatedObj.items,
              hasMore: paginatedObj.hasMore,
              lastDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMoreNotes() async {
    final currentState = state;
    if (!currentState.value!.hasMore) return;

    final lastDocument = currentState.value!.lastDocument;
    try {
      final result =
          await repository.fetchNotes(topicId, 5, lastDocument, sortBy);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          final newNotes = paginatedObj.items
              .where((item) =>
                  !currentState.value!.notes.any((note) => note.id == item.id))
              .toList();

          state = AsyncValue.data(
            currentState.value!.copyWith(
              notes: [...currentState.value!.notes, ...newNotes],
              hasMore: paginatedObj.hasMore,
              lastDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<Either<Failure, Note>> createNote(
    Note note,
    String topicId,
    String userId,
    String dropdownValue,
  ) async {
    try {
      final createNote = _ref.read(createNoteProvider);
      final result = await createNote.call(note, topicId, userId);

      return result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return Left(failure);
        },
        (newNote) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(
              tabDataProvider(TabDataParams(topicId, dropdownValue)).notifier);
          tabDataNotifier.updateNote(newNote);

          final recentItemNotifier =
              _ref.read(recentItemProvider(userId).notifier);
          recentItemNotifier.updateNote(newNote);
          return Right(newNote);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, Note>> updateNote(
    Note note,
    String topicId,
    String userId,
    String dropdownValue,
  ) async {
    try {
      final updateNote = _ref.read(updateNoteProvider);
      final result = await updateNote.call(note, topicId, userId);

      return result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return Left(failure);
        },
        (updatedNote) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(
              tabDataProvider(TabDataParams(topicId, dropdownValue)).notifier);
          tabDataNotifier.updateNote(updatedNote);

          final recentItemNotifier =
              _ref.read(recentItemProvider(userId).notifier);
          recentItemNotifier.updateNote(updatedNote);
          return Right(updatedNote);
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      return Left(Failure(e.toString()));
    }
  }

  // Future<void> fetchAllNotes() async {
  //   state = const AsyncValue.loading();
  //   try {
  //     final fetchAllNotes = _ref.read(fetchAllNotesProvider);
  //     final result = await fetchAllNotes.call();

  //     result.fold(
  //       (failure) =>
  //           state = AsyncValue.error(failure.message, StackTrace.current),
  //       (notes) => state = AsyncValue.data(
  //           NotesState(notes: notes, lastDocument: notes.length)),
  //     );
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //   }
  // }

  Future<void> deleteNote(
    String parentId,
    String noteId,
    String userId,
    String dropdownValue,
  ) async {
    try {
      final deleteNote = _ref.read(deleteNoteProvider);
      await deleteNote.call(parentId, noteId, userId);

      final tabDataNotifier = _ref.read(
          tabDataProvider(TabDataParams(parentId, dropdownValue)).notifier);
      tabDataNotifier.deleteNote(noteId);

      final recentItemNotifier = _ref.read(recentItemProvider(userId).notifier);
      recentItemNotifier.deleteNote(noteId);
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
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

  NotesNotifier(this.repository, this.topicId, this._ref)
      : super(const AsyncValue.loading()) {
    _loadInitialNotes();
  }

  Future<void> _loadInitialNotes() async {
    try {
      final result = await repository.fetchNotes(topicId, 5, 0);
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
      final result = await repository.fetchNotes(topicId, 5, lastDocument);
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

  Future<void> createNote(Note note, String topicId) async {
    try {
      final createNote = _ref.read(createNoteProvider);
      final result = await createNote.call(note, topicId);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (newNote) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(tabDataProvider(topicId).notifier);
          tabDataNotifier.updateNote(newNote);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateNote(Note note, String topicId) async {
    // final currentState = state;
    try {
      final updateNote = _ref.read(updateNoteProvider);
      final result = await updateNote.call(note, topicId);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (updatedNote) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(tabDataProvider(topicId).notifier);
          tabDataNotifier.updateNote(updatedNote);
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
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

  Future<void> deleteNote(String noteId) async {
    state = const AsyncValue.loading();
    try {
      final deleteNote = _ref.read(deleteNoteProvider);
      await deleteNote.call(noteId);

      final currentState = state;
      state = AsyncValue.data(
        currentState.value!.copyWith(
            notes: currentState.value!.notes
                .where((note) => note.id != noteId)
                .toList(),
            lastDocument: currentState.value!.lastDocument),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// class NoteChildNotifier extends StateNotifier<AsyncValue<NotesState>> {
//   final NoteRepository repository;
//   final String userId;
//   final Ref _ref;

//   NoteChildNotifier(this.repository, this.userId, this._ref)
//       : super(const AsyncValue.loading()) {
//     _loadInitialNoteChild();
//   }

//   Future<void> _loadInitialNoteChild() async {
//     try {
//       final result = await repository.fetchSubNotes(userId, 5, 0);
//       result.fold(
//         (failure) =>
//             state = AsyncValue.error(failure.message, StackTrace.current),
//         (paginatedObj) {
//           state = AsyncValue.data(
//             NotesState(
//               notes: paginatedObj.items,
//               hasMore: paginatedObj.hasMore,
//               lastDocument: paginatedObj.lastDocument,
//             ),
//           );
//         },
//       );
//     } catch (e, stackTrace) {
//       state = AsyncValue.error(e, stackTrace);
//     }
//   }

//   // Future<void> loadMoreNoteChild() async {
//   //   final currentState = state;
//   //   if (!currentState.value!.hasMore) return;

//   //   final lastDocument = currentState.value!.lastDocument;
//   //   try {
//   //     final result = await repository.fetchSubNotes(userId, 5, lastDocument);
//   //     result.fold(
//   //       (failure) =>
//   //           state = AsyncValue.error(failure.message, StackTrace.current),
//   //       (paginatedObj) {
//   //         final newNotes = paginatedObj.items
//   //             .where((item) => !currentState.value!.notes
//   //                 .any((note) => note.id == item.id))
//   //             .toList();

//   //         state = AsyncValue.data(
//   //           currentState.value!.copyWith(
//   //             notes: [...currentState.value!.notes, ...newNotes],
//   //             hasMore: paginatedObj.hasMore,
//   //             lastDocument: paginatedObj.lastDocument,
//   //           ),
//   //         );
//   //       },
//   //     );
//   //   } catch (e, stackTrace) {
//   //     state = AsyncValue.error(e, stackTrace);
//   //   }
//   // }
// }

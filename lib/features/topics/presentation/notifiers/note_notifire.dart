import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';

class NotesState {
  final List<Note> notes;
  final bool hasMore;
  final int lastDocument;

  NotesState(
      {required this.notes, this.hasMore = true, required this.lastDocument});

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

class NoteNotifire extends StateNotifier<AsyncValue<NotesState>> {
  final NoteRepository repository;
  final String topicId;
  final Ref _ref;

  NoteNotifire(this.repository, this.topicId, this._ref)
      : super(const AsyncValue.loading()) {
    _loadInitNotes();
  }

  Future<void> _loadInitNotes() async {
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
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/domain/repository/audio_repository.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';

class AudioState {
  final List<AudioRecording> notes;
  final bool hasMore;
  final int lastDocument;

  AudioState({
    required this.notes,
    this.hasMore = true,
    required this.lastDocument,
  });

  AudioState copyWith({
    List<AudioRecording>? notes,
    bool? hasMore,
    required int lastDocument,
  }) {
    return AudioState(
      notes: notes ?? this.notes,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument,
    );
  }
}

class AudioNotifier extends StateNotifier<AsyncValue<AudioState>> {
  final AudioRecordingRepository repository;
  final String topicId;
  final Ref _ref;

  AudioNotifier(this.repository, this.topicId, this._ref)
      : super(const AsyncValue.loading()) {
    _loadInitialAudio();
  }

  Future<void> _loadInitialAudio() async {
    try {
      final result = await repository.fetchAudioRecordings(topicId, 5, 0);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          state = AsyncValue.data(
            AudioState(
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

  Future<void> loadMoreAudio() async {
    final currentState = state;
    if (!currentState.value!.hasMore) return;

    final lastDocument = currentState.value!.lastDocument;
    try {
      final result =
          await repository.fetchAudioRecordings(topicId, 5, lastDocument);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          final newAudio = paginatedObj.items
              .where((item) =>
                  !currentState.value!.notes.any((note) => note.id == item.id))
              .toList();

          state = AsyncValue.data(
            currentState.value!.copyWith(
              notes: [...currentState.value!.notes, ...newAudio],
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

  Future<void> createAudio(AudioRecording note, String topicId) async {
    try {
      final createAudio = _ref.read(createAudioRecodingProvider);
      final result = await createAudio.call(note, topicId);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (newAudio) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(tabDataProvider(topicId).notifier);
          tabDataNotifier.updateAudioRecording(newAudio);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAudio(AudioRecording note, String topicId) async {
    // final currentState = state;
    try {
      final updateAudio = _ref.read(updateAudioRecodingProvider);
      final result = await updateAudio.call(note, topicId);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (updatedAudio) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(tabDataProvider(topicId).notifier);
          tabDataNotifier.updateAudioRecording(updatedAudio);
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  // Future<void> fetchAllAudio() async {
  //   state = const AsyncValue.loading();
  //   try {
  //     final fetchAllAudio = _ref.read(fetchAllAudioProvider);
  //     final result = await fetchAllAudio.call();

  //     result.fold(
  //       (failure) =>
  //           state = AsyncValue.error(failure.message, StackTrace.current),
  //       (notes) => state = AsyncValue.data(
  //           AudioState(notes: notes, lastDocument: notes.length)),
  //     );
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //   }
  // }

  Future<void> deleteAudio(String noteId) async {
    state = const AsyncValue.loading();
    try {
      final deleteAudio = _ref.read(deleteAudioRecodingProvider);
      await deleteAudio.call(noteId);

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

// class AudioChildNotifier extends StateNotifier<AsyncValue<AudioState>> {
//   final AudioRepository repository;
//   final String userId;
//   final Ref _ref;

//   AudioChildNotifier(this.repository, this.userId, this._ref)
//       : super(const AsyncValue.loading()) {
//     _loadInitialAudioChild();
//   }

//   Future<void> _loadInitialAudioChild() async {
//     try {
//       final result = await repository.fetchSubAudio(userId, 5, 0);
//       result.fold(
//         (failure) =>
//             state = AsyncValue.error(failure.message, StackTrace.current),
//         (paginatedObj) {
//           state = AsyncValue.data(
//             AudioState(
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

//   // Future<void> loadMoreAudioChild() async {
//   //   final currentState = state;
//   //   if (!currentState.value!.hasMore) return;

//   //   final lastDocument = currentState.value!.lastDocument;
//   //   try {
//   //     final result = await repository.fetchSubAudio(userId, 5, lastDocument);
//   //     result.fold(
//   //       (failure) =>
//   //           state = AsyncValue.error(failure.message, StackTrace.current),
//   //       (paginatedObj) {
//   //         final newAudio = paginatedObj.items
//   //             .where((item) => !currentState.value!.notes
//   //                 .any((note) => note.id == item.id))
//   //             .toList();

//   //         state = AsyncValue.data(
//   //           currentState.value!.copyWith(
//   //             notes: [...currentState.value!.notes, ...newAudio],
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

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/topics/presentation/providers/recentItem_provider.dart';
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
        (failure) {
          if (mounted) {
            state = AsyncValue.error(failure.message, StackTrace.current);
          }
        },
        (paginatedObj) {
          if (mounted) {
            state = AsyncValue.data(
              AudioState(
                notes: paginatedObj.items,
                hasMore: paginatedObj.hasMore,
                lastDocument: paginatedObj.lastDocument,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
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

  Future<Either<Failure, AudioRecording>> createAudio(
      AudioRecording note, String topicId, String userId) async {
    try {
      final createAudio = _ref.read(createAudioRecodingProvider);
      final result = await createAudio.call(note, topicId, userId);
      return result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return Left(failure);
        },
        (newAudio) async {
          final tabDataNotifier = _ref.read(tabDataProvider(topicId).notifier);
          tabDataNotifier.updateAudioRecording(newAudio);

          final recentItemNotifier =
              _ref.read(recentItemProvider(userId).notifier);
          recentItemNotifier.updateAudioRecording(newAudio);

          return Right(newAudio);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, AudioRecording>> updateAudio(
      AudioRecording note, String topicId, String userId) async {
    // final currentState = state;
    try {
      final updateAudio = _ref.read(updateAudioRecodingProvider);
      final result = await updateAudio.call(note, topicId, userId);

      return result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return Left(failure);
        },
        (updatedAudio) {
          // Notify TabDataNotifier to update state
          final tabDataNotifier = _ref.read(tabDataProvider(topicId).notifier);
          tabDataNotifier.updateAudioRecording(updatedAudio);

          final recentItemNotifier =
              _ref.read(recentItemProvider(userId).notifier);
          recentItemNotifier.updateAudioRecording(updatedAudio);

          return Right(updatedAudio);
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      return Left(Failure(e.toString()));
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

  Future<void> deleteAudio(
      String parentId, String audioId, String userId) async {
    try {
      final deleteAudio = _ref.read(deleteAudioRecodingProvider);
      await deleteAudio.call(parentId, audioId, userId);

      final tabDataNotifier = _ref.read(tabDataProvider(parentId).notifier);
      tabDataNotifier.deleteAudio(audioId);

      final recentItemNotifier = _ref.read(recentItemProvider(userId).notifier);
      recentItemNotifier.deleteAudio(audioId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

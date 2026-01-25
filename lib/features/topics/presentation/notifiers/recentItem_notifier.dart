import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/domain/repository/audio_repository.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:study_aid/features/files/domain/repository/file_repository.dart';
import 'package:study_aid/features/files/presentation/providers/files_providers.dart';

class RecentItemState {
  final List<dynamic> recentItems;

  RecentItemState({required this.recentItems});

  RecentItemState copyWith({
    required List<dynamic> recentItems,
  }) {
    return RecentItemState(
      recentItems: recentItems,
    );
  }
}

class RecentitemNotifier extends StateNotifier<AsyncValue<RecentItemState>> {
  final Ref ref;
  final String userId;

  RecentitemNotifier(this.ref, this.userId)
      : super(const AsyncValue.loading()) {
    loadRecentItems(userId);
  }

  Future<void> loadRecentItems(String userId) async {
    final userRepository = ref.read(userRepositoryProvider);
    final topicRepository = ref.read(topicRepositoryProvider);
    final noteRepository = ref.read(noteRepositoryProvider);
    final audioRepository = ref.read(audioRepositoryProvider);
    final fileRepository = ref.read(fileRepositoryProvider);

    try {
      final user = await userRepository.getUser(userId);
      user.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (U) {
          Logger().i("Recent items: ${U?.recentItems.toString()}");
          if (U != null && U.recentItems.isNotEmpty) {
            _fetchRecentItems(U.recentItems, topicRepository, noteRepository,
                audioRepository, fileRepository);
          } else {
            state = AsyncValue.data(RecentItemState(recentItems: []));
          }
        },
      );
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> _fetchRecentItems(
    List<Map<String, dynamic>> recentItems,
    TopicRepository topicRepository,
    NoteRepository noteRepository,
    AudioRecordingRepository audioRepository,
    FileRepository fileRepository,
  ) async {
    final List<dynamic> items = [];

    for (var item in recentItems) {
      final itemId = item['id'];
      final itemType = item['type'];

      switch (itemType) {
        case 'T':
          final topic = await topicRepository.getTopic(itemId);
          topic.fold(
            (failure) => Logger().e("Error fetching topic: ${failure.message}"),
            (topic) {
              if (topic != null) {
                items.add(topic);
              }
            },
          );
          break;

        case 'N':
          final note = await noteRepository.getNote(itemId);
          note.fold(
            (failure) => Logger().e("Error fetching note: ${failure.message}"),
            (note) {
              if (note != null) {
                items.add(note);
              }
            },
          );
          break;

        case 'A':
          final audio = await audioRepository.getAudio(itemId);
          audio.fold(
            (failure) => Logger().e("Error fetching audio: ${failure.message}"),
            (audio) {
              if (audio != null) {
                items.add(audio);
              }
            },
          );
          break;

        case 'F':
          final file = await fileRepository.getFile(itemId);
          file.fold(
            (failure) => Logger().e("Error fetching file: ${failure.message}"),
            (file) {
              if (file != null) {
                items.add(file);
              }
            },
          );
          break;
      }
    }

    // Update the state with the fetched items
    state = AsyncValue.data(RecentItemState(recentItems: items));
  }

  void updateNote(Note updatedNote) {
    final currentState = state;

    // Return if the state is null or if there is no data yet
    if (currentState.value == null) return;

    List<dynamic> updatedNoteList;

    // Check if the note to be updated exists in the current state
    if (currentState.value!.recentItems
        .any((item) => item is Note && item.id == updatedNote.id)) {
      // Map over the notes to replace the note with the updated note
      updatedNoteList = currentState.value!.recentItems
          .map((item) => item.id == updatedNote.id ? updatedNote : item)
          .toList();
    } else {
      // Add the updated note if it doesn't already exist
      updatedNoteList = [updatedNote, ...currentState.value!.recentItems];
    }

    // Update the state with the new list of notes
    state = AsyncValue.data(
      currentState.value!.copyWith(
        recentItems: updatedNoteList,
      ),
    );
  }

  void deleteNote(String noteId) {
    final currentState = state;

    // Return if the state is null or if there is no data yet
    if (currentState.value == null) return;

    // Update the state with the new list of notes
    state = AsyncValue.data(currentState.value!.copyWith(
      recentItems: currentState.value!.recentItems
          .where((note) => note.id != noteId)
          .toList(),
    ));
  }

  void updateAudioRecording(AudioRecording updatedAudio) {
    final currentState = state;
    if (currentState.value == null) return;

    List<dynamic> updatedAudioRecordingsList;

    // Check if the note to be updated exists in the current state
    if (currentState.value!.recentItems
        .any((audio) => audio.id == updatedAudio.id)) {
      // Map over the notes to replace the note with the updated note
      updatedAudioRecordingsList = currentState.value!.recentItems
          .map((audio) => audio.id == updatedAudio.id ? updatedAudio : audio)
          .toList();
    } else {
      // Add the updated note if it doesn't already exist
      updatedAudioRecordingsList = [
        updatedAudio,
        ...currentState.value!.recentItems
      ];
    }
    state = AsyncValue.data(
      currentState.value!.copyWith(
        recentItems: updatedAudioRecordingsList,
      ),
    );
  }

  void deleteAudio(String audioId) {
    final currentState = state;

    // Return if the state is null or if there is no data yet
    if (currentState.value == null) return;

    // Update the state with the new list of notes
    state = AsyncValue.data(currentState.value!.copyWith(
      recentItems: currentState.value!.recentItems
          .where((audio) => audio.id != audioId)
          .toList(),
    ));
  }

  void updateFile(FileEntity updatedFile) {
    final currentState = state;
    if (currentState.value == null) return;

    List<dynamic> updatedFilesList;

    if (currentState.value!.recentItems
        .any((item) => item is FileEntity && item.id == updatedFile.id)) {
      updatedFilesList = currentState.value!.recentItems
          .map((item) => item.id == updatedFile.id ? updatedFile : item)
          .toList();
    } else {
      updatedFilesList = [updatedFile, ...currentState.value!.recentItems];
    }

    state = AsyncValue.data(
      currentState.value!.copyWith(
        recentItems: updatedFilesList,
      ),
    );
  }

  void deleteFile(String fileId) {
    final currentState = state;
    if (currentState.value == null) return;

    state = AsyncValue.data(currentState.value!.copyWith(
      recentItems: currentState.value!.recentItems
          .where((item) => item.id != fileId)
          .toList(),
    ));
  }
}

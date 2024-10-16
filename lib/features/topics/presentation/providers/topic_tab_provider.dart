import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';

class TabDataState {
  final List<Topic> topics;
  final List<Note> notes;
  final List<AudioRecording> audioRecordings;
  final bool hasMoreTopics;
  final bool hasMoreNotes;
  final bool hasMoreAudio;
  final dynamic lastTopicDocument;
  final dynamic lastNoteDocument;
  final dynamic lastAudioDocument;

  TabDataState({
    required this.topics,
    required this.notes,
    required this.audioRecordings,
    required this.hasMoreTopics,
    required this.hasMoreNotes,
    required this.hasMoreAudio,
    this.lastTopicDocument,
    this.lastNoteDocument,
    this.lastAudioDocument,
  });

  TabDataState copyWith({
    List<Topic>? topics,
    List<Note>? notes,
    List<AudioRecording>? audioRecordings,
    bool? hasMoreTopics,
    bool? hasMoreNotes,
    bool? hasMoreAudio,
    dynamic lastTopicDocument,
    dynamic lastNoteDocument,
    dynamic lastAudioDocument,
  }) {
    return TabDataState(
      topics: topics ?? this.topics,
      notes: notes ?? this.notes,
      audioRecordings: audioRecordings ?? this.audioRecordings,
      hasMoreTopics: hasMoreTopics ?? this.hasMoreTopics,
      hasMoreNotes: hasMoreNotes ?? this.hasMoreNotes,
      hasMoreAudio: hasMoreAudio ?? this.hasMoreAudio,
      lastTopicDocument: lastTopicDocument ?? this.lastTopicDocument,
      lastNoteDocument: lastNoteDocument ?? this.lastNoteDocument,
      lastAudioDocument: lastAudioDocument ?? this.lastAudioDocument,
    );
  }
}

final tabDataProvider = StateNotifierProvider.family<TabDataNotifier,
    AsyncValue<TabDataState>, String>(
  (ref, parentTopicId) => TabDataNotifier(ref, parentTopicId),
);

class TabDataNotifier extends StateNotifier<AsyncValue<TabDataState>> {
  final Ref ref;
  final String parentTopicId;

  bool isFetchingTopics = false; // Flag to prevent duplicate loads
  bool isFetchingNotes = false; // Flag to prevent duplicate loads
  bool isFetchingAudio = false; // Flag to prevent duplicate loads

  TabDataNotifier(this.ref, this.parentTopicId)
      : super(const AsyncValue.loading()) {
    loadAllData(parentTopicId);
  }

  Future<void> loadMoreTopics(String topicId) async {
    if (isFetchingTopics) return; // Prevent duplicate fetches
    final currentState = state;
    if (currentState.value == null || !currentState.value!.hasMoreTopics) {
      return;
    }

    final lastDocument = currentState.value!.lastTopicDocument;
    try {
      isFetchingTopics = true; // Set the flag before fetching
      final repository = ref.read(topicRepositoryProvider);
      final result = await repository.fetchSubTopics(topicId, 5, lastDocument);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          Logger().f("loadMoreTopics::: ${paginatedObj.items.toList()}");
          final newTopics = paginatedObj.items
              .where((item) => !currentState.value!.topics
                  .any((topic) => topic.id == item.id))
              .toList();

          state = AsyncValue.data(
            currentState.value!.copyWith(
              topics: [...currentState.value!.topics, ...newTopics],
              hasMoreTopics: paginatedObj.hasMore,
              lastTopicDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      isFetchingTopics = false; // Reset the flag after fetching
    }
  }

  Future<void> loadMoreNotes(String topicId) async {
    if (isFetchingNotes) return; // Prevent duplicate fetches
    final currentState = state;
    if (currentState.value == null || !currentState.value!.hasMoreNotes) return;

    final lastDocument = currentState.value!.lastNoteDocument;
    try {
      isFetchingNotes = true; // Set the flag before fetching
      final repository = ref.read(noteRepositoryProvider);
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
              hasMoreNotes: paginatedObj.hasMore,
              lastNoteDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      isFetchingNotes = false; // Reset the flag after fetching
    }
  }

  Future<void> loadMoreAudio(String topicId) async {
    if (isFetchingAudio) return; // Prevent duplicate fetches
    final currentState = state;
    if (currentState.value == null || !currentState.value!.hasMoreAudio) return;

    final lastDocument = currentState.value!.lastAudioDocument;
    try {
      isFetchingAudio = true; // Set the flag before fetching
      final repository = ref.read(audioRepositoryProvider);
      final result =
          await repository.fetchAudioRecordings(topicId, 5, lastDocument);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          final newAudio = paginatedObj.items
              .where((item) => !currentState.value!.audioRecordings
                  .any((audio) => audio.id == item.id))
              .toList();

          state = AsyncValue.data(
            currentState.value!.copyWith(
              audioRecordings: [
                ...currentState.value!.audioRecordings,
                ...newAudio
              ],
              hasMoreAudio: paginatedObj.hasMore,
              lastAudioDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      isFetchingAudio = false; // Reset the flag after fetching
    }
  }

  Future<void> loadAllData(String parentTopicId) async {
    try {
      final topicRepository = ref.read(topicRepositoryProvider);
      final noteRepository = ref.read(noteRepositoryProvider);
      final audioRepository = ref.read(audioRepositoryProvider);

      final result = await Future.wait([
        topicRepository.fetchSubTopics(parentTopicId, 5, 0),
        noteRepository.fetchNotes(parentTopicId, 5, 0),
        audioRepository.fetchAudioRecordings(parentTopicId, 5, 0),
      ]);

      final topicsResult = result[0];
      final notesResult = result[1];
      final audioResult = result[2];

      topicsResult.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (topicsPaginatedObj) {
          notesResult.fold(
            (failure) =>
                state = AsyncValue.error(failure.message, StackTrace.current),
            (notesPaginatedObj) {
              audioResult.fold(
                (failure) => state =
                    AsyncValue.error(failure.message, StackTrace.current),
                (audioPaginatedObj) {
                  // Cast and filter items to their specific types
                  final List<Topic> topics = topicsPaginatedObj.items
                      .whereType<Topic>() // Cast to Topic
                      .toList();

                  final List<Note> notes = notesPaginatedObj.items
                      .whereType<Note>() // Cast to Note
                      .toList();

                  final List<AudioRecording> audioRecordings =
                      audioPaginatedObj.items
                          .whereType<AudioRecording>() // Cast to AudioRecording
                          .toList();

                  state = AsyncValue.data(TabDataState(
                    topics: topics,
                    notes: notes,
                    audioRecordings: audioRecordings,
                    hasMoreTopics: topicsPaginatedObj.hasMore,
                    hasMoreNotes: notesPaginatedObj.hasMore,
                    hasMoreAudio: audioPaginatedObj.hasMore,
                    lastTopicDocument: topicsPaginatedObj.lastDocument,
                    lastNoteDocument: notesPaginatedObj.lastDocument,
                    lastAudioDocument: audioPaginatedObj.lastDocument,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void updateNote(Note updatedNote) {
    final currentState = state;

    // Return if the state is null or if there is no data yet
    if (currentState.value == null) return;

    List<Note> updatedNoteList;

    // Check if the note to be updated exists in the current state
    if (currentState.value!.notes.any((note) => note.id == updatedNote.id)) {
      // Map over the notes to replace the note with the updated note
      updatedNoteList = currentState.value!.notes
          .map((note) => note.id == updatedNote.id ? updatedNote : note)
          .toList();
    } else {
      // Add the updated note if it doesn't already exist
      updatedNoteList = [updatedNote, ...currentState.value!.notes];
    }

    // Update the state with the new list of notes
    state = AsyncValue.data(
      currentState.value!.copyWith(
        notes: updatedNoteList,
      ),
    );
  }

  void deleteNote(String noteId) {
    final currentState = state;

    // Return if the state is null or if there is no data yet
    if (currentState.value == null) return;

    // Update the state with the new list of notes
    state = AsyncValue.data(currentState.value!.copyWith(
      notes:
          currentState.value!.notes.where((note) => note.id != noteId).toList(),
    ));
  }

  void updateTopic(Topic updatedTopic) {
    final currentState = state;
    if (currentState.value == null) return;

    List<Topic> updatedTopicsList;

    // Check if the note to be updated exists in the current state
    if (currentState.value!.topics
        .any((topic) => topic.id == updatedTopic.id)) {
      // Map over the notes to replace the note with the updated note
      updatedTopicsList = currentState.value!.topics
          .map((topic) => topic.id == updatedTopic.id ? updatedTopic : topic)
          .toList();
    } else {
      // Add the updated note if it doesn't already exist
      updatedTopicsList = [updatedTopic, ...currentState.value!.topics];
    }

    // final updatedTopics = currentState.value!.topics.map((topic) {
    //   return topic.id == updatedTopic.id ? updatedTopic : topic;
    // }).toList();

    state = AsyncValue.data(
      currentState.value!.copyWith(
        topics: updatedTopicsList,
      ),
    );
  }

  void updateAudioRecording(AudioRecording updatedAudio) {
    final currentState = state;
    if (currentState.value == null) return;

    List<AudioRecording> updatedAudioRecordingsList;

    // Check if the note to be updated exists in the current state
    if (currentState.value!.topics
        .any((audio) => audio.id == updatedAudio.id)) {
      // Map over the notes to replace the note with the updated note
      updatedAudioRecordingsList = currentState.value!.audioRecordings
          .map((audio) => audio.id == updatedAudio.id ? updatedAudio : audio)
          .toList();
    } else {
      // Add the updated note if it doesn't already exist
      updatedAudioRecordingsList = [
        updatedAudio,
        ...currentState.value!.audioRecordings
      ];
    }

    state = AsyncValue.data(
      currentState.value!.copyWith(
        audioRecordings: updatedAudioRecordingsList,
      ),
    );
  }

  void deleteAudio(String audioId) {
    final currentState = state;

    // Return if the state is null or if there is no data yet
    if (currentState.value == null) return;

    // Update the state with the new list of notes
    state = AsyncValue.data(currentState.value!.copyWith(
      audioRecordings: currentState.value!.audioRecordings
          .where((audio) => audio.id != audioId)
          .toList(),
    ));
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:study_aid/features/files/presentation/providers/files_providers.dart';

class TabDataState {
  final List<Topic> topics;
  final List<Note> notes;
  final List<AudioRecording> audioRecordings;
  final List<FileEntity> files;
  final bool hasMoreTopics;
  final bool hasMoreNotes;
  final bool hasMoreAudio;
  final bool hasMoreFiles;
  final dynamic lastTopicDocument;
  final dynamic lastNoteDocument;
  final dynamic lastAudioDocument;
  final dynamic lastFileDocument;

  TabDataState({
    required this.topics,
    required this.notes,
    required this.audioRecordings,
    required this.files,
    required this.hasMoreTopics,
    required this.hasMoreNotes,
    required this.hasMoreAudio,
    required this.hasMoreFiles,
    this.lastTopicDocument,
    this.lastNoteDocument,
    this.lastAudioDocument,
    this.lastFileDocument,
  });

  TabDataState copyWith({
    List<Topic>? topics,
    List<Note>? notes,
    List<AudioRecording>? audioRecordings,
    List<FileEntity>? files,
    bool? hasMoreTopics,
    bool? hasMoreNotes,
    bool? hasMoreAudio,
    bool? hasMoreFiles,
    dynamic lastTopicDocument,
    dynamic lastNoteDocument,
    dynamic lastAudioDocument,
    dynamic lastFileDocument,
  }) {
    return TabDataState(
      topics: topics ?? this.topics,
      notes: notes ?? this.notes,
      audioRecordings: audioRecordings ?? this.audioRecordings,
      files: files ?? this.files,
      hasMoreTopics: hasMoreTopics ?? this.hasMoreTopics,
      hasMoreNotes: hasMoreNotes ?? this.hasMoreNotes,
      hasMoreAudio: hasMoreAudio ?? this.hasMoreAudio,
      hasMoreFiles: hasMoreFiles ?? this.hasMoreFiles,
      lastTopicDocument: lastTopicDocument ?? this.lastTopicDocument,
      lastNoteDocument: lastNoteDocument ?? this.lastNoteDocument,
      lastAudioDocument: lastAudioDocument ?? this.lastAudioDocument,
      lastFileDocument: lastFileDocument ?? this.lastFileDocument,
    );
  }
}

class TabDataParams {
  final String parentTopicId;
  final String sortBy;

  TabDataParams(this.parentTopicId, this.sortBy);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabDataParams &&
          runtimeType == other.runtimeType &&
          parentTopicId == other.parentTopicId &&
          sortBy == other.sortBy;

  @override
  int get hashCode => parentTopicId.hashCode ^ sortBy.hashCode;
}

final tabDataProvider = StateNotifierProvider.family<TabDataNotifier,
    AsyncValue<TabDataState>, TabDataParams>(
  (ref, params) => TabDataNotifier(ref, params.parentTopicId, params.sortBy),
);

class TabDataNotifier extends StateNotifier<AsyncValue<TabDataState>> {
  final Ref ref;
  final String parentTopicId;
  final String sortBy;

  bool isFetchingTopics = false; // Flag to prevent duplicate loads
  bool isFetchingNotes = false; // Flag to prevent duplicate loads
  bool isFetchingAudio = false; // Flag to prevent duplicate loads
  bool isFetchingFiles = false; // Flag to prevent duplicate loads

  TabDataNotifier(this.ref, this.parentTopicId, this.sortBy)
      : super(const AsyncValue.loading()) {
    loadAllData(parentTopicId, 0, 0, 0, 0, sortBy);
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
      final result =
          await repository.fetchSubTopics(topicId, 5, lastDocument, sortBy);
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

  Future<List<Note>> loadAllNotes(String topicId) async {
    if (isFetchingNotes) {
      return state.value?.notes ?? [];
    }

    try {
      isFetchingNotes = true;
      final repository = ref.read(noteRepositoryProvider);
      final result = await repository.fetchNotes(topicId, 5, 0, sortBy);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          final refreshedNotes =
              paginatedObj.items.whereType<Note>().toList();
          final current = state.value;

          if (current == null) {
            state = AsyncValue.data(TabDataState(
              topics: const [],
              notes: refreshedNotes,
              audioRecordings: const [],
              files: const [],
              hasMoreTopics: false,
              hasMoreNotes: paginatedObj.hasMore,
              hasMoreAudio: false,
              hasMoreFiles: false,
              lastNoteDocument: paginatedObj.lastDocument,
            ));
          } else {
            state = AsyncValue.data(current.copyWith(
              notes: refreshedNotes,
              hasMoreNotes: paginatedObj.hasMore,
              lastNoteDocument: paginatedObj.lastDocument,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      isFetchingNotes = false;
    }

    while (state.value?.hasMoreNotes ?? false) {
      await loadMoreNotes(topicId);
    }

    return state.value?.notes ?? [];
  }

  Future<void> loadMoreAudio(String topicId) async {
    if (isFetchingAudio) return; // Prevent duplicate fetches
    final currentState = state;
    if (currentState.value == null || !currentState.value!.hasMoreAudio) return;

    final lastDocument = currentState.value!.lastAudioDocument;
    try {
      isFetchingAudio = true; // Set the flag before fetching
      final repository = ref.read(audioRepositoryProvider);
      final result = await repository.fetchAudioRecordings(
          topicId, 5, lastDocument, sortBy);

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

  Future<void> loadMoreFiles(String topicId) async {
    if (isFetchingFiles) return; // Prevent duplicate fetches
    final currentState = state;
    if (currentState.value == null || !currentState.value!.hasMoreFiles) return;

    final lastDocument = currentState.value!.lastFileDocument;
    try {
      isFetchingFiles = true; // Set the flag before fetching
      final repository = ref.read(fileRepositoryProvider);
      final result =
          await repository.fetchFiles(topicId, 5, lastDocument, sortBy);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          final newFiles = paginatedObj.items
              .where((item) =>
                  !currentState.value!.files.any((file) => file.id == item.id))
              .toList();

          state = AsyncValue.data(
            currentState.value!.copyWith(
              files: [...currentState.value!.files, ...newFiles],
              hasMoreFiles: paginatedObj.hasMore,
              lastFileDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      isFetchingFiles = false; // Reset the flag after fetching
    }
  }

  Future<void> loadAllData(String parentTopicId, int startTopic, int startNote,
      int startAudio, int startFile, String sortBy) async {
    try {
      final currentState = state;

      final topicRepository = ref.read(topicRepositoryProvider);
      final noteRepository = ref.read(noteRepositoryProvider);
      final audioRepository = ref.read(audioRepositoryProvider);
      final fileRepository = ref.read(fileRepositoryProvider);

      final result = await Future.wait([
        topicRepository.fetchSubTopics(parentTopicId, 5, startTopic, sortBy),
        noteRepository.fetchNotes(parentTopicId, 5, startNote, sortBy),
        audioRepository.fetchAudioRecordings(
            parentTopicId, 5, startAudio, sortBy),
        fileRepository.fetchFiles(parentTopicId, 5, startFile, sortBy),
      ]);

      final topicsResult = result[0];
      final notesResult = result[1];
      final audioResult = result[2];
      final filesResult = result[3];

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
                  filesResult.fold(
                    (failure) => state =
                        AsyncValue.error(failure.message, StackTrace.current),
                    (filesPaginatedObj) {
                      // Cast and filter items to their specific types
                      final List<Topic> topics = topicsPaginatedObj.items
                          .whereType<Topic>()
                          .toList();

                      final List<Note> notes = notesPaginatedObj.items
                          .whereType<Note>()
                          .toList();

                      final List<AudioRecording> audioRecordings =
                          audioPaginatedObj.items
                              .whereType<AudioRecording>()
                              .toList();

                      final List<FileEntity> files = filesPaginatedObj.items
                          .whereType<FileEntity>()
                          .toList();

                      if (currentState.value == null) {
                        state = AsyncValue.data(TabDataState(
                          topics: topics,
                          notes: notes,
                          audioRecordings: audioRecordings,
                          files: files,
                          hasMoreTopics: topicsPaginatedObj.hasMore,
                          hasMoreNotes: notesPaginatedObj.hasMore,
                          hasMoreAudio: audioPaginatedObj.hasMore,
                          hasMoreFiles: filesPaginatedObj.hasMore,
                          lastTopicDocument: topicsPaginatedObj.lastDocument,
                          lastNoteDocument: notesPaginatedObj.lastDocument,
                          lastAudioDocument: audioPaginatedObj.lastDocument,
                          lastFileDocument: filesPaginatedObj.lastDocument,
                        ));
                      } else {
                        state = AsyncValue.data(
                          currentState.value!.copyWith(
                            topics: [...currentState.value!.topics, ...topics],
                            notes: [...currentState.value!.notes, ...notes],
                            audioRecordings: [
                              ...currentState.value!.audioRecordings,
                              ...audioRecordings
                            ],
                            files: [...currentState.value!.files, ...files],
                            hasMoreTopics: topicsPaginatedObj.hasMore,
                            hasMoreNotes: notesPaginatedObj.hasMore,
                            hasMoreAudio: audioPaginatedObj.hasMore,
                            hasMoreFiles: filesPaginatedObj.hasMore,
                            lastTopicDocument: topicsPaginatedObj.lastDocument,
                            lastNoteDocument: notesPaginatedObj.lastDocument,
                            lastAudioDocument: audioPaginatedObj.lastDocument,
                            lastFileDocument: filesPaginatedObj.lastDocument,
                          ),
                        );
                      }
                    },
                  );
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

  void deleteTopic(String deletedTopicId) {
    final currentState = state;

    // Ensure the current state is not null
    if (currentState.value == null) return;

    // Filter out the topic with the matching ID
    final updatedTopicsList = currentState.value!.topics
        .where((topic) => topic.id != deletedTopicId)
        .toList();

    // Update the state with the modified topics list
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

  void updateFile(FileEntity updatedFile) {
    final currentState = state;
    if (currentState.value == null) return;

    List<FileEntity> updatedFilesList;

    if (currentState.value!.files
        .any((file) => file.id == updatedFile.id)) {
      updatedFilesList = currentState.value!.files
          .map((file) => file.id == updatedFile.id ? updatedFile : file)
          .toList();
    } else {
      updatedFilesList = [updatedFile, ...currentState.value!.files];
    }

    state = AsyncValue.data(
      currentState.value!.copyWith(
        files: updatedFilesList,
      ),
    );
  }

  void deleteFile(String fileId) {
    final currentState = state;
    if (currentState.value == null) return;

    state = AsyncValue.data(currentState.value!.copyWith(
      files: currentState.value!.files
          .where((file) => file.id != fileId)
          .toList(),
    ));
  }

  Future<void> loadAllDataMore(String parentTopicId) async {
    if (isFetchingTopics || isFetchingAudio || isFetchingNotes) return;
    final currentState = state;
    if (currentState.value == null ||
        (!currentState.value!.hasMoreTopics &&
            !currentState.value!.hasMoreNotes &&
            !currentState.value!.hasMoreAudio &&
            !currentState.value!.hasMoreFiles)) return;

    var lastTopic = currentState.value?.lastTopicDocument;
    var lastNote = currentState.value?.lastNoteDocument;
    var lastAudio = currentState.value?.lastAudioDocument;
    var lastFile = currentState.value?.lastFileDocument;

    loadAllData(parentTopicId, lastTopic, lastNote, lastAudio, lastFile, sortBy);
  }
}

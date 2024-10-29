// Provide the SearchNotifier to the widget tree
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
import 'package:study_aid/features/search/data/repositories/search_repository_impl.dart';
import 'package:study_aid/features/search/domain/repositories/search_repository.dart';
import 'package:study_aid/features/search/presentation/notifiers/search_notifier.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final noteRepository = ref.read(noteRepositoryProvider);

  final audioRecordingRepository = ref.read(audioRepositoryProvider);
  return SearchRepositoryImpl(
      noteRepository: noteRepository,
      audioRecordingRepository: audioRecordingRepository);
});

final searchNotifireProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final searchRepository = ref.read(searchRepositoryProvider);
  return SearchNotifier(searchRepository);
});

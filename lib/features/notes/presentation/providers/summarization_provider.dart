import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/services/file_text_extractor_service.dart';
import 'package:study_aid/core/services/summarization_service.dart';
import 'package:study_aid/features/notes/presentation/notifiers/summarization_notifier.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';

final summarizationServiceProvider = Provider<SummarizationService>((ref) {
  return SummarizationService();
});

final fileTextExtractorServiceProvider = Provider<FileTextExtractorService>((ref) {
  return FileTextExtractorService();
});

final summarizationNotifierProvider = StateNotifierProvider.autoDispose<SummarizationNotifier, SummarizationState>((ref) {
  final service = ref.read(summarizationServiceProvider);
  final createNote = ref.read(createNoteProvider);
  return SummarizationNotifier(service, createNote);
});

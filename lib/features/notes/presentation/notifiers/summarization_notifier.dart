import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/services/file_text_extractor_service.dart';
import 'package:study_aid/core/services/summarization_service.dart';
import 'package:study_aid/core/utils/helpers/markdown_to_quill_converter.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/usecases/note.dart';
import 'package:flutter/material.dart';

class SummarizationState {
  final bool isLoading;
  final String statusMessage;
  final String accumulatedSummary;
  final bool isError;
  final bool isSuccess;
  final Note? createdNote; // Added field

  SummarizationState({
    this.isLoading = false,
    this.statusMessage = '',
    this.accumulatedSummary = '',
    this.isError = false,
    this.isSuccess = false,
    this.createdNote,
  });

  SummarizationState copyWith({
    bool? isLoading,
    String? statusMessage,
    String? accumulatedSummary,
    bool? isError,
    bool? isSuccess,
    Note? createdNote,
  }) {
    return SummarizationState(
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
      accumulatedSummary: accumulatedSummary ?? this.accumulatedSummary,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
      createdNote: createdNote ?? this.createdNote,
    );
  }
}

class SummarizationNotifier extends StateNotifier<SummarizationState> {
  final SummarizationService _service;
  final FileTextExtractorService _extractor;
  final CreateNote _createNote;

  SummarizationNotifier(this._service, this._extractor, this._createNote) : super(SummarizationState());

  Future<void> extractAndSummarize({
    required String fileUrl,
    required String fileType,
    required String topicId,
    required String userId,
    String? title,
    Color? noteColor,
  }) async {
    state = state.copyWith(isLoading: true, statusMessage: 'Extracting text from file...', isError: false, isSuccess: false);
    
    try {
      final text = await _extractor.extractText(fileUrl, fileType);
      
      if (text.isEmpty) {
        state = state.copyWith(
          isLoading: false, 
          isError: true, 
          statusMessage: 'Could not extract any text from this file.'
        );
        return;
      }
      
      // Proceed to summarization
      await summarizeAndSave(
        content: text,
        topicId: topicId,
        userId: userId,
        title: title,
        noteColor: noteColor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        isError: true, 
        statusMessage: 'Extraction failed: ${e.toString().replaceAll("Exception: ", "")}'
      );
    }
  }

  Future<void> summarizeAndSave({
    required String content,
    required String topicId,
    required String userId,
    String? title,
    Color? noteColor,
  }) async {
    state = state.copyWith(isLoading: true, statusMessage: 'Starting summarization...', isError: false, isSuccess: false, accumulatedSummary: '', createdNote: null);
    
    try {
      final stream = await _service.summarizeText(content);
      
      await for (final update in stream) {
        if (update.isError) {
          state = state.copyWith(
            isLoading: false, 
            isError: true, 
            statusMessage: update.statusMessage
          );
          return;
        }
        
        String newSummary = state.accumulatedSummary;
        if (update.isSummary && update.partialSummary != null) {
          newSummary += (newSummary.isEmpty ? '' : '\n\n') + update.partialSummary!;
        }

        state = state.copyWith(
          statusMessage: update.statusMessage,
          accumulatedSummary: newSummary,
        );
      }
      
      // Done summarizing, now save
      if (state.accumulatedSummary.isEmpty) {
        state = state.copyWith(isLoading: false, isError: true, statusMessage: 'No summary generated.');
        return;
      }

      state = state.copyWith(statusMessage: 'Saving note...');
      
      final now = DateTime.now();
      

      
      // Convert markdown to Quill format and extract metadata
      final conversionResult = MarkdownToQuillConverter.convert(state.accumulatedSummary);
      
      // Determine title: User provided > Extracted from Markdown > Default timestamp
      String noteTitle = title ?? conversionResult.title;
      if (noteTitle.isEmpty || noteTitle == 'Summary') {
        noteTitle = title ?? 'Summary ${now.toString().split('.')[0]}';
      }

      final note = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: noteTitle,
        color: noteColor ?? const Color(0xFFFFFFFF), // Use provided color or default white
        tags: ['summary', 'ai'],
        createdDate: now,
        updatedDate: now,
        content: conversionResult.plainContent, // Store plain text for previews
        contentJson: conversionResult.contentJson, // Store formatted Quill Delta
        syncStatus: 'pending',
        localChangeTimestamp: now,
        remoteChangeTimestamp: now,
        parentId: topicId,
        titleLowerCase: noteTitle.toLowerCase(),
        userId: userId,
      );

      
      final result = await _createNote(note, topicId, userId);
      
      result.fold(
        (failure) => state = state.copyWith(
          isError: true, 
          isLoading: false, 
          statusMessage: 'Failed to save note: ${failure.message}'
        ),
        (success) => state = state.copyWith(
          isSuccess: true, 
          isLoading: false, 
          statusMessage: 'Summary saved successfully!',
          createdNote: note, // Store the created note
        ),
      );
      
    } catch (e) {
       state = state.copyWith(
         isError: true, 
         isLoading: false, 
         statusMessage: 'An unexpected error occurred: $e'
       );
    }
  }
  
  void reset() {
    state = SummarizationState();
  }
}

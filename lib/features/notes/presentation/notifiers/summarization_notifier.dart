import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/services/summarization_service.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/usecases/note.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart'; // For BaseEntity if needed
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
  final CreateNote _createNote;

  SummarizationNotifier(this._service, this._createNote) : super(SummarizationState());

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
      
      // Properly escape the summary for JSON (Quill delta format)
      final escapedSummary = state.accumulatedSummary
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r')
          .replaceAll('\t', '\\t');
      
      final note = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: title ?? 'Summary ${now.toString().split('.')[0]}',
        color: noteColor ?? const Color(0xFFFFFFFF), // Use provided color or default white
        tags: ['summary', 'ai'],
        createdDate: now,
        updatedDate: now,
        content: state.accumulatedSummary,
        contentJson: '[{"insert":"$escapedSummary\\n"}]', // Properly escaped Quill delta
        syncStatus: 'pending',
        localChangeTimestamp: now,
        remoteChangeTimestamp: now,
        parentId: topicId,
        titleLowerCase: (title ?? 'summary').toLowerCase(),
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

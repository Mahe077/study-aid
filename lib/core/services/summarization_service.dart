import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../config/open_ai_config.dart';

/// ----------------------------
/// MODELS
/// ----------------------------
class SummarizationUpdate {
  final String statusMessage;
  final String? partialSummary;
  final bool isSummary;
  final bool isError;

  SummarizationUpdate({
    required this.statusMessage,
    this.partialSummary,
    this.isSummary = false,
    this.isError = false,
  });
}

/// ----------------------------
/// SERVICE - Text Summarization
/// Uses OpenAI GPT API for high-quality summaries
/// Handles large texts by chunking
/// ----------------------------
class SummarizationService {
  final Logger _logger = Logger();

  // OpenAI has a context limit, we'll chunk at ~12k chars to leave room for response
  static const int _maxCharsPerChunk = 12000;

  /// Public API
  Stream<SummarizationUpdate> summarizeText(String text) async* {
    yield* _processJob(text);
  }

  /// ----------------------------
  /// CORE FLOW
  /// ----------------------------
  Stream<SummarizationUpdate> _processJob(String text) async* {
    // Clean control characters
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

    if (text.trim().isEmpty) {
      yield SummarizationUpdate(
        statusMessage: 'Text is empty.',
        isError: true,
      );
      return;
    }

    try {
      // Split text into chunks if needed
      final chunks = _splitTextIntoChunks(text);

      _logger.i('Text split into ${chunks.length} chunk(s)');

      final summaries = <String>[];

      for (int i = 0; i < chunks.length; i++) {
        yield SummarizationUpdate(
          statusMessage: 'Summarizing part ${i + 1} of ${chunks.length}...',
        );

        final chunkSummary = await _summarizeChunk(chunks[i], i + 1, chunks.length);
        
        if (chunkSummary != null && chunkSummary.isNotEmpty) {
          summaries.add(chunkSummary);

          yield SummarizationUpdate(
            statusMessage: 'Part ${i + 1} complete.',
            partialSummary: chunkSummary,
            isSummary: true,
          );
        }
      }

      if (summaries.isEmpty) {
        throw Exception('No summary could be generated.');
      }

      // If we had multiple chunks, create a final combined summary
      if (summaries.length > 1) {
        yield SummarizationUpdate(
          statusMessage: 'Creating final summary...',
        );

        final combinedText = summaries.join('\n\n');
        final finalSummary = await _summarizeChunk(
          combinedText, 
          1, 
          1,
          isFinalSummary: true,
        );

        if (finalSummary != null && finalSummary.isNotEmpty) {
          yield SummarizationUpdate(
            statusMessage: 'Final summary complete.',
            partialSummary: finalSummary,
            isSummary: true,
          );
        }
      }

      yield SummarizationUpdate(
        statusMessage: 'Summarization complete.',
      );
    } catch (e, st) {
      _logger.e(e.toString(), stackTrace: st);
      yield SummarizationUpdate(
        statusMessage: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    }
  }

  /// Split text into manageable chunks
  List<String> _splitTextIntoChunks(String text) {
    if (text.length <= _maxCharsPerChunk) {
      return [text];
    }

    final chunks = <String>[];
    int start = 0;

    while (start < text.length) {
      int end = start + _maxCharsPerChunk;
      
      if (end >= text.length) {
        end = text.length;
      } else {
        // Try to break at a sentence or paragraph boundary
        final searchStart = (end - 500).clamp(start, end);
        final searchText = text.substring(searchStart, end);
        
        // Look for paragraph break first
        int breakPoint = searchText.lastIndexOf('\n\n');
        if (breakPoint == -1) {
          // Look for sentence break
          breakPoint = searchText.lastIndexOf('. ');
          if (breakPoint != -1) breakPoint += 1; // Include the period
        }
        
        if (breakPoint != -1 && breakPoint > 0) {
          end = searchStart + breakPoint + 1;
        }
      }

      final chunk = text.substring(start, end).trim();
      if (chunk.isNotEmpty) {
        chunks.add(chunk);
      }
      start = end;
    }

    return chunks;
  }

  /// Summarize a single chunk using OpenAI
  Future<String?> _summarizeChunk(
    String text, 
    int partNumber, 
    int totalParts, {
    bool isFinalSummary = false,
  }) async {
    final systemPrompt = isFinalSummary
        ? '''You are an expert summarizer. You are given multiple summaries from different parts of a document. 
Create a cohesive, comprehensive final summary that captures all the key points.
Write in clear, well-structured paragraphs. Use bullet points for lists of key concepts if appropriate.
The summary should be detailed enough to be useful for studying.'''
        : '''You are an expert summarizer for educational content. 
Summarize the following text, capturing all key concepts, definitions, and important details.
Write in clear, well-structured paragraphs. Use bullet points for lists of key concepts if appropriate.
The summary should be detailed enough to be useful for studying.
${totalParts > 1 ? "This is part $partNumber of $totalParts parts of a larger document." : ""}''';

    final body = {
      "model": OpenAIConfig.model,
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": "Please summarize the following text:\n\n$text"}
      ],
      "temperature": 0.3,
      "max_tokens": 2000,
    };

    _logger.i('Sending request to OpenAI (${text.length} chars)...');

    final response = await http.post(
      Uri.parse(OpenAIConfig.apiEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
      },
      body: jsonEncode(body),
    );

    _logger.d('OpenAI response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      
      if (content != null) {
        _logger.i('Summary generated successfully (${content.length} chars)');
        return content.trim();
      }
      
      throw Exception('Empty response from OpenAI');
    }

    // Handle errors
    _logger.e('OpenAI API error: ${response.statusCode} - ${response.body}');
    
    final error = jsonDecode(response.body);
    final errorMessage = error['error']?['message'] ?? 'Request failed';
    
    if (response.statusCode == 401) {
      _logger.e('Invalid OpenAI API key. Please check your configuration.');
      throw Exception('Please try again later.');
    } else if (response.statusCode == 429) {
      _logger.e('Rate limit exceeded. Please try again later.');
      throw Exception('Please try again later.');
    } else if (response.statusCode == 503) {
      throw Exception('OpenAI service temporarily unavailable. Please try again.');
    }
    
    throw Exception(errorMessage);
  }
}


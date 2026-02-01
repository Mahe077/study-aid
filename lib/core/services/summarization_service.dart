import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../config/azure_config.dart';

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
/// Uses Azure Language Service Text Analytics API
/// Handles large texts by chunking
/// ----------------------------
class SummarizationService {
  final Logger _logger = Logger();

  // Azure limit: 125KB per request, ~40k chars per doc is safe
  static const int _maxCharsPerDoc = 40000;
  static const int _docsPerBatch = 2;

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
      // Split text into chunks
      final chunks = _splitTextIntoChunks(text);
      final batches = _createBatches(chunks);

      _logger.i('Text split into ${chunks.length} chunks, ${batches.length} batches');

      final summaries = <String>[];

      for (int i = 0; i < batches.length; i++) {
        yield SummarizationUpdate(
          statusMessage: 'Processing part ${i + 1} of ${batches.length}...',
        );

        final batchSummary = await _processBatch(batches[i]);
        if (batchSummary != null && batchSummary.isNotEmpty) {
          summaries.add(batchSummary);

          yield SummarizationUpdate(
            statusMessage: 'Part ${i + 1} complete.',
            partialSummary: batchSummary,
            isSummary: true,
          );
        }
      }

      if (summaries.isEmpty) {
        throw Exception('No summary could be generated.');
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
    final chunks = <String>[];
    int start = 0;

    while (start < text.length) {
      int end = start + _maxCharsPerDoc;
      if (end >= text.length) {
        end = text.length;
      } else {
        // Avoid splitting in middle of surrogate pair
        if (text.codeUnitAt(end - 1) >= 0xD800 &&
            text.codeUnitAt(end - 1) <= 0xDBFF) {
          end--;
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

  /// Create batches of documents for API calls
  List<List<Map<String, String>>> _createBatches(List<String> chunks) {
    final allDocs = <Map<String, String>>[];

    for (int i = 0; i < chunks.length; i++) {
      allDocs.add({
        'id': '${i + 1}',
        'language': 'en',
        'text': chunks[i],
      });
    }

    final batches = <List<Map<String, String>>>[];
    for (int i = 0; i < allDocs.length; i += _docsPerBatch) {
      final end = (i + _docsPerBatch > allDocs.length)
          ? allDocs.length
          : i + _docsPerBatch;
      batches.add(allDocs.sublist(i, end));
    }

    return batches;
  }

  /// Process a single batch
  Future<String?> _processBatch(List<Map<String, String>> documents) async {
    final operationLocation = await _submitJob(documents);
    if (operationLocation == null) {
      throw Exception('Failed to submit batch.');
    }

    // Poll for results
    int pollCount = 0;
    const maxPolls = 60;

    while (pollCount < maxPolls) {
      await Future.delayed(const Duration(seconds: 2));

      final pollResponse = await _pollJob(operationLocation);
      final status = pollResponse['status'];

      _logger.i('Poll status: $status');

      if (status == 'succeeded') {
        return _extractSummaryFromResponse(pollResponse);
      }

      if (status == 'failed') {
        final errors = pollResponse['errors'] as List?;
        final errorMsg = errors?.isNotEmpty == true
            ? errors!.first['message'] ?? 'Batch failed.'
            : 'Batch failed.';
        throw Exception(errorMsg);
      }

      pollCount++;
    }

    throw Exception('Batch timed out.');
  }

  /// ----------------------------
  /// AZURE API CALLS
  /// ----------------------------

  /// Submit summarization job
  Future<String?> _submitJob(List<Map<String, String>> documents) async {
    final url = Uri.parse(
        '${AzureConfig.languageResourceEndpoint}language/analyze-text/jobs?api-version=2023-04-01');

    final body = {
      "displayName": "StudyAid Summarization",
      "analysisInput": {"documents": documents},
      "tasks": [
        {
          "kind": "AbstractiveSummarization",
          "taskName": "abstractiveSummary",
          "parameters": {"summaryLength": "long"}
        }
      ]
    };

    _logger.i('Submitting batch with ${documents.length} documents');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': AzureConfig.languageResourceKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      final operationLocation = response.headers['operation-location'];
      _logger.i('Job submitted: $operationLocation');
      return operationLocation;
    }

    _logger.e('Azure API error: ${response.statusCode} - ${response.body}');
    final error = jsonDecode(response.body);
    throw Exception(
      error['error']?['message'] ?? 'Request failed (${response.statusCode})',
    );
  }

  /// Poll job status
  Future<Map<String, dynamic>> _pollJob(String operationLocation) async {
    final response = await http.get(
      Uri.parse(operationLocation),
      headers: {
        'Ocp-Apim-Subscription-Key': AzureConfig.languageResourceKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Polling failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Extract summary from response
  String? _extractSummaryFromResponse(Map<String, dynamic> response) {
    try {
      final tasks = response['tasks'];
      if (tasks == null) return null;

      final items = tasks['items'] as List?;
      if (items == null || items.isEmpty) return null;

      final results = items.first['results'];
      if (results == null) return null;

      final documents = results['documents'] as List?;
      if (documents == null || documents.isEmpty) return null;

       // Sort by document ID and combine summaries
      final sortedDocs = List<dynamic>.from(documents);
      sortedDocs.sort(
          (a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));

      final allSummaries = <String>[];
      for (final doc in sortedDocs) {
        final summaries = doc['summaries'] as List?;
        if (summaries != null) {
          for (final s in summaries) {
            allSummaries.add(s['text'] as String);
          }
        }
      }

      return allSummaries.isNotEmpty ? allSummaries.join(' ') : null;
    } catch (e) {
      _logger.e('Error extracting summary: $e');
      return null;
    }
  }
}

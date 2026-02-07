import 'package:study_aid/core/config/openai_config.dart';
import 'package:study_aid/features/notes/domain/models/tts_chunk.dart';

/// Service for chunking large text into TTS-friendly segments
class TextChunker {
  /// Splits text into chunks suitable for TTS processing
  /// Preserves sentence and paragraph boundaries
  List<TtsChunk> chunkText({
    required String title,
    required String content,
    int maxCharsPerChunk = OpenAIConfig.maxCharsPerChunk,
  }) {
    // Normalize and validate input
    final normalizedTitle = normalizeTitle(title);
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      // Return single chunk with just the title
      return [
        TtsChunk(
          index: 0,
          text: '',
          isFirst: true,
        ),
      ];
    }

    // Split content by paragraphs first
    final paragraphs = trimmedContent.split(RegExp(r'\n\s*\n'));
    final chunks = <TtsChunk>[];
    StringBuffer currentChunk = StringBuffer();
    int chunkIndex = 0;

    for (final paragraph in paragraphs) {
      final trimmedParagraph = paragraph.trim();
      if (trimmedParagraph.isEmpty) continue;

      // Check if adding this paragraph would exceed limit
      final potentialLength = currentChunk.length + trimmedParagraph.length + 2;

      if (potentialLength <= maxCharsPerChunk) {
        // Fits in current chunk
        if (currentChunk.isNotEmpty) {
          currentChunk.write('\n\n');
        }
        currentChunk.write(trimmedParagraph);
      } else {
        // Save current chunk if not empty
        if (currentChunk.isNotEmpty) {
          chunks.add(TtsChunk(
            index: chunkIndex++,
            text: currentChunk.toString(),
            isFirst: chunkIndex == 0,
          ));
          currentChunk.clear();
        }

        // If paragraph itself is too long, split by sentences
        if (trimmedParagraph.length > maxCharsPerChunk) {
          final sentenceChunks = _splitLongParagraph(
            trimmedParagraph,
            maxCharsPerChunk,
          );
          for (final sentenceChunk in sentenceChunks) {
            chunks.add(TtsChunk(
              index: chunkIndex++,
              text: sentenceChunk,
              isFirst: chunkIndex == 0,
            ));
          }
        } else {
          // Paragraph fits in a new chunk
          currentChunk.write(trimmedParagraph);
        }
      }
    }

    // Add remaining content
    if (currentChunk.isNotEmpty) {
      chunks.add(TtsChunk(
        index: chunkIndex,
        text: currentChunk.toString(),
        isFirst: chunkIndex == 0,
      ));
    }

    // Ensure at least one chunk exists
    if (chunks.isEmpty) {
      chunks.add(TtsChunk(
        index: 0,
        text: trimmedContent,
        isFirst: true,
      ));
    }

    return chunks;
  }

  /// Normalizes title for TTS
  /// - Removes special characters except letters, numbers, spaces, and basic punctuation
  /// - Collapses multiple spaces
  /// - Trims leading/trailing spaces
  String normalizeTitle(String title) {
    // Remove special characters but keep basic punctuation
    String normalized = title.replaceAll(
      RegExp(r'[^\w\s.,!?:;\-]', unicode: true),
      '',
    );

    // Collapse multiple spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Trim
    normalized = normalized.trim();

    return normalized;
  }

  /// Splits a long paragraph into smaller chunks by sentences
  List<String> _splitLongParagraph(String paragraph, int maxChars) {
    // Split by sentence endings
    final sentences = paragraph.split(RegExp(r'(?<=[.!?])\s+'));
    final chunks = <String>[];
    StringBuffer currentChunk = StringBuffer();

    for (final sentence in sentences) {
      final potentialLength = currentChunk.length + sentence.length + 1;

      if (potentialLength <= maxChars) {
        if (currentChunk.isNotEmpty) {
          currentChunk.write(' ');
        }
        currentChunk.write(sentence);
      } else {
        // Save current chunk
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.toString());
          currentChunk.clear();
        }

        // If single sentence is too long, force split by words
        if (sentence.length > maxChars) {
          chunks.addAll(_splitByWords(sentence, maxChars));
        } else {
          currentChunk.write(sentence);
        }
      }
    }

    // Add remaining content
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.toString());
    }

    return chunks;
  }

  /// Last resort: splits text by words if a single sentence is too long
  List<String> _splitByWords(String text, int maxChars) {
    final words = text.split(RegExp(r'\s+'));
    final chunks = <String>[];
    StringBuffer currentChunk = StringBuffer();

    for (final word in words) {
      final potentialLength = currentChunk.length + word.length + 1;

      if (potentialLength <= maxChars) {
        if (currentChunk.isNotEmpty) {
          currentChunk.write(' ');
        }
        currentChunk.write(word);
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.toString());
          currentChunk.clear();
        }
        currentChunk.write(word);
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.toString());
    }

    return chunks;
  }
}

/// Represents a chunk of text to be converted to speech
class TtsChunk {
  final int index;
  final String text;
  final bool isFirst;

  TtsChunk({
    required this.index,
    required this.text,
    required this.isFirst,
  });

  /// Formats the text for TTS input
  /// For the first chunk, prepends the normalized title
  String getFormattedText(String normalizedTitle) {
    if (isFirst) {
      // Add title with a period for natural pause, then content
      return '$normalizedTitle.\n\n$text';
    }
    return text;
  }

  @override
  String toString() => 'TtsChunk(index: $index, isFirst: $isFirst, textLength: ${text.length})';
}

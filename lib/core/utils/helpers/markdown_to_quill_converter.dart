import 'dart:convert';

/// Utility to convert markdown text to Quill Delta format
/// and extract metadata like title from the markdown content
class MarkdownToQuillConverter {
  
  /// Result of converting markdown to note format
  static ({String title, String contentJson, String plainContent}) convert(String markdown) {
    final title = _extractTitle(markdown);
    final contentJson = _markdownToQuillDelta(markdown);
    final plainContent = _stripMarkdown(markdown);
    
    return (
      title: title,
      contentJson: contentJson,
      plainContent: plainContent,
    );
  }

  /// Extract title from the first heading in markdown
  static String _extractTitle(String markdown) {
    final lines = markdown.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // Match markdown headings (# to ######)
      final headingMatch = RegExp(r'^#{1,6}\s+(.+)$').firstMatch(trimmed);
      if (headingMatch != null) {
        String title = headingMatch.group(1) ?? '';
        // Remove any trailing markdown formatting
        title = title.replaceAll(RegExp(r'\*+'), '').trim();
        // Limit title length
        if (title.length > 100) {
          title = '${title.substring(0, 97)}...';
        }
        return title;
      }
      
      // Also check for bold text at the start as potential title
      final boldMatch = RegExp(r'^\*\*(.+?)\*\*').firstMatch(trimmed);
      if (boldMatch != null && trimmed == boldMatch.group(0)) {
        String title = boldMatch.group(1) ?? '';
        if (title.length > 100) {
          title = '${title.substring(0, 97)}...';
        }
        return title;
      }
    }
    
    // Fallback: use first non-empty line
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        String title = trimmed.replaceAll(RegExp(r'[#*_`]'), '').trim();
        if (title.length > 100) {
          title = '${title.substring(0, 97)}...';
        }
        return title;
      }
    }
    
    return 'Summary';
  }

  /// Convert markdown to Quill Delta JSON format
  static String _markdownToQuillDelta(String markdown) {
    final List<Map<String, dynamic>> delta = [];
    final lines = markdown.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Check for headings
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final text = headingMatch.group(2)!;
        
        // Add heading text with bold formatting
        _addFormattedText(delta, text, bold: true);
        delta.add({'insert': '\n', 'attributes': {'header': level}});
        continue;
      }
      
      // Check for bullet points
      if (line.trimLeft().startsWith('- ') || line.trimLeft().startsWith('* ')) {
        final indent = (line.length - line.trimLeft().length) ~/ 2;
        final text = line.trimLeft().substring(2);
        
        _addFormattedText(delta, text);
        final listAttr = <String, dynamic>{'list': 'bullet'};
        if (indent > 0) {
          listAttr['indent'] = indent;
        }
        delta.add({'insert': '\n', 'attributes': listAttr});
        continue;
      }
      
      // Check for numbered lists
      final numberedMatch = RegExp(r'^\s*(\d+)\.\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        final text = numberedMatch.group(2)!;
        
        _addFormattedText(delta, text);
        delta.add({'insert': '\n', 'attributes': {'list': 'ordered'}});
        continue;
      }
      
      // Regular paragraph text
      if (line.trim().isNotEmpty) {
        _addFormattedText(delta, line);
        delta.add({'insert': '\n'});
      } else if (i < lines.length - 1) {
        // Empty line - add a newline for spacing
        delta.add({'insert': '\n'});
      }
    }
    
    // Ensure we end with a newline (Quill requirement)
    if (delta.isEmpty || delta.last['insert'] != '\n') {
      delta.add({'insert': '\n'});
    }
    
    return jsonEncode(delta);
  }

  /// Add text with inline formatting (bold, italic) to delta
  static void _addFormattedText(List<Map<String, dynamic>> delta, String text, {bool bold = false}) {
    // Process inline formatting
    final segments = _parseInlineFormatting(text);
    
    for (final segment in segments) {
      final attributes = <String, dynamic>{};
      
      if (bold || segment.bold) {
        attributes['bold'] = true;
      }
      if (segment.italic) {
        attributes['italic'] = true;
      }
      if (segment.code) {
        attributes['code'] = true;
      }
      
      if (attributes.isEmpty) {
        delta.add({'insert': segment.text});
      } else {
        delta.add({'insert': segment.text, 'attributes': attributes});
      }
    }
  }

  /// Parse inline markdown formatting (bold, italic, code)
  static List<_TextSegment> _parseInlineFormatting(String text) {
    final segments = <_TextSegment>[];
    
    // Simple regex-based parsing
    final pattern = RegExp(
      r'(\*\*\*(.+?)\*\*\*)|'  // Bold italic ***text***
      r'(\*\*(.+?)\*\*)|'      // Bold **text**
      r'(\*(.+?)\*)|'          // Italic *text*
      r'(`(.+?)`)|'            // Code `text`
      r'([^*`]+)',             // Plain text
    );
    
    final matches = pattern.allMatches(text);
    
    for (final match in matches) {
      if (match.group(2) != null) {
        // Bold italic
        segments.add(_TextSegment(match.group(2)!, bold: true, italic: true));
      } else if (match.group(4) != null) {
        // Bold
        segments.add(_TextSegment(match.group(4)!, bold: true));
      } else if (match.group(6) != null) {
        // Italic
        segments.add(_TextSegment(match.group(6)!, italic: true));
      } else if (match.group(8) != null) {
        // Code
        segments.add(_TextSegment(match.group(8)!, code: true));
      } else if (match.group(9) != null) {
        // Plain text
        segments.add(_TextSegment(match.group(9)!));
      }
    }
    
    // If no segments found, return original text
    if (segments.isEmpty && text.isNotEmpty) {
      segments.add(_TextSegment(text));
    }
    
    return segments;
  }

  /// Strip markdown formatting for plain text version
  static String _stripMarkdown(String markdown) {
    String text = markdown;
    
    // Remove headings markers
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remove bold/italic markers
    text = text.replaceAll(RegExp(r'\*\*\*(.+?)\*\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*(.+?)\*'), r'$1');
    
    // Remove code markers
    text = text.replaceAll(RegExp(r'`(.+?)`'), r'$1');
    
    // Remove bullet point markers
    text = text.replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '• ');
    
    return text.trim();
  }
}

class _TextSegment {
  final String text;
  final bool bold;
  final bool italic;
  final bool code;
  
  _TextSegment(this.text, {this.bold = false, this.italic = false, this.code = false});
}

import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AudioFileUtils {
  /// Fixes the audio file path for playback by ensuring it has a compatible extension.
  /// 
  /// iOS Audio Players often fail to play MPEG4 audio if it has an .aac extension.
  /// This method checks if the file is an .aac file and attempts to create a 
  /// temporary .m4a copy for playback.
  static Future<String?> getCompatibleAudioPath(String? originalPath) async {
    if (originalPath == null) return null;

    // Optimization: Android handles .aac (MPEG4) files fine. 
    // Only iOS/macOS (AVFoundation) are strict about the extension matching the container.
    if (!Platform.isIOS && !Platform.isMacOS) {
      return originalPath;
    }
    
    // If it's not an AAC file, return as is.
    if (!originalPath.toLowerCase().endsWith('.aac')) {
      return originalPath;
    }

    final File originalFile = File(originalPath);
    if (!await originalFile.exists()) {
      return originalPath; // Let the caller handle existence check failure
    }

    try {
      // Create a temp file path with .m4a extension
      final String tempDir = (await getTemporaryDirectory()).path;
      final String fileName = p.basenameWithoutExtension(originalPath);
      final String tempPath = p.join(tempDir, '${fileName}_temp.m4a');
      final File tempFile = File(tempPath);

      // Check if we already created the temp file to avoid redundant copying
      if (await tempFile.exists()) {
        // Optional: Check if temp file is newer or same size? 
        // For simplicity, assume it's valid if it exists. 
        // To be safe against stale files, we could check modification time.
        final originalStat = await originalFile.stat();
        final tempStat = await tempFile.stat();
        if (tempStat.modified.isAfter(originalStat.modified)) {
             return tempPath;
        }
      }

      // Copy the file
      await originalFile.copy(tempPath);
      Logger().i('Created compatible audio copy: $tempPath');
      return tempPath;
    } catch (e) {
      Logger().e('Failed to create compatible audio copy: $e');
      return originalPath; // Fallback to original
    }
  }
}

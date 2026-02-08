import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service for managing cached TTS audio files
class AudioCacheService {
  static const int maxCacheSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const Duration cacheTtl = Duration(days: 7); // 7 days

  /// Gets cached audio file path if it exists and is valid
  Future<String?> getCachedAudio({
    required String noteId,
    required int chunkIndex,
    required String voice,
    required double speed,
    String? contentHash,
  }) async {
    final cacheKey =
        _generateCacheKey(noteId, chunkIndex, voice, speed, contentHash);
    final file = await _getCacheFile(cacheKey);

    if (await file.exists()) {
      // Check if file is within TTL
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);

      if (age < cacheTtl) {
        return file.path;
      } else {
        // File is too old, delete it
        await file.delete();
      }
    }

    return null;
  }

  /// Clears cache for a specific note
  Future<void> clearNoteCache(String noteId) async {
    final directory = await _getCacheDirectory();
    final files = await directory.list().toList();

    for (final entity in files) {
      if (entity is File && entity.path.contains(noteId)) {
        await entity.delete();
      }
    }
  }

  /// Clears all cached audio files
  Future<void> clearAllCache() async {
    final directory = await _getCacheDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create(recursive: true);
    }
  }

  /// Clears cache if it exceeds the size limit using LRU strategy
  Future<void> evictOldCacheIfNeeded() async {
    final directory = await _getCacheDirectory();
    if (!await directory.exists()) return;

    // Get all files with their stats
    final files = <File, FileStat>{};
    await for (final entity in directory.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        files[entity] = stat;
      }
    }

    // Calculate total size
    int totalSize = files.values.fold(0, (sum, stat) => sum + stat.size);

    if (totalSize <= maxCacheSizeBytes) return;

    // Sort files by last modified (oldest first)
    final sortedFiles = files.entries.toList()
      ..sort((a, b) => a.value.modified.compareTo(b.value.modified));

    // Delete oldest files until under limit
    for (final entry in sortedFiles) {
      if (totalSize <= maxCacheSizeBytes * 0.8) break; // Keep 20% buffer

      await entry.key.delete();
      totalSize -= entry.value.size;
    }
  }

  /// Gets the size of the cache in bytes
  Future<int> getCacheSize() async {
    final directory = await _getCacheDirectory();
    if (!await directory.exists()) return 0;

    int totalSize = 0;
    await for (final entity in directory.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }

    return totalSize;
  }

  /// Generates a cache key for the given parameters
  String _generateCacheKey(
    String noteId,
    int chunkIndex,
    String voice,
    double speed,
    String? contentHash,
  ) {
    final speedStr = speed.toStringAsFixed(1);
    final hashPart = (contentHash == null || contentHash.isEmpty)
        ? ''
        : '_$contentHash';
    return '${noteId}_${chunkIndex}_${voice}_$speedStr$hashPart.mp3';
  }

  /// Gets the cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/tts_cache');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Gets a cache file for the given cache key
  Future<File> _getCacheFile(String cacheKey) async {
    final directory = await _getCacheDirectory();
    return File('${directory.path}/$cacheKey');
  }
}

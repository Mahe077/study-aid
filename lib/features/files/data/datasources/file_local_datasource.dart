import 'package:hive/hive.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/features/files/data/models/file_model.dart';

abstract class FileLocalDataSource {
  Future<void> createFile(FileModel file);
  Future<void> updateFile(FileModel file);
  Future<void> deleteFile(String fileId);
  Future<FileModel?> getCachedFile(String fileId);
  Future<List<FileModel>> fetchAllFiles();
  Future<List<FileModel>> searchFromLocal(String query);
  bool fileExists(String fileId);
}

class FileLocalDataSourceImpl extends FileLocalDataSource {
  final Box<FileModel> fileBox;

  FileLocalDataSourceImpl(this.fileBox);

  @override
  Future<void> createFile(FileModel file) async {
    try {
      await fileBox.put(file.id, file);
    } catch (e) {
      throw CacheException('Failed to cache file: $e');
    }
  }

  @override
  Future<void> deleteFile(String fileId) async {
    try {
      await fileBox.delete(fileId);
    } catch (e) {
      throw CacheException('Failed to delete file from cache: $e');
    }
  }

  @override
  Future<List<FileModel>> fetchAllFiles() async {
    try {
      return fileBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to fetch files from cache: $e');
    }
  }

  @override
  Future<FileModel?> getCachedFile(String fileId) async {
    try {
      return fileBox.get(fileId);
    } catch (e) {
      throw CacheException('Failed to get file from cache: $e');
    }
  }

  @override
  Future<List<FileModel>> searchFromLocal(String query) async {
    try {
      query = query.toLowerCase();
      return fileBox.values
          .where((file) => file.fileName.toLowerCase().contains(query))
          .toList();
    } catch (e) {
      throw CacheException('Failed to search files: $e');
    }
  }

  @override
  Future<void> updateFile(FileModel file) async {
    try {
      await fileBox.put(file.id, file);
    } catch (e) {
      throw CacheException('Failed to update file in cache: $e');
    }
  }

  @override
  bool fileExists(String fileId) {
    return fileBox.containsKey(fileId);
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileLocalCacheService {
  static const String _keyPrefix = 'file_local_path_';

  Future<String?> getLocalPath(String fileId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix$fileId');
  }

  Future<void> saveLocalCopy({
    required String fileId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/files_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final file = File('${cacheDir.path}/${fileId}_$safeName');
    await file.writeAsBytes(bytes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$fileId', file.path);
  }

  Future<bool> localFileExists(String fileId) async {
    final path = await getLocalPath(fileId);
    if (path == null || path.isEmpty) return false;
    return File(path).exists();
  }

  Future<Uint8List?> readLocalBytes(String fileId) async {
    final path = await getLocalPath(fileId);
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<void> removeLocal(String fileId) async {
    final path = await getLocalPath(fileId);
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$fileId');
  }
}

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:study_aid/features/files/data/datasources/file_remote_datasource.dart';

class FileUploadService {
  final FileRemoteDataSource remoteDataSource;

  FileUploadService(this.remoteDataSource);

  /// Pick a file from the device
  Future<PlatformFile?> pickFile({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
        withData: true, // Required for web to get bytes
      );

      return result?.files.single;
    } catch (e) {
      throw Exception('File picking failed: $e');
    }
  }

  /// Get file metadata
  FileMetadata getFileMetadata(PlatformFile file) {
    final fileName = file.name;
    final extension = fileName.split('.').last.toLowerCase();
    final sizeBytes = file.size;

    return FileMetadata(
      fileName: fileName,
      fileType: extension,
      fileSizeBytes: sizeBytes,
      bytes: file.bytes,
    );
  }

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String userId,
    required String topicId,
  }) async {
    return await remoteDataSource.uploadFileToStorage(
      bytes,
      fileName,
      userId,
      topicId,
    );
  }
}

class FileMetadata {
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final Uint8List? bytes;

  FileMetadata({
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    this.bytes,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

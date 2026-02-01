import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';

abstract class FileRepository {
  Future<Either<Failure, FileEntity>> createFile(
      FileEntity file, String topicId, String userId);
  Future<Either<Failure, FileEntity>> updateFile(
      FileEntity file, String topicId, String userId);
  Future<void> deleteFile(String topicId, String fileId, String userId);
  Future<Either<Failure, PaginatedObj<FileEntity>>> fetchFiles(
      String topicId, int limit, int startAfter, String sortBy);
  Future<Either<Failure, void>> syncFiles(String userId);
  Future<Either<Failure, FileEntity?>> getFile(String fileId);
  Future<Either<Failure, List<FileEntity>>> search(
      String query, String userId);
  Future<Either<Failure, String>> uploadFileToStorage(
      Uint8List bytes, String fileName, String userId, String topicId);
}

import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:study_aid/features/files/domain/repository/file_repository.dart';

class CreateFileUseCase {
  final FileRepository repository;

  CreateFileUseCase(this.repository);

  Future<Either<Failure, FileEntity>> call(
      FileEntity file, String topicId, String userId) {
    return repository.createFile(file, topicId, userId);
  }
}

class DeleteFileUseCase {
  final FileRepository repository;

  DeleteFileUseCase(this.repository);

  Future<void> call(String topicId, String fileId, String userId) {
    return repository.deleteFile(topicId, fileId, userId);
  }
}

class UpdateFileUseCase {
  final FileRepository repository;

  UpdateFileUseCase(this.repository);

  Future<Either<Failure, FileEntity>> call(
      FileEntity file, String topicId, String userId) {
    return repository.updateFile(file, topicId, userId);
  }
}

class GetFileUseCase {
  final FileRepository repository;

  GetFileUseCase(this.repository);

  Future<Either<Failure, FileEntity?>> call(String fileId) {
    return repository.getFile(fileId);
  }
}

class SyncFilesUseCase {
  final FileRepository repository;

  SyncFilesUseCase(this.repository);

  Future<void> call(String userId) async {
    final result = await repository.syncFiles(userId);
    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}

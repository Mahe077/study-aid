import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/app_logger.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/core/services/file_local_cache_service.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';
import 'package:study_aid/features/files/data/datasources/file_local_datasource.dart';
import 'package:study_aid/features/files/data/datasources/file_remote_datasource.dart';
import 'package:study_aid/features/files/data/models/file_model.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:study_aid/features/files/domain/repository/file_repository.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';

class FileRepositoryImpl extends FileRepository {
  final FileRemoteDataSource remoteDataSource;
  final FileLocalDataSource localDataSource;
  final FileLocalCacheService cacheService;
  final NetworkInfo networkInfo;
  final TopicRepository topicRepository;
  final UserRepository userRepository;

  FileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.cacheService,
    required this.networkInfo,
    required this.topicRepository,
    required this.userRepository,
  });

  @override
  Future<Either<Failure, FileEntity>> createFile(
      FileEntity file, String topicId, String userId) async {
    FileModel fileModel = FileModel.fromDomain(file);
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.createFile(fileModel);
        return result.fold((failure) => Left(failure), (F) async {
          await localDataSource.createFile(F);
          await topicRepository.updateFileOfParent(topicId, F.id);
          await userRepository.updateRecentItems(
              userId, F.id, ConstantStrings.file);
          return Right(F);
        });
      } else {
        await localDataSource.createFile(fileModel);
        await topicRepository.updateFileOfParent(topicId, fileModel.id);
        await userRepository.updateRecentItems(
            userId, fileModel.id, ConstantStrings.file);
      }
      return Right(fileModel);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedObj<FileEntity>>> fetchFiles(
      String topicId, int limit, int startAfter, String sortBy) async {
    try {
      final localTopic = await topicRepository.getTopic(topicId);

      return localTopic.fold((failure) => Left(failure), (topic) async {
        if (topic == null) {
          return Left(Failure('File: Topic was not found'));
        } else if (topic.files.isEmpty) {
          return Right(
              PaginatedObj(items: [], hasMore: false, lastDocument: 0));
        } else {
          final fileRefs = List.from(topic.files);

          for (var id in fileRefs) {
            if (!localDataSource.fileExists(id)) {
              final fileOrFailure = await remoteDataSource.getFileById(id);

              await fileOrFailure.fold(
                (failure) async {
                  Logger().e('Failed to fetch file with ID $id: $failure');
                },
                (file) async {
                  await localDataSource.createFile(file);
                },
              );
            }
          }

          // For now, return all files (pagination can be added later)
          final allFiles = await localDataSource.fetchAllFiles();
          final topicFiles = allFiles
              .where((file) => fileRefs.contains(file.id))
              .toList();

          return Right(PaginatedObj(
              items: topicFiles,
              hasMore: false,
              lastDocument: topicFiles.length));
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> updateFile(
      FileEntity file, String topicId, String userId) async {
    try {
      final now = DateTime.now();
      FileModel fileModel = FileModel.fromDomain(file);
      fileModel = fileModel.copyWith(
          updatedDate: now,
          localChangeTimestamp: now,
          syncStatus: ConstantStrings.pending);

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.updateFile(fileModel);

        return result.fold((failure) => Left(failure), (F) async {
          await localDataSource.updateFile(fileModel);
          await userRepository.updateRecentItems(
              userId, fileModel.id, ConstantStrings.file);
          return Right(F);
        });
      } else {
        await localDataSource.updateFile(fileModel);
      }
      await userRepository.updateRecentItems(
          userId, fileModel.id, ConstantStrings.file);
      return Right(fileModel);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<void> deleteFile(
      String topicId, String fileId, String userId) async {
    await localDataSource.deleteFile(fileId);
    await cacheService.removeLocal(fileId);

    if (await networkInfo.isConnected) {
      await remoteDataSource.deleteFile(fileId);
    }
    await topicRepository.removeFileOfParent(topicId, fileId);
    await userRepository.updateRecentItems(userId, fileId, ConstantStrings.file,
        isDelete: true);
  }

  @override
  Future<Either<Failure, void>> syncFiles(String userId) async {
    try {
      // 1. Fetch available topics to scan for missing files
      final allTopics = await topicRepository.fetchAllTopics();

      await allTopics.fold(
        (failure) async {
          Logger().e("SyncFiles: Failed to fetch topics: $failure");
        },
        (topics) async {
          // 2. Iterate through all topics and their files
          for (var topic in topics) {
            for (var fileId in topic.files) {
              if (!await networkInfo.isConnected) {
                continue;
              }

              FileEntity? candidate =
                  await localDataSource.getCachedFile(fileId);

              if (candidate == null) {
                final remoteFileResult =
                    await remoteDataSource.getFileById(fileId);
                await remoteFileResult.fold(
                  (failure) async {
                    Logger().w(
                        "SyncFiles: Missing file $fileId in cloud: ${failure.message}");
                  },
                  (remoteFile) async {
                    await localDataSource.createFile(remoteFile);
                    candidate = remoteFile;
                    Logger().i("SyncFiles: Pulled missing file $fileId");
                  },
                );
              }

              if (candidate != null) {
                await ensureFileAvailable(candidate!, topic.id, userId);
              } else {
                await localDataSource.deleteFile(fileId);
                await cacheService.removeLocal(fileId);
                await topicRepository.removeFileOfParent(topic.id, fileId);
                await userRepository.updateRecentItems(
                    userId, fileId, ConstantStrings.file,
                    isDelete: true);
              }
            }
          }
        },
      );

      // 3. Keep existing sync logic
      var localFiles = await localDataSource.fetchAllFiles();

      for (var localFile in localFiles) {
        if (await networkInfo.isConnected) {
          final ensured =
              await ensureFileAvailable(localFile, localFile.topicId, userId);
          if (ensured.isLeft()) {
            continue;
          }
          final ensuredFile = ensured.getOrElse(() => null);
          if (ensuredFile == null) {
            continue;
          }
        }

        final remoteFileOrFailure =
            await remoteDataSource.getFileById(localFile.id);

        await remoteFileOrFailure.fold((failure) async {
          final newFileResult = await remoteDataSource.createFile(localFile);
          newFileResult.fold((failure) => Left(failure),
              (newFile) async {
            await localDataSource.deleteFile(localFile.id);
            await localDataSource.createFile(newFile);
          });
        }, (remoteFile) async {
          if (localFile.updatedDate.isAfter(remoteFile.updatedDate)) {
            await remoteDataSource.updateFile(localFile);
            await localDataSource.updateFile(
                localFile.copyWith(syncStatus: ConstantStrings.synced));
          } else if (remoteFile.updatedDate.isAfter(localFile.updatedDate)) {
            await localDataSource.updateFile(
                remoteFile.copyWith(syncStatus: ConstantStrings.synced));
          }
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileEntity?>> getFile(String fileId) async {
    try {
      final localFile = await localDataSource.getCachedFile(fileId);
      if (localFile != null) {
        return Right(localFile);
      }

      if (await networkInfo.isConnected) {
        final remoteFileResult = await remoteDataSource.getFileById(fileId);

        return remoteFileResult.fold(
          (failure) => Left(failure),
          (remoteFile) async {
            await localDataSource.createFile(remoteFile);
            return Right(remoteFile);
          },
        );
      } else {
        return Right(null);
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileEntity?>> ensureFileAvailable(
      FileEntity file, String topicId, String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Right(file);
      }

      final docExists = await remoteDataSource.fileExists(file.id);
      final storageExists = docExists
          ? await remoteDataSource.storageFileExists(file.fileUrl)
          : false;
      final hasLocal = await cacheService.localFileExists(file.id);

      if (!docExists || !storageExists) {
        if (hasLocal) {
          final bytes = await cacheService.readLocalBytes(file.id);
          if (bytes == null) {
            return await _removeMissingFile(file, topicId, userId, docExists);
          }

          final newUrl = await remoteDataSource.uploadFileToStorage(
              bytes, file.fileName, file.userId, file.topicId);

          final now = DateTime.now();
          final updated = FileModel.fromDomain(file).copyWith(
            fileUrl: newUrl,
            updatedDate: now,
            remoteChangeTimestamp: now,
            localChangeTimestamp: now,
            syncStatus: ConstantStrings.synced,
          );

          final upsert = await remoteDataSource.upsertFile(updated);
          return await upsert.fold(
            (failure) => Left(failure),
            (remoteFile) async {
              await localDataSource.updateFile(remoteFile);
              return Right(remoteFile);
            },
          );
        }

        return await _removeMissingFile(file, topicId, userId, docExists);
      }

      return Right(file);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, FileEntity?>> _removeMissingFile(
      FileEntity file, String topicId, String userId, bool docExists) async {
    AppLogger.i("Removing missing file: ${file.id}");
    await localDataSource.deleteFile(file.id);
    await cacheService.removeLocal(file.id);

    if (docExists) {
      await remoteDataSource.deleteFile(file.id);
    }

    await topicRepository.removeFileOfParent(topicId, file.id);
    await userRepository.updateRecentItems(
        userId, file.id, ConstantStrings.file,
        isDelete: true);

    return const Right(null);
  }

  @override
  Future<Either<Failure, List<FileEntity>>> search(
      String query, String userId) async {
    try {
      List<FileModel> combinedResults = [];

      final localFileResult = await localDataSource.searchFromLocal(query);
      combinedResults.addAll(localFileResult);

      if (await networkInfo.isConnected) {
        final remoteFileResult =
            await remoteDataSource.searchFromRemote(query, userId);

        return remoteFileResult.fold(
          (failure) => Left(Failure(failure.message)),
          (remoteFiles) {
            combinedResults.addAll(remoteFiles.where((remoteFile) =>
                !combinedResults
                    .any((localFile) => localFile.id == remoteFile.id)));
            return Right(combinedResults);
          },
        );
      } else {
        return Right(combinedResults);
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFileToStorage(
      Uint8List bytes, String fileName, String userId, String topicId) async {
    try {
      if (await networkInfo.isConnected) {
        final url = await remoteDataSource.uploadFileToStorage(
            bytes, fileName, userId, topicId);
        return Right(url);
      } else {
        return Left(Failure('No internet connection'));
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/services/file_upload_service.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:study_aid/features/files/domain/repository/file_repository.dart';
import 'package:study_aid/features/files/domain/usecases/file_usecases.dart';
import 'package:study_aid/features/topics/presentation/providers/recentItem_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';

class FilesState {
  final List<FileEntity> files;
  final bool hasMore;
  final int lastDocument;
  final bool isUploading;
  final double uploadProgress;

  FilesState({
    required this.files,
    this.hasMore = true,
    required this.lastDocument,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  FilesState copyWith({
    List<FileEntity>? files,
    bool? hasMore,
    required int lastDocument,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return FilesState(
      files: files ?? this.files,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class FilesNotifier extends StateNotifier<AsyncValue<FilesState>> {
  final FileRepository repository;
  final FileUploadService uploadService;
  final String topicId;
  final Ref _ref;
  final String sortBy;

  FilesNotifier(
    this.repository,
    this.uploadService,
    this.topicId,
    this._ref,
    this.sortBy,
  ) : super(const AsyncValue.loading()) {
    _loadInitialFiles();
  }

  Future<void> _loadInitialFiles() async {
    try {
      final result = await repository.fetchFiles(topicId, 10, 0, sortBy);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          state = AsyncValue.data(
            FilesState(
              files: paginatedObj.items,
              hasMore: paginatedObj.hasMore,
              lastDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<Either<Failure, FileEntity>> uploadFile({
    required String userId,
    required String dropdownValue,
    List<String>? allowedExtensions,
    VoidCallback? onUploadStarted,
  }) async {
    try {
      // Pick file
      final pickedFile = await uploadService.pickFile(allowedExtensions: allowedExtensions);
      if (pickedFile == null) {
        return Left(Failure('No file selected'));
      }

      // Invoke the callback to show the "upload started" toast.
      onUploadStarted?.call();


      // Update UI to show upload progress
      final currentState = state.value!;
      state = AsyncValue.data(currentState.copyWith(
        lastDocument: currentState.lastDocument,
        isUploading: true,
        uploadProgress: 0.0,
      ));

      // Get file metadata
      final metadata = uploadService.getFileMetadata(pickedFile);

      // Upload to Firebase Storage
      if (metadata.bytes == null && !kIsWeb) {
         return Left(Failure('File bytes are null. Cannot upload.'));
      }

      final fileUrl = await uploadService.uploadFile(
        bytes: metadata.bytes!,
        fileName: metadata.fileName,
        userId: userId,
        topicId: topicId,
      );

      // Create file entity
      final now = DateTime.now();
      final fileEntity = FileEntity(
        id: UniqueKey().toString(),
        fileName: metadata.fileName,
        fileUrl: fileUrl,
        fileType: metadata.fileType,
        fileSizeBytes: metadata.fileSizeBytes,
        uploadedDate: now,
        updatedDate: now,
        userId: userId,
        topicId: topicId,
        syncStatus: ConstantStrings.pending,
        localChangeTimestamp: now,
        remoteChangeTimestamp: now,
      );

      // Save to repository
      final createFile = CreateFileUseCase(repository);
      final result = await createFile.call(fileEntity, topicId, userId);

      return result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(
            lastDocument: currentState.lastDocument,
            isUploading: false,
          ));
          return Left(failure);
        },
        (newFile) {
          // Update UI
          final tabDataNotifier = _ref.read(
              tabDataProvider(TabDataParams(topicId, dropdownValue)).notifier);
          tabDataNotifier.updateFile(newFile);

          final recentItemNotifier =
              _ref.read(recentItemProvider(userId).notifier);
          recentItemNotifier.updateFile(newFile);

          state = AsyncValue.data(currentState.copyWith(
            files: [newFile, ...currentState.files],
            lastDocument: currentState.lastDocument + 1,
            isUploading: false,
            uploadProgress: 1.0,
          ));

          return Right(newFile);
        },
      );
    } catch (e, stackTrace) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          lastDocument: currentState.lastDocument,
          isUploading: false,
        ));
      } else {
        state = AsyncValue.error(e, stackTrace);
      }
      return Left(Failure(e.toString()));
    }
  }

  Future<void> deleteFile(
    String fileId,
    String userId,
    String dropdownValue,
  ) async {
    try {
      final deleteFile = DeleteFileUseCase(repository);
      await deleteFile.call(topicId, fileId, userId);

      final tabDataNotifier = _ref.read(
          tabDataProvider(TabDataParams(topicId, dropdownValue)).notifier);
      tabDataNotifier.deleteFile(fileId);

      final recentItemNotifier = _ref.read(recentItemProvider(userId).notifier);
      recentItemNotifier.deleteFile(fileId);

      // Update local state
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          files: currentState.files.where((f) => f.id != fileId).toList(),
          lastDocument: currentState.lastDocument,
        ));
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }
}

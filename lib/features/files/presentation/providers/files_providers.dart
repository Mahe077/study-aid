import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/core/services/file_upload_service.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';
import 'package:study_aid/features/files/data/datasources/file_local_datasource.dart';
import 'package:study_aid/features/files/data/datasources/file_remote_datasource.dart';
import 'package:study_aid/features/files/data/models/file_model.dart';
import 'package:study_aid/features/files/data/repository/file_repository_impl.dart';
import 'package:study_aid/features/files/domain/repository/file_repository.dart';
import 'package:study_aid/features/files/presentation/notifiers/files_notifier.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';

final fileLocalDataSourceProvider = Provider<FileLocalDataSource>((ref) {
  return FileLocalDataSourceImpl(Hive.box<FileModel>('fileBox'));
});

final fileRemoteDataSourceProvider = Provider<FileRemoteDataSource>((ref) {
  return FileRemoteDataSourceImpl();
});

final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  final remoteDataSource = ref.watch(fileRemoteDataSourceProvider);
  return FileUploadService(remoteDataSource);
});

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final localDataSource = ref.watch(fileLocalDataSourceProvider);
  final remoteDataSource = ref.watch(fileRemoteDataSourceProvider);
  
  // Use Riverpod providers instead of GetIt
  final networkInfo = NetworkInfo();
  final topicRepository = ref.watch(topicRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return FileRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
    topicRepository: topicRepository,
    userRepository: userRepository,
  );
});

// Provider for the list of files
// We use family to pass topicId and sortBy
final filesProvider = StateNotifierProvider.family<FilesNotifier, AsyncValue<FilesState>, FilesParams>(
  (ref, params) {
    final repository = ref.watch(fileRepositoryProvider);
    final uploadService = ref.watch(fileUploadServiceProvider);
    
    return FilesNotifier(
      repository,
      uploadService,
      params.topicId,
      ref,
      params.sortBy,
    );
  },
);

class FilesParams {
  final String topicId;
  final String sortBy;

  FilesParams({required this.topicId, required this.sortBy});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is FilesParams &&
      other.topicId == topicId &&
      other.sortBy == sortBy;
  }

  @override
  int get hashCode => topicId.hashCode ^ sortBy.hashCode;
}

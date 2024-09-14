import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/topics/data/datasources/topic_firebase_service.dart';
import 'package:study_aid/features/topics/data/datasources/topic_local_storage.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';
import 'package:study_aid/features/topics/data/repositories/topic_repository_impl.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';
import 'package:study_aid/features/topics/domain/usecases/topic.dart';
import 'package:study_aid/features/topics/presentation/notifiers/topic_notifire.dart';

// Data source providers
final remoteDataSourceProvider =
    Provider<RemoteDataSource>((ref) => RemoteDataSourceImpl());
final localDataSourceProvider = Provider<LocalDataSource>(
    (ref) => LocalDataSourceImpl(Hive.box<TopicModel>('topicBox')));
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

// Repository provider
final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  final localDataSource = ref.read(localDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return TopicRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
    userRepository: userRepository,
  );
});

// Use case providers
final createTopicProvider =
    Provider((ref) => CreateTopic(ref.read(topicRepositoryProvider)));
final updateTopicProvider =
    Provider((ref) => UpdateTopic(ref.read(topicRepositoryProvider)));
final deleteTopicProvider =
    Provider((ref) => DeleteTopic(ref.read(topicRepositoryProvider)));
final fetchAllTopicsProvider =
    Provider((ref) => FetchAllTopics(ref.read(topicRepositoryProvider)));

final topicsProvider = StateNotifierProvider.autoDispose
    .family<TopicsNotifier, AsyncValue<TopicsState>, String>((ref, userId) {
  final repository = ref.read(topicRepositoryProvider);
  return TopicsNotifier(repository, userId, ref);
});

final syncTopicsUseCaseProvider =
    Provider((ref) => SyncTopicsUseCase(ref.read(topicRepositoryProvider)));

final topicChildProvider = StateNotifierProvider.autoDispose
    .family<TopicChildNotifier, AsyncValue<TopicsState>, String?>(
        (ref, parentTopicId) {
  final repository = ref.read(topicRepositoryProvider);
  return TopicChildNotifier(repository, parentTopicId!, ref);
});

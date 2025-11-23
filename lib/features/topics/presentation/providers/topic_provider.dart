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
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';

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

class TopicParams {
  final String userId;
  final String sortBy;

  TopicParams(this.userId, this.sortBy);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          sortBy == other.sortBy;

  @override
  int get hashCode => userId.hashCode ^ sortBy.hashCode;
}

final topicsProvider = StateNotifierProvider.autoDispose
    .family<TopicsNotifier, AsyncValue<TopicsState>, TopicParams>((ref, param) {
  final repository = ref.read(topicRepositoryProvider);
  return TopicsNotifier(repository, param.userId, param.sortBy, ref);
});

final syncTopicsUseCaseProvider =
    Provider((ref) => SyncTopicsUseCase(ref.read(topicRepositoryProvider)));

final topicChildProvider = StateNotifierProvider.autoDispose
    .family<TopicChildNotifier, AsyncValue<TopicsState>, TabDataParams>(
        (ref, param) {
  final repository = ref.read(topicRepositoryProvider);
  return TopicChildNotifier(repository, param.parentTopicId, ref, param.sortBy);
});

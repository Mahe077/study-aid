import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';
import 'package:study_aid/features/topics/data/datasources/topic_firebase_service.dart';
import 'package:study_aid/features/topics/data/datasources/topic_local_storage.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';

class TopicRepositoryImpl implements TopicRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserRepository userRepository;

  TopicRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo,
      required this.userRepository});

  @override
  Future<Either<Failure, Topic>> createTopic(String? title, String? description,
      Color color, String? parentId, String userId) async {
    try {
      final now = DateTime.now();
      var topicModel = TopicModel(
        id: UniqueKey().toString(), // Temporary unique ID
        title: title ?? '',
        description: description ?? '',
        color: color,
        createdDate: now,
        updatedDate: now,
        subTopics: [],
        notes: [],
        audioRecordings: [],
        syncStatus: ConstantStrings.pending,
        localChangeTimestamp: now,
        remoteChangeTimestamp: now,
      );

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.createTopic(topicModel);
        return result.fold(
          (failure) => Left(failure),
          (topic) async {
            await localDataSource.createTopic(topic);
            if (parentId == null) {
              await userRepository.updateCreatedTopic(userId, topic.id);
            } else {
              await updateSubTopicOfParent(parentId, topic.id);
            }
            return Right(topic);
          },
        );
      } else {
        await localDataSource.createTopic(topicModel);
        if (parentId == null) {
          await userRepository.updateCreatedTopic(userId, topicModel.id);
        } else {
          TopicModel? localParentTopic =
              await localDataSource.getCachedTopic(parentId);
          if (localParentTopic == null) {
            return Left(Failure("Unknown parent topic selected"));
          }
          localParentTopic.subTopics.add(topicModel.id);
          await localDataSource.updateTopic(localParentTopic);
        }

        return Right(topicModel);
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSubTopicOfParent(
      String parentId, String subTopicId) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getTopicById(parentId);
        return result.fold(
          (failure) => Left(failure),
          (topic) async {
            topic.subTopics.add(subTopicId);
            final updateResult = await remoteDataSource.updateTopic(topic);
            return updateResult.fold((failure) => Left(failure), (_) async {
              await localDataSource.updateTopic(topic);
              return const Right(null);
            });
          },
        );
      } else {
        final localParentTopic = await localDataSource.getCachedTopic(parentId);
        if (localParentTopic != null) {
          localParentTopic.subTopics.add(subTopicId);
          await localDataSource.updateTopic(
              localParentTopic.copyWith(syncStatus: ConstantStrings.pending));
          return const Right(null);
        } else {
          return Left(Failure("Something Wrong Try again later!"));
        }
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNoteOfParent(
      String parentId, String noteId) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getTopicById(parentId);
        result.fold(
          (failure) => Left(failure),
          (topic) async {
            topic.notes.add(noteId);
            await remoteDataSource.updateTopic(topic);
          },
        );
      } else {
        final localParentTopic = await localDataSource.getCachedTopic(parentId);
        if (localParentTopic != null) {
          localParentTopic.notes.add(noteId);
          await localDataSource.updateTopic(localParentTopic);
        } else {
          return Left(Failure("Something Wrong Try again later!"));
        }
      }
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAudioOfParent(
      String parentId, String audioId) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getTopicById(parentId);
        result.fold(
          (failure) => Left(failure),
          (topic) async {
            topic.audioRecordings.add(audioId);
            await remoteDataSource.updateTopic(topic);
          },
        );
      } else {
        final localParentTopic = await localDataSource.getCachedTopic(parentId);
        if (localParentTopic != null) {
          localParentTopic.audioRecordings.add(audioId);
          await localDataSource.updateTopic(localParentTopic);
        } else {
          return Left(Failure("Something Wrong Try again later!"));
        }
      }
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Topic>> updateTopic(Topic topic) async {
    try {
      final now = DateTime.now();
      TopicModel topicModel = TopicModel.fromDomain(topic);
      topicModel = topicModel.copyWith(
          updatedDate: now,
          localChangeTimestamp: now,
          syncStatus: ConstantStrings.pending);

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.updateTopic(topicModel.copyWith(
            remoteChangeTimestamp: now, syncStatus: ConstantStrings.synced));

        return result.fold(
          (failure) => Left(failure),
          (topic) async {
            await localDataSource.updateTopic(topic);
            return Right(topic);
          },
        );
      } else {
        await localDataSource.updateTopic(topicModel);
        return Right(topicModel);
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await localDataSource.deleteTopic(topicId);

    if (await networkInfo.isConnected) {
      await remoteDataSource
          .deleteTopic(topicId); //TODO:update parent or user references
    }
  }

  @override
  Future<Either<Failure, List<Topic>>> fetchAllTopics() async {
    try {
      final topics = await localDataSource.fetchAllTopics();
      return Right(topics.map((topicModel) => topicModel.toDomain()).toList());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedObj<Topic>>> fetchUserTopics(
      String userId, int limit, int startAfter) async {
    try {
      final resultUser = await userRepository.getUser(userId);

      return resultUser.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            return Left(Failure('User not found or has no created topics'));
          } else if (user.createdTopics.isEmpty) {
            return Right(
                PaginatedObj(items: [], hasMore: false, lastDocument: 0));
          } else {
            final topicRefs = List.from(user.createdTopics);

            for (var id in topicRefs) {
              if (!localDataSource.topicExists(id)) {
                final topicOrFailure = await remoteDataSource.getTopicById(id);

                topicOrFailure.fold(
                  (failure) {
                    // Handle the failure (e.g., log it or return a failure response)
                    Logger().e('Failed to fetch topic with ID $id: $failure');
                  },
                  (topic) async {
                    // Save the fetched topic to the local data source
                    await localDataSource.createTopic(topic);
                  },
                );
              }
            }
            final topics = await localDataSource.fetchPeginatedTopics(
              limit,
              topicRefs,
              startAfter,
            );

            return topics.fold(
                (failure) => Left(failure), (items) => Right(items));
          }
        },
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedObj<Topic>>> fetchSubTopics(
      String topicId, int limit, int startAfter) async {
    try {
      final parentTopic = await localDataSource.getCachedTopic(topicId);

      if (parentTopic == null || parentTopic.subTopics.isEmpty) {
        return Left(
            Failure('Topic was not found or has no created sub topics'));
      } else {
        final topicRefs = List.from(parentTopic.subTopics);

        final topics = await localDataSource.fetchPeginatedTopics(
          limit,
          topicRefs,
          startAfter,
        );

        return topics.fold((failure) => Left(failure), (items) => Right(items));
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncTopics() async {
    try {
      var localTopics = await localDataSource.fetchAllTopics();
      localTopics = localTopics
          .where((topic) => topic.syncStatus == ConstantStrings.pending)
          .toList();

      for (var topic in localTopics) {
        topic = topic.copyWith(syncStatus: ConstantStrings.synced);
        if (await remoteDataSource.topicExists(topic.id)) {
          await remoteDataSource.updateTopic(topic);
          await localDataSource.updateTopic(topic);
        } else {
          final newTopicResult = await remoteDataSource.createTopic(topic);
          newTopicResult.fold((failure) => Left(Failure(failure.toString())),
              (newTopic) async {
            await localDataSource.deleteTopic(topic.id);
            await localDataSource.createTopic(newTopic);
          });
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Topic?>> getTopic(String topicId) async {
    try {
      return Right(await localDataSource.getCachedTopic(topicId));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<List<dynamic>> getAllEntitiesPaginated(
      String parentId, int limit, int startAfter) async {
    final topicsResults = await fetchSubTopics(parentId, limit, startAfter);
    // final notes = noteBox.values.toList();
    // final audios = audioBox.values.toList();
    var topics;
    topicsResults.fold(
        (failure) => Left(failure), (items) => topics = items.items);

    final allEntities = [...topics];
    // []..addAll(topics.);
    // ..addAll(notes)
    // ..addAll(audios);

    allEntities.sort((a, b) =>
        b.updatedDate.compareTo(a.updatedDate)); // Sort by updatedDate date

    // Determine the start index based on the last fetched date
    int startIndex = startAfter;
    allEntities.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

    // Load items in the specified limit
    final paginatedEntities = allEntities.skip(startIndex).take(limit).toList();

    return paginatedEntities;
  }
}

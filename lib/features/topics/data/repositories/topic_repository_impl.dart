import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
        final result = await remoteDataSource.createTopic(
            topicModel.copyWith(syncStatus: ConstantStrings.synced));
        await localDataSource.createTopic(topicModel);

        return result.fold(
          (failure) => Left(failure),
          (topic) async {
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
          //TODO: update the parent topic box createdfTopic
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
        result.fold(
          (failure) => Left(failure),
          (topic) async {
            topic.subTopics.add(subTopicId);
            await remoteDataSource.updateTopic(topic);
          },
        );
      } else {
        final localParentTopic = await localDataSource.getCachedTopic(parentId);
        if (localParentTopic != null) {
          localParentTopic.subTopics.add(subTopicId);
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
  Future<Either<Failure, Topic>> updateTopic(
      String topicId, String title, Color color) async {
    try {
      final now = DateTime.now();
      var topicModel = TopicModel(
        id: topicId,
        title: title,
        description: '',
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
        final result = await remoteDataSource.updateTopic(topicModel);

        return result.fold(
          (failure) => Left(failure),
          (topic) async {
            await localDataSource.updateTopic(topic);
            return Right(topic);
          },
        );
      } else {
        await localDataSource.updateTopic(topicModel.copyWith());
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
      String userId, int limit,
      {DocumentSnapshot? startAfter}) async {
    try {
      // Fetch user document
      final resultUser = await userRepository.getUser(userId);

      return resultUser.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null || user.createdTopics.isEmpty) {
            return Left(Failure('User not found or has no created topics'));
          } else {
            // Get the list of topic references
            final topicRefs = List.from(user.createdTopics);

            // Fetch topics from references
            final topicsResult = await remoteDataSource
                .getTopics(userId, limit, topicRefs, startAfter: startAfter);

            return topicsResult.fold(
              (failure) => Left(failure),
              (items) {
                return Right(items);
              },
            );
          }
        },
      );
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
}

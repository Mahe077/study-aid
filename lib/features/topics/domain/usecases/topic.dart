import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';

class CreateTopic {
  final TopicRepository repository;

  CreateTopic(this.repository);

  Future<Either<Failure, Topic>> call(String? title, String? description,
      Color color, String? parentId, String userId) async {
    final result = await repository.createTopic(
        title, description, color, parentId, userId);
    return result.fold(
      (failure) => Left(failure),
      (topic) => Right(topic),
    );
  }
}

class UpdateTopic {
  final TopicRepository repository;

  UpdateTopic(this.repository);

  Future<Either<Failure, Topic>> call(
      String topicId, String title, Color color) async {
    final result = await repository.updateTopic(topicId, title, color);
    return result.fold(
      (failure) => Left(failure),
      (topic) => Right(topic),
    );
  }
}

class DeleteTopic {
  final TopicRepository repository;

  DeleteTopic(this.repository);

  Future<void> call(String topicId) async {
    return repository.deleteTopic(topicId);
  }
}

class FetchAllTopics {
  final TopicRepository repository;

  FetchAllTopics(this.repository);

  Future<Either<Failure, List<Topic>>> call() async {
    final result = await repository.fetchAllTopics();
    return result.fold(
      (failure) => Left(failure),
      (topic) => Right(topic),
    );
  }
}

class SyncTopicsUseCase {
  final TopicRepository repository;

  SyncTopicsUseCase(this.repository);

  Future<void> call() async {
    final result = await repository.syncTopics();
    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}

// Similar use cases for SyncUserDataUseCase, SyncNotesUseCase, and SyncAudioUseCase

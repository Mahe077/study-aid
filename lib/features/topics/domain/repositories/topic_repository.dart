import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';

abstract class TopicRepository {
  Future<Either<Failure, Topic>> createTopic(String? title, String? description,
      Color color, String? parentId, String userId);
  Future<Either<Failure, Topic>> updateTopic(
      String topicId, String title, Color color);
  Future<void> deleteTopic(String topicId);
  Future<Either<Failure, List<Topic>>> fetchAllTopics();
  Future<Either<Failure, void>> updateSubTopicOfParent(
      String parentId, String subTopicId);
  Future<Either<Failure, PaginatedObj<Topic>>> fetchUserTopics(
      String userId, int limit,
      {DocumentSnapshot? startAfter});
  Future<Either<Failure, void>> syncTopics();
}

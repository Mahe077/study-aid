import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';

abstract class TopicRepository {
  Future<Either<Failure, Topic>> createTopic(String? title, String? description,
      Color color, String? parentId, String userId);
  Future<Either<Failure, Topic>> updateTopic(Topic topic);
  Future<void> deleteTopic(String topicId, String? parentId, String userId);
  Future<Either<Failure, Topic?>> getTopic(String topicId);
  Future<Either<Failure, List<Topic>>> fetchAllTopics();
  Future<Either<Failure, void>> updateSubTopicOfParent(
      String parentId, String subTopicId);
  Future<Either<Failure, void>> updateNoteOfParent(
      String parentId, String noteId);
  Future<Either<Failure, void>> updateFileOfParent(
      String parentId, String fileId);
  Future<Either<Failure, void>> updateAudioOfParent(
      String parentId, String audioId);
  Future<Either<Failure, PaginatedObj<Topic>>> fetchUserTopics(
      String userId, int limit, int startAfter, String sortBy);
  Future<Either<Failure, PaginatedObj<Topic>>> fetchSubTopics(
      String topicId, int limit, int startAfter, String sortBy);
  Future<Either<Failure, void>> syncTopics();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, TopicModel>> createTopic(TopicModel topic);
  Future<Either<Failure, TopicModel>> updateTopic(TopicModel topic);
  Future<Either<Failure, void>> deleteTopic(String topicId);
  Future<Either<Failure, void>> fetchAllTopics();
  Future<Either<Failure, TopicModel>> getTopicById(String parentId);
  Future<Either<Failure, PaginatedObj<TopicModel>>> getTopics(
      String userId, int limit, List<dynamic> topicRefs,
      {DocumentSnapshot? startAfter});
  Future<bool> topicExists(String topicId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> topicExists(String topicId) async {
    try {
      final docRef = _firestore.collection('topics').doc(topicId);
      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } on Exception catch (e) {
      throw Exception('Error checking topic existence: $e');
    }
  }

  @override
  Future<Either<Failure, TopicModel>> createTopic(TopicModel topic) async {
    try {
      final docRef = _firestore.collection('topics').doc();
      // Convert TopicModel to Firestore document
      final topicWithId = topic.copyWith(id: docRef.id, syncStatus: 'synced');

      // Set the document in Firestore
      await docRef.set(topicWithId.toFirestore());

      // Return the topic with the newly assigned ID
      return Right(topicWithId);
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    } on Exception catch (e) {
      throw Exception('Error in creating a topic: $e');
    }
  }

  @override
  Future<Either<Failure, TopicModel>> updateTopic(TopicModel topic) async {
    try {
      await _firestore
          .collection('topics')
          .doc(topic.id)
          .update(topic.copyWith(syncStatus: 'synced').toFirestore());
      return Right(topic);
    } on Exception catch (e) {
      throw Exception('Error in updating a topic: $e');
    }
  }

  @override
  Future<Either<Failure, void>> deleteTopic(String topicId) async {
    try {
      await _firestore.collection('topics').doc(topicId).delete();
      return const Right(null);
    } catch (e) {
      throw Exception('Error in deleting the topic: $e');
    }
  }

  @override
  Future<Either<Failure, List<TopicModel>>> fetchAllTopics() async {
    try {
      final querySnapshot = await _firestore.collection('topics').get();
      return Right(querySnapshot.docs
          .map((doc) => TopicModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw Exception('Error in loading topics: $e');
    }
  }

  @override
  Future<Either<Failure, TopicModel>> getTopicById(String parentId) async {
    try {
      final querySnapshot =
          await _firestore.collection('topics').doc(parentId).get();
      return Right(TopicModel.fromFirestore(querySnapshot));
    } catch (e) {
      throw Exception('Error in updating a topic: $e');
    }
  }

  @override
  Future<Either<Failure, PaginatedObj<TopicModel>>> getTopics(
      String userId, int limit, List<dynamic> topicRefs,
      {DocumentSnapshot? startAfter}) async {
    try {
      Query query = _firestore
          .collection('topics')
          .where(FieldPath.documentId, whereIn: topicRefs)
          .orderBy('updatedDate', descending: true) // Sort by updatedDate
          .limit(limit);

      if (startAfter != null) {
        // Continue from the last document if paging
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final topics =
          snapshot.docs.map((doc) => TopicModel.fromFirestore(doc)).toList();

      // Check if there are more topics to load
      final hasMore = topicRefs.length > limit;

      return Right(PaginatedObj(
        items: topics,
        hasMore: hasMore,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      ));
    } catch (e) {
      throw Exception('Error in updating a topic: $e');
    }
  }
}

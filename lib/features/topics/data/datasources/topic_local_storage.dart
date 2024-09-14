import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';

abstract class LocalDataSource {
  Future<void> createTopic(TopicModel topic);
  Future<void> updateTopic(TopicModel topic);
  Future<TopicModel?> getCachedTopic(String topicId);
  Future<void> deleteTopic(String topicId);
  List<TopicModel> fetchAllTopics();
  bool topicExists(String topicId);
  Future<Either<Failure, PaginatedObj<TopicModel>>> fetchPeginatedTopics(
      int limit, List<dynamic> topicRefs, int startAfter);
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<TopicModel> _topicBox;

  LocalDataSourceImpl(this._topicBox);
  @override
  Future<void> createTopic(TopicModel topic) async {
    await _topicBox.put(topic.id, topic);
  }

  @override
  Future<void> updateTopic(TopicModel topic) async {
    await _topicBox.put(topic.id, topic);
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await _topicBox.delete(topicId);
  }

  @override
  List<TopicModel> fetchAllTopics() {
    return _topicBox.values.toList();
  }

  @override
  Future<Either<Failure, PaginatedObj<TopicModel>>> fetchPeginatedTopics(
      int limit, List<dynamic> topicRefs, int startAfter) async {
    try {
      int startIndex = startAfter;
      int endIndex = startIndex + limit;

      printTopicBoxContents();

      List<Future<TopicModel?>> futureTopics = topicRefs.map((topicId) {
        return getCachedTopic(topicId);
      }).toList();

// Wait for all the futures to resolve
      List<TopicModel?> topics = await Future.wait(futureTopics);

// Filter out any null values and return a list of non-null TopicModels
      List<TopicModel> nonNullTopics =
          topics.where((topic) => topic != null).cast<TopicModel>().toList();

      nonNullTopics.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

      final hasmore = topics.length > endIndex ? true : false;

      return Right(PaginatedObj(
          items: hasmore
              ? nonNullTopics.sublist(startIndex, endIndex)
              : nonNullTopics.sublist(startIndex),
          hasMore: hasmore,
          lastDocument: endIndex));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<TopicModel?> getCachedTopic(String topicId) async {
    final topic = _topicBox.get(topicId);
    if (topic != null) {
      return topic;
    } else {
      return null;
    }
  }

  @override
  bool topicExists(String topicId) {
    return _topicBox.containsKey(topicId);
  }

  void printTopicBoxContents() {
    // Assuming _topicBox is your Hive box
    var allKeys = _topicBox.keys;
    print('All keys in topicBox: $allKeys');

    var allTopics = _topicBox.values.toList();
    print('All items in topicBox:');
    for (var i = 0; i < allTopics.length; i++) {
      print('Item $i: ${allTopics[i]}');
    }
  }
}

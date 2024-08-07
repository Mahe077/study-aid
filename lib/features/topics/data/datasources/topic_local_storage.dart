import 'package:hive/hive.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';

abstract class LocalDataSource {
  Future<void> createTopic(TopicModel topic);
  Future<void> updateTopic(TopicModel topic);
  Future<TopicModel?> getCachedTopic(String topicId);
  Future<void> deleteTopic(String topicId);
  Future<List<TopicModel>> fetchAllTopics();
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
  Future<List<TopicModel>> fetchAllTopics() async {
    return _topicBox.values.toList();
  }

  @override
  Future<TopicModel?> getCachedTopic(String topicId) async {
    return _topicBox.get(topicId);
  }
}

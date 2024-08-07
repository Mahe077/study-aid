import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

class TopicsState {
  final List<Topic> topics;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  TopicsState({
    required this.topics,
    this.hasMore = true,
    this.lastDocument,
  });

  TopicsState copyWith({
    List<Topic>? topics,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return TopicsState(
      topics: topics ?? this.topics,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

class TopicsNotifier extends StateNotifier<AsyncValue<TopicsState>> {
  final TopicRepository repository;
  final String userId;
  final Ref _ref;

  TopicsNotifier(this.repository, this.userId, this._ref)
      : super(const AsyncValue.loading()) {
    _loadInitialTopics();
  }

  Future<void> _loadInitialTopics() async {
    try {
      final result = await repository.fetchUserTopics(userId, 5);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          state = AsyncValue.data(
            TopicsState(
              topics: paginatedObj.items,
              hasMore: paginatedObj.hasMore,
              lastDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMoreTopics() async {
    final currentState = state;
    if (!currentState.value!.hasMore) return;

    final lastDocument = currentState.value!.lastDocument;
    try {
      final result =
          await repository.fetchUserTopics(userId, 5, startAfter: lastDocument);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (paginatedObj) {
          final newTopics = paginatedObj.items
              .where((item) => !currentState.value!.topics
                  .any((topic) => topic.id == item.id))
              .toList();

          state = AsyncValue.data(
            currentState.value!.copyWith(
              topics: [...currentState.value!.topics, ...newTopics],
              hasMore: paginatedObj.hasMore,
              lastDocument: paginatedObj.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createTopic(String? title, String? description, Color color,
      String? parentId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final createTopic = _ref.read(createTopicProvider);
      final result =
          await createTopic.call(title, description, color, parentId, userId);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (newTopic) {
          final currentState = state;

          state = AsyncValue.data(
            currentState.value!.copyWith(
              topics: [newTopic, ...currentState.value!.topics],
              // Keep existing `hasMore` and `lastDocument` state
              hasMore: currentState.value!.hasMore,
              lastDocument: currentState.value!.lastDocument,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTopic(String id, String title, Color color) async {
    state = const AsyncValue.loading();
    try {
      final updateTopic = _ref.read(updateTopicProvider);
      final result = await updateTopic.call(id, title, color);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (updatedTopic) {
          final currentState = state;

          state = AsyncValue.data(
            currentState.value!.copyWith(
              topics: currentState.value!.topics
                  .map(
                    (topic) =>
                        topic.id == updatedTopic.id ? updatedTopic : topic,
                  )
                  .toList(),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> fetchAllTopics() async {
    state = const AsyncValue.loading();
    try {
      final fetchAllTopics = _ref.read(fetchAllTopicsProvider);
      final result = await fetchAllTopics.call();

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (topics) => state = AsyncValue.data(TopicsState(topics: topics)),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTopic(String topicId) async {
    state = const AsyncValue.loading();
    try {
      final deleteTopic = _ref.read(deleteTopicProvider);
      await deleteTopic.call(topicId);

      final currentState = state;
      state = AsyncValue.data(
        currentState.value!.copyWith(
          topics: currentState.value!.topics
              .where((topic) => topic.id != topicId)
              .toList(),
        ),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

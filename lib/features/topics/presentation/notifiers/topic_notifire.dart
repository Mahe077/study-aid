import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';

class TopicsState {
  final List<Topic> topics;
  final bool hasMore;
  final int lastDocument;

  TopicsState({
    required this.topics,
    this.hasMore = true,
    required this.lastDocument,
  });

  TopicsState copyWith({
    List<Topic>? topics,
    bool? hasMore,
    required int lastDocument,
  }) {
    return TopicsState(
      topics: topics ?? this.topics,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument,
    );
  }
}

class TopicsNotifier extends StateNotifier<AsyncValue<TopicsState>> {
  final TopicRepository repository;
  final String userId;
  final Ref _ref;

  TopicsNotifier(this.repository, this.userId, this._ref)
      : super(const AsyncValue.loading()) {
    loadInitialTopics();
  }

  Future<void> loadInitialTopics() async {
    try {
      final result = await repository.fetchUserTopics(userId, 5, 0);
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
      final result = await repository.fetchUserTopics(userId, 5, lastDocument);
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
    final currentState = state;
    try {
      final createTopic = _ref.read(createTopicProvider);
      final result =
          await createTopic.call(title, description, color, parentId, userId);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (newTopic) {
          if (parentId == null) {
            Logger().d(
                'createTopic:: Current state: ${currentState.value.toString()}');
            Logger().d('createTopic:: State: ${state.value.toString()}');
            Logger().d('createTopic:: New topic created: $newTopic');

            // If the state is loading or null, initialize the state with the new topic
            if (currentState.value == null ||
                currentState.value!.topics.isEmpty) {
              // Initialize state
              state = AsyncValue.data(
                TopicsState(
                  topics: [newTopic],
                  hasMore: false,
                  lastDocument: 0,
                ),
              );
            } else {
              // If we already have some topics, merge the new one
              state = AsyncValue.data(
                currentState.value!.copyWith(
                  topics: [newTopic, ...currentState.value!.topics],
                  hasMore: currentState.value!.hasMore,
                  lastDocument: currentState.value!.lastDocument,
                ),
              );
            }
          } else {
            // Notify TabDataNotifier to update state
            final tabDataNotifier =
                _ref.read(tabDataProvider(parentId).notifier);
            tabDataNotifier.updateTopic(newTopic);
          }
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTopic(Topic topic) async {
    state = const AsyncValue.loading();
    try {
      final updateTopic = _ref.read(updateTopicProvider);
      final result = await updateTopic.call(topic);

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
                lastDocument: currentState.value!.lastDocument),
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
        (topics) => state = AsyncValue.data(
            TopicsState(topics: topics, lastDocument: topics.length)),
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
            lastDocument: currentState.value!.lastDocument),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

class TopicChildNotifier extends StateNotifier<AsyncValue<TopicsState>> {
  final TopicRepository repository;
  final String topicId;
  final Ref _ref;

  TopicChildNotifier(this.repository, this.topicId, this._ref)
      : super(const AsyncValue.loading()) {
    _loadInitialTopicChild();
  }

  Future<void> createTopic(String? title, String? description, Color color,
      String parentId, String userId) async {
    final currentState = state; // Get the current state before changing it

    try {
      final createTopic = _ref.read(createTopicProvider);
      final result =
          await createTopic.call(title, description, color, parentId, userId);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (newTopic) {
          // If the state is loading or null, initialize the state with the new topic
          if (currentState.value == null ||
              currentState.value!.topics.isEmpty) {
            // Initialize state
            state = AsyncValue.data(
              TopicsState(
                topics: [newTopic],
                hasMore: false,
                lastDocument: 0,
              ),
            );
          } else {
            // If we already have some topics, merge the new one
            state = AsyncValue.data(
              currentState.value!.copyWith(
                topics: [newTopic, ...currentState.value!.topics],
                hasMore: currentState.value!.hasMore,
                lastDocument: currentState.value!.lastDocument,
              ),
            );
          }

          // final tabDataNotifier = _ref.read(tabDataProvider(parentId).notifier);
          // tabDataNotifier.updateTopic(newTopic);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> _loadInitialTopicChild() async {
    try {
      final result = await repository.fetchSubTopics(topicId, 5, 0);
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

  Future<void> loadMoreTopicChild() async {
    final currentState = state;
    if (currentState.value == null || !currentState.value!.hasMore) return;

    final lastDocument = currentState.value!.lastDocument;
    try {
      final result = await repository.fetchSubTopics(topicId, 5, lastDocument);
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
}

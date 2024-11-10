import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/assets/app_vectors.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/recent_tile.dart';
import 'package:study_aid/common/widgets/tiles/content_tile.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/presentation/providers/recentItem_provider.dart';
import 'package:study_aid/features/search/presentation/providers/search_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

class HomePage extends ConsumerStatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _search = TextEditingController();

  // List<Note> notes = [sampleNote];
  // List<Topic> topics = [sampleTopic];

  void _loadMoreTopics() {
    Logger().d("_loadMoreTopics clicked");
    ref.read(topicsProvider(widget.user.id).notifier).loadMoreTopics();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(topicsProvider(widget.user.id).notifier).loadInitialTopics();
      ref
          .read(recentItemProvider(widget.user.id).notifier)
          .loadRecentItems(widget.user.id);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final topicsState = ref.watch(topicsProvider(widget.user.id));
    final recentItemState = ref.watch(recentItemProvider(widget.user.id));
    final searchState = ref.watch(searchNotifireProvider);

    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        showMenu: true,
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: FAB(userId: widget.user.id),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppHeadings(
                        text: 'Hello ${widget.user.username},',
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      widget.user.createdTopics.isEmpty
                          ? _emptyHomeText()
                          : _searchField(ref),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: searchState.isSearchActive
                  ? searchState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildSearchResults(searchState.searchResults)
                  : topicsState.when(
                      data: (state) {
                        if (state.topics.isEmpty) {
                          return const EmptyHome();
                        }
                        return Column(
                          children: [
                            recentItemState.when(
                              data: (recentItems) {
                                if (recentItems.recentItems.isEmpty) {
                                  return Container();
                                }
                                return Column(
                                  children: [
                                    const Align(
                                      alignment: AlignmentDirectional.topStart,
                                      child: AppSubHeadings(
                                        text: 'Recent Items',
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: AlignmentDirectional.topStart,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        clipBehavior: Clip.none,
                                        child: Row(
                                          children: recentItems.recentItems
                                              .map((item) {
                                            return Row(
                                              children: [
                                                RecentTile(
                                                    entity: item,
                                                    type: item is Topic
                                                        ? TopicType.topic
                                                        : item is Note
                                                            ? TopicType.note
                                                            : TopicType.audio,
                                                    userId: widget.user.id,
                                                    parentTopicId:
                                                        item.parentId),
                                                const SizedBox(width: 15),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                );
                              },
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (error, stack) => const Center(
                                  child:
                                      Center(child: Text("No item to show"))),
                            ),
                            const Align(
                              alignment: AlignmentDirectional.topStart,
                              child: AppSubHeadings(
                                text: 'Topics',
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView(
                                children: [
                                  for (int i = 0; i < state.topics.length; i++)
                                    Column(
                                      children: [
                                        ContentTile(
                                          // title: state.topics[i].title,
                                          userId: widget.user.id,
                                          entity: state.topics[i],
                                          type: TopicType.topic,
                                          parentTopicId: '',
                                        ),
                                        if (i < state.topics.length - 1)
                                          const SizedBox(height: 10),
                                      ],
                                    ),
                                  if (state.hasMore) ...[
                                    ElevatedButton(
                                      onPressed: _loadMoreTopics,
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 25,
                                      ),
                                    ),
                                  ] else
                                    const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField(WidgetRef ref) {
    return TextField(
      controller: _search,
      decoration: InputDecoration(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final query = _search.text.trim();
                if (query.isNotEmpty) {
                  ref
                      .read(searchNotifireProvider.notifier)
                      .performSearch(query);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Clear search and reset to the default view
                _search.clear();
                ref.read(searchNotifireProvider.notifier).resetSearch();
              },
            ),
          ],
        ),
        hintText: 'Search anything',
      ),
    );
  }

  Text _emptyHomeText() {
    return const Text(
      "Let’s get started with your notes...",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontSize: 16,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 16, color: AppColors.black),
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final item = results[index];

        if (item is Note) {
          return ContentTile(
            entity: item,
            type: TopicType.note,
            userId: widget.user.id,
            parentTopicId: item.parentId,
          );
        } else if (item is AudioRecording) {
          return ContentTile(
            entity: item,
            type: TopicType.audio,
            userId: widget.user.id,
            parentTopicId: item.parentId,
          );
        }

        // Handle unexpected item types gracefully
        return const SizedBox.shrink();
      },
    );
  }
}

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SvgPicture.asset(AppVectors.home),
                const SizedBox(height: 20),
                const Text(
                  'Looks like you haven’t created anything yet. Click on the + button in the bottom left corner to get started.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

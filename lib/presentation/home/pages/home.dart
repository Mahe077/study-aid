import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/recent_tile.dart';
import 'package:study_aid/common/widgets/tiles/content_tile.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/presentation/providers/recentItem_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

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
  Widget build(
    BuildContext context,
  ) {
    final topicsState = ref.watch(topicsProvider(widget.user.id));
    final recentItemState = ref.watch(recentItemProvider(widget.user.id));

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
                          : _searchField(),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: topicsState.when(
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
                                    children:
                                        recentItems.recentItems.map((item) {
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
                                              parentTopicId:item.parentId
                                          ),
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
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => const Center(
                            child: Center(child: Text("No item to show"))),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.search),
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
}

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Looks like you haven’t created anything yet. Click on the + button in the bottom left corner to get started.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

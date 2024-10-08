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
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/example_data.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

class TopicPage extends ConsumerStatefulWidget {
  final String topicTitle;
  final Topic entity;
  final String userId;

  const TopicPage(
      {Key? key,
      required this.topicTitle,
      required this.entity,
      required this.userId})
      : super(key: key);

  @override
  ConsumerState<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends ConsumerState<TopicPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMoreTopics() {
    Logger().d("_loadMoreTopics clicked");
    ref.read(topicChildProvider(widget.userId).notifier).loadMoreTopicChild();
  }

  @override
  Widget build(BuildContext context) {
    // final subtopicsState = ref.watch(topicChildProvider(widget.entity.id));
    final tabDataState = ref.watch(tabDataProvider(widget.entity.id));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const BasicAppbar(hideBack: true),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: FAB(
          parentId: widget.entity.id,
          userId: widget.userId,
          topicTitle: widget.entity.title,
          topicColor: widget.entity.color,
        ),
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
                          text: "${widget.topicTitle},",
                          alignment: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        _searchField(),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.topStart,
                      child: AppSubHeadings(
                        text: 'Recent Items',
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: recent.map((item) {
                          return Row(
                            children: [
                              RecentTile(
                                title: item.title,
                                entity: item,
                                type: item is Topic
                                    ? TopicType.topic
                                    : item is Note
                                        ? TopicType.note
                                        : TopicType.audio,
                              ),
                              const SizedBox(width: 15),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const TabBar(
                      tabs: [
                        Tab(text: "All"),
                        Tab(text: "Topic"),
                        Tab(text: "Notes"),
                        Tab(text: "Audio Clips")
                      ],
                      unselectedLabelColor: AppColors.darkGrey,
                      unselectedLabelStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      labelColor: AppColors.primary,
                      labelStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      indicator: BoxDecoration(),
                      dividerHeight: 0,
                      tabAlignment: TabAlignment.center,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                        child: tabDataState.when(
                      data: (state) {
                        if (state.topics.isEmpty
                            //&&
                            // state.notes.isEmpty &&
                            // state.audioRecordings.isEmpty
                            ) {
                          return const Center(child: Text("No items to show"));
                        }
                        return TabBarView(
                            // controller: _tabController,
                            children: [
                              _contentList([...state.topics, ...state.notes],
                                  TopicType.all),
                              _contentList(state.topics, TopicType.topic),
                              _contentList(state.notes, TopicType.note),
                              _contentList([], TopicType.audio),
                            ]);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => const Center(
                          child: Center(child: Text("No item to show"))),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentList(List<dynamic> items, TopicType type) {
    final filteredItems = items.where((item) {
      if (type == TopicType.all) return true; // Show all items
      if (type == TopicType.topic && item is Topic) return true;
      if (type == TopicType.note && item is Note) return true;
      if (type == TopicType.audio && item is AudioRecording) return true;
      return false;
    }).toList();

    if (filteredItems.isEmpty) {
      return const Center(child: Text("No items to show"));
    }

    if (type == TopicType.all) {
      filteredItems.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));
    }

    return ListView(
      children: [
        ...filteredItems.map((item) => Column(
              children: [
                ContentTile(
                    userId: widget.userId,
                    entity: item,
                    type: type,
                    parentTopicId: widget.entity.id),
                const SizedBox(height: 10),
              ],
            )),
        ElevatedButton(
          onPressed: () {
            final notifier =
                ref.read(tabDataProvider(widget.entity.id).notifier);
            switch (type) {
              case TopicType.all:
                notifier.loadAllData(widget.entity.id);
                break;
              case TopicType.topic:
                notifier.loadMoreTopics(widget.entity.id);
                break;
              case TopicType.note:
                notifier.loadMoreNotes(widget.entity.id);
                break;
              case TopicType.audio:
                notifier.loadMoreAudio();
                break;
            }
          },
          // onPressed: _loadMoreTopics,
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 25,
          ),
        ),
      ],
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
}

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          'Looks like you haven’t created anything yet. Click on the + button in the bottom left corner to get started.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/recent_tile.dart';
import 'package:study_aid/common/widgets/tiles/content_tile.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/example_data.dart';

class TopicPage extends ConsumerStatefulWidget {
  final String topicTitle;
  final Topic entity;

  const TopicPage({Key? key, required this.topicTitle, required this.entity})
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
    setState(() {
      widget.entity.subTopics.addAll(["Topic 4", "Topic 5", "Topic 6"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const BasicAppbar(hideBack: true),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton:
            FAB(parentId: widget.entity.id, userId: user.value!.id),
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
                        Tab(text: "Audio Clips"),
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
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _contentList(
                              widget.entity.subTopics, TopicType.topic),
                          _contentList(
                              widget.entity.subTopics, TopicType.topic),
                          _contentList(widget.entity.notes, TopicType.note),
                          _contentList(
                              widget.entity.audioRecordings, TopicType.audio),
                        ],
                      ),
                    ),
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
    if (items.isEmpty) {
      return const Center(child: Text("No items to show"));
    }

    return ListView(
      children: [
        ...items.map((item) => Column(
              children: [
                ContentTile(
                  // title: item.title,
                  entity: item,
                  type: type,
                ),
                const SizedBox(height: 10),
              ],
            )),
        ElevatedButton(
          onPressed: _loadMoreTopics,
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
  const EmptyHome({Key? key}) : super(key: key);

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

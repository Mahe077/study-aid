import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/recent_tile.dart';
import 'package:study_aid/common/widgets/tiles/topic_tile.dart';
import 'package:study_aid/domain/entities/note.dart';
import 'package:study_aid/domain/entities/topic.dart';

class TopicPage extends StatefulWidget {
  final String topicTitle;
  final dynamic entity;
  const TopicPage({super.key, required this.topicTitle, required this.entity});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage>
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

  //TODO:check these
  String usename = "Nasim";
  List notes = ["hi", "hello"];
  List<String> topics = ["Topic 1", "Topic 2", "Topic 3"];
  List<int> types = [1, 2, 3];

  void _loadMoreTopics() {
    setState(() {
      topics.addAll(["Topic 4", "Topic 5", "Topic 6"]);
    });
  }
  // List notes = [];
  //

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const BasicAppbar(
          hideBack: true,
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: const FAB(),
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
                        const SizedBox(
                          height: 10,
                        ),
                        notes.isEmpty
                            ? _emptyHomeText()
                            : _searchField(context),
                        const SizedBox(
                          height: 15,
                        ),
                        // TODO:remove this
                        // IconButton(
                        //     onPressed: () {
                        //       setState(() {
                        //         notes = ["hi"];
                        //       });
                        //     },
                        //     icon: Icon(Icons.add))
                        //TODO:Remove this added for testing puposes
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: notes.isEmpty
                    ? const EmptyHome()
                    : Column(
                        children: [
                          const Align(
                            alignment: AlignmentDirectional.topStart,
                            child: AppSubHeadings(
                              text: 'Recent Items',
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: List.generate(
                                3,
                                (index) => Row(
                                  children: [
                                    const RecentTile(),
                                    if (index < 2) const SizedBox(width: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const TabBar(
                            tabs: [
                              Tab(
                                text: "All",
                              ),
                              Tab(
                                text: "Topic",
                              ),
                              Tab(
                                text: "Notes",
                              ),
                              Tab(
                                text: "Audio Clips",
                              ),
                            ],
                            unselectedLabelColor: AppColors.darkGrey,
                            unselectedLabelStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                            labelColor: AppColors.primary,
                            labelStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                            indicator: BoxDecoration(),
                            dividerHeight: 0,
                            tabAlignment: TabAlignment.center,
                            // tabMargin: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          // const Align(
                          //   alignment: AlignmentDirectional.topStart,
                          //   child: AppSubHeadings(
                          //     text: 'Topics',
                          //     size: 20,
                          //   ),
                          // ),
                          const SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _allContent(widget.entity),
                                _topicsContent(widget.entity),
                                _notesContent(widget.entity),
                                _audioContent(widget.entity),
                              ],
                            ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _allContent(TopicEntity entity) {
    // Replace with your content for "All" tab
    return ListView(
      children: [
        if (entity.topics != null)
          ...entity.topics!.map((topic) => Column(
                children: [
                  TopicTile(
                    title: topic.title,
                    entity: topic,
                    type: TopicType.topic,
                  ),
                  if (topic != entity.topics!.last) const SizedBox(height: 10),
                ],
              )),
        if (entity.notes != null) ...[
          const SizedBox(height: 10),
          ...entity.notes!.map((note) => Column(
                children: [
                  TopicTile(
                    title: note.title,
                    entity: note,
                    type: TopicType.note,
                  ),
                  if (note != entity.notes!.last) const SizedBox(height: 10),
                ],
              ))
        ],
        if (entity.audioRecordings != null) ...[
          const SizedBox(height: 10),
          ...entity.audioRecordings!.map((audio) => Column(
                children: [
                  TopicTile(
                    title: audio.title,
                    entity: audio,
                    type: TopicType.topic,
                  ),
                  if (audio != entity.audioRecordings!.last)
                    const SizedBox(height: 10),
                ],
              ))
        ],
        // ...List.generate(
        //   topics.length,
        //   (index) => Column(
        //     children: [
        //       TopicTile(
        //         title: topics[index],
        //         type: TopicType.note,
        //       ),
        //       if (index < topics.length - 1) const SizedBox(height: 10),
        // ],
        // ),
        // ),
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

  Widget _topicsContent(TopicEntity entity) {
    // Replace with your content for "Topics" tab
    // return const Center(child: Text("Topics content goes here"));
    if (entity.topics != null && entity.topics!.isNotEmpty) {
      return ListView(children: [
        ...entity.topics!.map((topic) => Column(
              children: [
                TopicTile(
                  title: topic.title,
                  entity: topic,
                  type: TopicType.topic,
                ),
                if (topic != entity.topics!.last) const SizedBox(height: 10),
              ],
            )),
        ElevatedButton(
          onPressed: _loadMoreTopics,
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 25,
          ),
        ),
      ]);
    } else {
      return const Center(child: Text("No Topics to show"));
    }
  }

  Widget _notesContent(TopicEntity entity) {
    // Replace with your content for "Notes" tab
    return ListView(
      children: [
        if (entity.notes != null && entity.notes!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...entity.notes!.map((note) => Column(
                children: [
                  TopicTile(
                    title: note.title,
                    entity: note,
                    type: TopicType.note,
                  ),
                  if (note != entity.notes!.last) const SizedBox(height: 10),
                ],
              )),
          ElevatedButton(
            onPressed: _loadMoreTopics,
            child: const Icon(
              Icons.keyboard_arrow_down,
              size: 25,
            ),
          ),
        ] else
          const Center(child: Text("No Notes to show"))
      ],
    );
  }

  Widget _audioContent(TopicEntity entity) {
    // Replace with your content for "Audio Clips" tab
    if (entity.audioRecordings != null && entity.audioRecordings!.isNotEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 10),
          ...entity.audioRecordings!.map((audio) => Column(
                children: [
                  TopicTile(
                    title: audio.title,
                    entity: audio,
                    type: TopicType.topic,
                  ),
                  if (audio != entity.audioRecordings!.last)
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
    } else {
      return const Center(child: Text("No Audio Clips to show"));
    }
  }

  Widget _searchField(BuildContext context) {
    return TextField(
        controller: _search,
        decoration: const InputDecoration(
            suffixIcon: Icon(Icons.search), hintText: 'Search anything'));
  }

  Text _emptyHomeText() {
    return const Text(
      "Let’s get started with your notes...",
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontSize: 16,
      ),
      textAlign: TextAlign.left,
    );
  }
}

class EmptyHome extends StatelessWidget {
  const EmptyHome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Looks like you haven’t created anything yet.Click on the + button in the bottom left corner to get started.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

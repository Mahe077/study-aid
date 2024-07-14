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
import 'package:study_aid/presentation/example_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _search = TextEditingController();

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
    return Scaffold(
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
                        text: 'Hello $usename,',
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      notes.isEmpty ? _emptyHomeText() : _searchField(context),
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
                          height: 15,
                        ),
                        const Align(
                          alignment: AlignmentDirectional.topStart,
                          child: AppSubHeadings(
                            text: 'Topics',
                            size: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              // ...exampleTopicEntitys.map((entity) => Column(
                              //       children: [
                              //         TopicTile(title: entity.title, type: 3),
                              //         const SizedBox(height: 10),
                              //       ],
                              //     )),
                              for (int i = 0;
                                  i < exampleTopicEntitys.length;
                                  i++)
                                Column(
                                  children: [
                                    TopicTile(
                                        title: exampleTopicEntitys[i].title,
                                        entity: exampleTopicEntitys[i],
                                        type: TopicType.topic),
                                    if (i < exampleTopicEntitys.length - 1)
                                      const SizedBox(height: 10),
                                  ],
                                ),
                              // ...List.generate(
                              //   topics.length,
                              //   (index) => Column(
                              //     children: [
                              //       TopicTile(
                              //         title: topics[index],
                              //         type: types[index],
                              //       ),
                              //       if (index < topics.length - 1)
                              //         const SizedBox(height: 10),
                              //     ],
                              //   ),
                              // ),
                              ElevatedButton(
                                onPressed: _loadMoreTopics,
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
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
      // ignore: unnecessary_const
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

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

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
                          height: 5,
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
                                  if (index < 2) const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Align(
                          alignment: AlignmentDirectional.topStart,
                          child: AppSubHeadings(
                            text: 'Topics',
                            size: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              children: [
                                ...List.generate(
                                  topics.length,
                                  (index) => Column(
                                    children: [
                                      TopicTile(title: topics[index]),
                                      if (index < topics.length - 1)
                                        const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _loadMoreTopics,
                                  child: const Text("Load More"),
                                ),
                              ],
                            ),
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
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontSize: 16,
      ),
      textAlign: TextAlign.left,
    );
  }
}

class RecentTile extends StatelessWidget {
  const RecentTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.grey,
      ),
      width: 200,
      height: 100,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  size: 16,
                ),
                SizedBox(
                  width: 10,
                ),
                AppSubHeadings(
                  text: 'Note Title',
                  size: 16,
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Lorem Ipsum is simply dummy text of the printing and types...',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
                Icon(
                  Icons.star,
                  size: 12,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TopicTile extends StatelessWidget {
  final String title;

  const TopicTile({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.grey,
      ),
      height: 140,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.topic,
                  size: 16,
                ),
                const SizedBox(
                  width: 10,
                ),
                AppSubHeadings(
                  text: title,
                  size: 16,
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scr...",
              maxLines: 3,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: List.generate(
                3,
                (index) => Row(
                  children: [
                    const Tag(),
                    if (index < 2) const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: 08:45 AM 24/04/2023',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
                Icon(
                  Icons.star,
                  size: 12,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 18,
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(5)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.topic,
              size: 10,
              color: AppColors.primary,
            ),
            Text(
              '3 Sub Topics',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
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

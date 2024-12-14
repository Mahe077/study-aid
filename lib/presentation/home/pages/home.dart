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
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/presentation/providers/recentItem_provider.dart';
import 'package:study_aid/features/search/presentation/providers/search_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

class HomePage extends ConsumerStatefulWidget {
  User user;

  HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _search = TextEditingController();
  final Map<String, String> sortOptions = {
    'updatedDate': 'Last Updated',
    'createdDate': 'Date Created',
    'title': 'Title',
  };
  String dropdownValue = 'updatedDate';

  void _loadMoreTopics() {
    Logger().d("_loadMoreTopics clicked");
    ref
        .read(
            topicsProvider(TopicParams(widget.user.id, dropdownValue)).notifier)
        .loadMoreTopics();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(topicsProvider(TopicParams(widget.user.id, dropdownValue))
              .notifier)
          .loadInitialTopics();
      ref
          .read(recentItemProvider(widget.user.id).notifier)
          .loadRecentItems(widget.user.id);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final userState = ref.watch(userProvider);
    final topicsState =
        ref.watch(topicsProvider(TopicParams(widget.user.id, dropdownValue)));
    final recentItemState = ref.watch(recentItemProvider(widget.user.id));
    final searchState = ref.watch(searchNotifireProvider);

    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        showMenu: true,
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: FAB(
        userId: widget.user.id,
        dropdownValue: dropdownValue,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: userState.when(
            data: (user) {
              return Column(
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
                              text: 'Hello ${user?.username ?? ''},',
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
                            : _buildSearchResults(
                                searchState.searchResults, dropdownValue)
                        : topicsState.when(
                            data: (state) {
                              setState(
                                () {
                                  if (state.topics.isNotEmpty) {
                                    widget.user = widget.user.copyWith(
                                      createdTopics: state.topics
                                          .map((topic) => topic.id)
                                          .toList(),
                                    );
                                  } else {
                                    widget.user =
                                        widget.user.copyWith(createdTopics: []);
                                  }
                                },
                              );
                              if (state.topics.isEmpty) {
                                return const EmptyHome();
                              }
                              return Column(
                                children: [
                                  recentItemState.when(
                                      data: (recentItems) {
                                        Logger().d(recentItems
                                            .recentItems.isEmpty
                                            .toString());
                                        if (recentItems.recentItems.isEmpty) {
                                          return Container();
                                        }
                                        return Column(
                                          children: [
                                            const Align(
                                              alignment:
                                                  AlignmentDirectional.topStart,
                                              child: AppSubHeadings(
                                                text: 'Recent Items',
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment:
                                                  AlignmentDirectional.topStart,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                clipBehavior: Clip.none,
                                                child: Row(
                                                  children: recentItems
                                                      .recentItems
                                                      .map((item) {
                                                    return Row(
                                                      children: [
                                                        RecentTile(
                                                          entity: item,
                                                          type: item is Topic
                                                              ? TopicType.topic
                                                              : item is Note
                                                                  ? TopicType
                                                                      .note
                                                                  : TopicType
                                                                      .audio,
                                                          userId:
                                                              widget.user.id,
                                                          parentTopicId:
                                                              item.parentId,
                                                          dropdownValue:
                                                              dropdownValue,
                                                        ),
                                                        const SizedBox(
                                                            width: 15),
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
                                      error: (error, stack) {
                                        Logger().e(error);
                                        return Container();
                                      }),
                                  Row(
                                    children: [
                                      Spacer(),
                                      Text(
                                        "Sort by :",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      DropdownButton<String>(
                                        dropdownColor: AppColors.white,
                                        isDense: true,
                                        borderRadius: BorderRadius.circular(8),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary,
                                          fontSize: 12,
                                        ),
                                        value: dropdownValue,
                                        onChanged: (newValue) {
                                          if (newValue != null
                                              // && newValue != dropdownValue
                                              ) {
                                            setState(() {
                                              dropdownValue =
                                                  newValue; // Update the value and rebuild the widget
                                            });
                                            ref.invalidate(tabDataProvider);
                                            Logger().d(
                                                "Sort value: $dropdownValue");
                                          }
                                        },
                                        items: sortOptions.entries.map((entry) {
                                          return DropdownMenuItem<String>(
                                            value: entry.key,
                                            child: Text(entry.value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
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
                                        for (int i = 0;
                                            i < state.topics.length;
                                            i++)
                                          Column(
                                            children: [
                                              ContentTile(
                                                // title: state.topics[i].title,
                                                userId: widget.user.id,
                                                entity: state.topics[i],
                                                type: TopicType.topic,
                                                parentTopicId: '',
                                                dropdownValue: dropdownValue,
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
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stack) {
                              Logger().e(error);
                              return Center(
                                  child: Text('Something went wrong'));
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          )),
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
                      .performSearch(query, widget.user.id);
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

  Widget _buildSearchResults(List<dynamic> results, String dropdownValue) {
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
            dropdownValue: dropdownValue,
          );
        } else if (item is AudioRecording) {
          return ContentTile(
            entity: item,
            type: TopicType.audio,
            userId: widget.user.id,
            parentTopicId: item.parentId,
            dropdownValue: dropdownValue,
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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                    children: [
                      const TextSpan(
                        text: 'Looks like you haven’t created anything yet.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                    children: [
                      const TextSpan(
                        text: 'If you’re new to the app, you need to create a ',
                      ),
                      const TextSpan(
                        text: 'Topic',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const TextSpan(
                        text:
                            ' first and then create sub topics, text and voice notes under the main topics.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                    children: [
                      TextSpan(
                        text:
                            'Click on the + button in the bottom left corner to create your first ',
                      ),
                      const TextSpan(
                        text: 'Topic',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: '.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

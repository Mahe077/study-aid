import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/common/widgets/tiles/content_tile.dart';
import 'package:study_aid/common/widgets/tiles/recent_tile.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/search/presentation/providers/search_provider.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

class TopicPage extends ConsumerStatefulWidget {
  final String topicTitle;
  final Topic entity;
  final String userId;

  const TopicPage({
    super.key,
    required this.topicTitle,
    required this.entity,
    required this.userId,
  });

  @override
  ConsumerState<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends ConsumerState<TopicPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  late TabController _tabController;
  late AudioPlayer _audioPlayer;
  bool _recordExists = false;
  final Map<String, String> sortOptions = {
    'createdDate': 'Date Created',
    'title': 'Title',
    'updatedDate': 'Last Updated',
  };
  String dropdownValue = 'updatedDate';

  StreamSubscription? _playerStateSubscription;

  List<AudioRecording> _audioQueue =
      []; // To hold the list of audio recordings to be played

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    _audioPlayer.dispose();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  int _currentAudioIndex = 0; // Track the current audio index

  void _playAllAudio(List<dynamic> audioList) async {
    _audioQueue = List.from(audioList); // Copy the list of audio recordings
    _currentAudioIndex = 0; // Reset index when a new list is set

    if (_audioQueue.isNotEmpty) {
      _playCurrentAudio(); // Start playing the first audio in the queue
      _showAudioBottomSheet(); // Show bottom sheet with playback controls
    }

    // Set up a listener to automatically play the next audio when one completes
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextAudio(); // Automatically play the next audio when one finishes
      }
    });
  }

// Function to play the current audio file based on _currentAudioIndex
  void _playCurrentAudio() async {
    if (_currentAudioIndex < 0 || _currentAudioIndex >= _audioQueue.length) {
      return;
    }

    final currentAudio =
        _audioQueue[_currentAudioIndex]; // Get the current audio by index

    try {
      await _audioPlayer.setUrl(currentAudio.localpath); // Load the audio URL
      _audioPlayer.play(); // Start playing
    } catch (e) {
      // Handle audio loading error
      Logger().e("Error playing audio: $e");
    }
  }

// Function to play the next audio in the queue
  void _playNextAudio() {
    if (_currentAudioIndex < _audioQueue.length - 1) {
      _currentAudioIndex++; // Move to the next audio
      _playCurrentAudio(); // Play the next audio
    } else {
      _audioPlayer.stop(); // Stop if at the end of the queue
    }
  }

// Function to play the previous audio in the queue
  void _playPreviousAudio() {
    if (_currentAudioIndex > 0) {
      _currentAudioIndex--; // Move to the previous audio
      _playCurrentAudio(); // Play the previous audio
    }
  }

// Bottom sheet showing playback info and control buttons
  void _showAudioBottomSheet() {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            final currentPosition = snapshot.data ?? Duration.zero;
            final totalDuration = _audioPlayer.duration ?? Duration.zero;
            final currentAudioName = _audioQueue[_currentAudioIndex].title;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _audioPlayer.stop();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    currentAudioName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Progress display
                  Text(
                    "${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration)}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),

                  // Progress bar
                  LinearProgressIndicator(
                    value: totalDuration.inMilliseconds > 0
                        ? currentPosition.inMilliseconds /
                            totalDuration.inMilliseconds
                        : 0.0,
                  ),
                  SizedBox(height: 16),

                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: _currentAudioIndex > 0
                            ? _playPreviousAudio
                            : null, // Enable if there's a previous audio
                      ),
                      IconButton(
                        icon: Icon(_audioPlayer.playing
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed: () {
                          if (_audioPlayer.playing) {
                            _audioPlayer.pause();
                          } else {
                            _audioPlayer.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: _currentAudioIndex < _audioQueue.length - 1
                            ? _playNextAudio
                            : null, // Enable if there's a next audio
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Utility function to format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final tabDataState = ref
        .watch(tabDataProvider(TabDataParams(widget.entity.id, dropdownValue)));
    final searchState = ref.watch(searchNotifireProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const BasicAppbar(showMenu: true),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: FAB(
          parentId: widget.entity.id,
          userId: widget.userId,
          topicTitle: widget.entity.title,
          topicColor: widget.entity.color,
          dropdownValue: dropdownValue,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              _buildHeadingSection(),
              Expanded(
                child: searchState.isSearchActive
                    ? searchState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSearchResults(
                            searchState.searchResults, dropdownValue)
                    : Column(
                        children: [
                          _buildRecentItemsSection(tabDataState, dropdownValue),
                          const SizedBox(height: 10),
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
                                  if (newValue != null &&
                                      newValue != dropdownValue) {
                                    setState(() {
                                      dropdownValue =
                                          newValue; // Update the value and rebuild the widget
                                    });
                                    ref.invalidate(tabDataProvider);
                                    Logger().d("Sort value: $dropdownValue");
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
                          // const SizedBox(height: 8),
                          _buildTabBar(),
                          const SizedBox(height: 8),
                          _buildTabView(tabDataState, dropdownValue),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeadings(
          text: "${widget.topicTitle},",
          alignment: TextAlign.left,
        ),
        const SizedBox(height: 10),
        _searchField(ref),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRecentItemsSection(
      AsyncValue<TabDataState> tabDataState, String dropdownvalue) {
    return tabDataState.when(
      data: (state) {
        final List<dynamic> items = [
          ...state.topics,
          ...state.notes,
          ...state.audioRecordings
        ];

        if (items.isEmpty) return Container();

        items.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

        final topFiveItems = items.take(5).toList();

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
                  children: topFiveItems.map((item) {
                    return Row(
                      children: [
                        RecentTile(
                          entity: item,
                          type: item is Topic
                              ? TopicType.topic
                              : item is Note
                                  ? TopicType.note
                                  : TopicType.audio,
                          userId: widget.userId,
                          parentTopicId: widget.entity.id,
                          dropdownValue: dropdownvalue,
                        ),
                        const SizedBox(width: 15),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        Logger().d(error);
        return const Center(child: Text("Something went wrong!"));
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: "All"),
        Tab(text: "Topic"),
        Tab(text: "Notes"),
        Tab(child: Text("Audio Clips")),
      ],
      isScrollable: true,
      unselectedLabelColor: AppColors.darkGrey,
      unselectedLabelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      labelColor: AppColors.primary,
      labelStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      indicator: const BoxDecoration(),
      dividerHeight: 0,
      tabAlignment: TabAlignment.center,
    );
  }

  Widget _buildTabView(
      AsyncValue<TabDataState> tabDataState, String dropdownvalue) {
    return Expanded(
      child: tabDataState.when(
        data: (state) {
          _recordExists = state.audioRecordings.length > 1;

          return TabBarView(
            controller: _tabController,
            children: [
              _contentList(
                  [...state.topics, ...state.notes, ...state.audioRecordings],
                  TopicType.all,
                  state.hasMoreTopics ||
                      state.hasMoreNotes ||
                      state.hasMoreAudio,
                  dropdownvalue),
              _contentList(state.topics, TopicType.topic, state.hasMoreTopics,
                  dropdownvalue),
              _contentList(state.notes, TopicType.note, state.hasMoreNotes,
                  dropdownvalue),
              _contentList(state.audioRecordings, TopicType.audio,
                  state.hasMoreAudio, dropdownvalue),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text("No item to show")),
      ),
    );
  }

  Widget _contentList(
      List<dynamic> items, TopicType type, bool hasMore, String dropdownvalue) {
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
      if (dropdownvalue == 'updatedDate') {
        filteredItems.sort(
            (a, b) => b.updatedDate.compareTo(a.updatedDate)); // Descending
      } else if (dropdownvalue == 'createdDate') {
        filteredItems.sort(
            (a, b) => b.createdDate.compareTo(a.createdDate)); // Descending
      } else if (dropdownvalue == 'title') {
        filteredItems.sort((a, b) => a.titleLowerCase
            .compareTo(b.titleLowerCase)); // Ascending alphabetical order
      }
    }

    return Column(
      children: [
        if (_recordExists && type == TopicType.audio) ...[
          _playAllButton(filteredItems),
          const SizedBox(height: 5),
        ],
        Expanded(
          child: ListView(
            children: [
              ...filteredItems.map((item) => Column(
                    children: [
                      ContentTile(
                        userId: widget.userId,
                        entity: item,
                        type: type,
                        parentTopicId: widget.entity.id,
                        dropdownValue: dropdownvalue,
                      ),
                      const SizedBox(height: 10),
                    ],
                  )),
              if (hasMore) _loadMoreButton(type, dropdownvalue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playAllButton(List<dynamic> audioRecordings) {
    final toast = CustomToast(context: context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(70, 15),
            padding: const EdgeInsets.all(2),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            if (audioRecordings.isNotEmpty) {
              _playAllAudio(audioRecordings); // Start playing all audio
            } else {
              toast.showInfo(
                  title: 'No audio files available.',
                  description:
                      'Please record or upload new audio to get started.');
            }
          },
          child: const Row(
            children: [
              Icon(Icons.play_arrow, size: 15, color: AppColors.icon),
              SizedBox(width: 5),
              Text(
                'Play All',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loadMoreButton(TopicType type, String dropdownvalue) {
    return ElevatedButton(
      onPressed: () {
        final notifier = ref.read(
            tabDataProvider(TabDataParams(widget.entity.id, dropdownvalue))
                .notifier);
        switch (type) {
          case TopicType.all:
            Logger().i("Load more ${TopicType.all}");
            notifier.loadAllDataMore(widget.entity.id);
            break;
          case TopicType.topic:
            Logger().i("Load more ${TopicType.topic}");
            notifier.loadMoreTopics(widget.entity.id);
            break;
          case TopicType.note:
            Logger().i("Load more ${TopicType.note}");
            notifier.loadMoreNotes(widget.entity.id);
            break;
          case TopicType.audio:
            Logger().i("Load more ${TopicType.audio}");
            notifier.loadMoreAudio(widget.entity.id);
            break;
        }
      },
      child: const Icon(Icons.keyboard_arrow_down, size: 25),
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
                      .performSearch(query, widget.userId);
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

  Widget _buildSearchResults(List<dynamic> results, dropdownValue) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
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
            userId: widget.userId,
            parentTopicId: widget.entity.id,
            dropdownValue: dropdownValue,
          );
        } else if (item is AudioRecording) {
          return ContentTile(
            entity: item,
            type: TopicType.audio,
            userId: widget.userId,
            parentTopicId: widget.entity.id,
            dropdownValue: dropdownValue,
          );
        }

        return const SizedBox
            .shrink(); // Handle unexpected item types gracefully
      },
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
          'Looks like you haven’t created anything yet. Click the button below to get started!',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

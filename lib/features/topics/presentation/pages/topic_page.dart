import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/bannerbars/info_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/fab.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/common/widgets/tiles/content_tile.dart';
import 'package:study_aid/common/widgets/tiles/recent_tile.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
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
    super.dispose();
  }

  // Function to play audio files in sequence
  void _playAllAudio(List<dynamic> audioList) async {
    _audioQueue = List.from(audioList); // Copy the list of audio recordings

    if (_audioQueue.isNotEmpty) {
      _playNextAudio(); // Start playing the first audio in the queue
    }
  }

  // Function to play the next audio file in the queue
  void _playNextAudio() async {
    if (_audioQueue.isEmpty) return; // If queue is empty, stop playing

    final currentAudio =
        _audioQueue.removeAt(0); // Get the first audio in the queue

    try {
      await _audioPlayer.setUrl(currentAudio.localpath); // Load the audio URL
      _audioPlayer.play(); // Start playing

      // Listen for when the current audio finishes
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _playNextAudio(); // Play the next audio when the current one finishes
        }
      });
    } catch (e) {
      // Handle audio loading error (e.g., log error, show message)
      Logger().e("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabDataState = ref.watch(tabDataProvider(widget.entity.id));

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
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              _buildHeadingSection(),
              Expanded(
                child: Column(
                  children: [
                    _buildRecentItemsSection(tabDataState),
                    const SizedBox(height: 10),
                    _buildTabBar(),
                    const SizedBox(height: 8),
                    _buildTabView(tabDataState),
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
        _searchField(),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRecentItemsSection(AsyncValue<TabDataState> tabDataState) {
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
                            parentTopicId: widget.entity.id),
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

  Widget _buildTabView(AsyncValue<TabDataState> tabDataState) {
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
                state.hasMoreTopics || state.hasMoreNotes || state.hasMoreAudio,
              ),
              _contentList(state.topics, TopicType.topic, state.hasMoreTopics),
              _contentList(state.notes, TopicType.note, state.hasMoreNotes),
              _contentList(
                  state.audioRecordings, TopicType.audio, state.hasMoreAudio),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text("No item to show")),
      ),
    );
  }

  Widget _contentList(List<dynamic> items, TopicType type, bool hasMore) {
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
                      ),
                      const SizedBox(height: 10),
                    ],
                  )),
              if (hasMore) _loadMoreButton(type),
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
              Icon(Icons.play_arrow, size: 10),
              SizedBox(width: 2),
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

  Widget _loadMoreButton(TopicType type) {
    return ElevatedButton(
      onPressed: () {
        final notifier = ref.read(tabDataProvider(widget.entity.id).notifier);
        switch (type) {
          case TopicType.all:
            Logger().i("Load more ${TopicType.all}");
            notifier.loadAllData(widget.entity.id);
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

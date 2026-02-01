import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
import 'package:study_aid/common/widgets/buttons/sync_button.dart';
import 'package:study_aid/features/files/presentation/widgets/files_list_view.dart';
import 'package:study_aid/features/notes/presentation/widgets/summarization_dialog.dart';

class TopicPage extends ConsumerStatefulWidget {
  final String topicTitle;
  final Topic entity;
  final String userId;
  final Color tileColor;

  const TopicPage({
    super.key,
    required this.topicTitle,
    required this.entity,
    required this.userId,
    required this.tileColor,
  });

  @override
  ConsumerState<TopicPage> createState() => _TopicPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _TopicPageState extends ConsumerState<TopicPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  late TabController _tabController;
  late AudioPlayer _audioPlayer;
  bool _recordExists = false;
  bool _noteExists = false;

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 0.6;
  double rate = 0.3;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

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
    _tabController = TabController(length: 5, vsync: this);
    _audioPlayer = AudioPlayer();
    initTts();
  }

  dynamic initTts() async {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Playing");
        }
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Complete");
        }
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Cancel");
        }
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Paused");
        }
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Continued");
        }
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        if (kDebugMode) {
          print("error: $msg");
        }
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      if (kDebugMode) {
        print(engine);
      }
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      if (kDebugMode) {
        print(voice);
      }
    }
  }

  Future<void> _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    _audioPlayer.dispose();
    _playerStateSubscription?.cancel();
    flutterTts.stop();
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
      await _audioPlayer
          .setFilePath(currentAudio.localpath); // Load the audio URL
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
      length: 5,
      child: Scaffold(
        appBar: BasicAppbar(
          showMenu: true,
          action: SyncButton(
            userId: widget.userId,
            onSyncComplete: () {
              ref.invalidate(tabDataProvider(
                  TabDataParams(widget.entity.id, dropdownValue)));
            },
          ),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: FAB(
          parentId: widget.entity.id,
          userId: widget.userId,
          topicTitle: widget.entity.title,
          topicColor: widget.entity.color,
          dropdownValue: dropdownValue,
          tileColor: widget.tileColor, // Use the reactive tileColor
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
          ...state.audioRecordings,
          ...state.files,
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
                                  : item is AudioRecording
                                      ? TopicType.audio
                                      : TopicType.file,
                          userId: widget.userId,
                          parentTopicId: widget.entity.id,
                          dropdownValue: dropdownvalue,
                          tileColor: widget.tileColor,
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
        Tab(text: "Files"),
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
          _noteExists = state.notes.isNotEmpty;

          return TabBarView(
            controller: _tabController,
            children: [
              _contentList(
                  [
                    ...state.topics,
                    ...state.notes,
                    ...state.audioRecordings,
                    ...state.files
                  ],
                  TopicType.all,
                  state.hasMoreTopics ||
                      state.hasMoreNotes ||
                      state.hasMoreAudio ||
                      state.hasMoreFiles,
                  dropdownvalue),
              _contentList(state.topics, TopicType.topic, state.hasMoreTopics,
                  dropdownvalue),
              _contentList(state.notes, TopicType.note, state.hasMoreNotes,
                  dropdownvalue),
              _contentList(state.audioRecordings, TopicType.audio,
                  state.hasMoreAudio, dropdownvalue),
              FilesListView(
                topicId: widget.entity.id,
                userId: widget.userId,
                sortBy: dropdownvalue,
                scrollController: ScrollController(),
                tileColor: widget.tileColor,
              ),
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

    final List<Map<String, String>> emptyTopicPageItems = [
      {
        "title": "Create a Note",
        "content":
            "Allows you to add a new note with textual or graphical data.",
      },
      {
        "title": "Record an Audio",
        "content":
            "With this you can create an audio recording with an option to transcribe what you speak.",
      },
      {
        "title": "Add an Image",
        "content":
            "You can directly create a new note with an image with just a couple of clicks.",
      },
      {
        "title": "Add a Sub Topic",
        "content":
            "If you prefer to have things more organized, here you can create a sub topic under the current topic. Inside that, you will have all these options again.",
      },
    ];

    if (type == TopicType.all && filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Looks like you haven’t created anything here.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Click on the + button in the bottom left corner to get started.",
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "It will provide you the following options.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: emptyTopicPageItems.length,
                  shrinkWrap: true, // Ensures it doesn’t take infinite height
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents scrolling inside the centered column
                  itemBuilder: (context, index) {
                    final item = emptyTopicPageItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${index + 1}. ",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['content'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type != TopicType.all && filteredItems.isEmpty) {
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
        if (_noteExists && type == TopicType.note) ...[
          if (TtsState.stopped != ttsState)
            // Show control row if TTS is playing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (TtsState.paused == ttsState)
                  IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        _speak();
                      }),
                if (TtsState.playing == ttsState || TtsState.continued == ttsState)
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    // Pause playback
                    _pause();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    // Stop playback completely
                    _stop();
                  },
                ),
              ],
            )
          else
            // Show play button if TTS is not playing or completed
          _playTTSButton(filteredItems),
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
                        tileColor: widget.tileColor,
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

  Widget _playTTSButton(List<dynamic> notes) {
    final toast = CustomToast(context: context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(115, 15),
            padding: const EdgeInsets.all(2),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            if (notes.isNotEmpty) {
              _playtts(notes); // Start playing all audio
            } else {
              toast.showInfo(
                  title: 'No audio files available.',
                  description:
                      'Please record or upload new audio to get started.');
            }
          },
          child: Row(
            children: [
              Icon(
                  (TtsState.playing == ttsState)
                      ? Icons.stop
                      : Icons.play_arrow,
                  size: 15,
                  color: AppColors.icon),
              const SizedBox(width: 5),
              const Text(
                'Text to speech',
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
          case TopicType.file:
            Logger().i("Load more ${TopicType.file}");
            notifier.loadMoreFiles(widget.entity.id);
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
            tileColor: widget.tileColor,
          );
        } else if (item is AudioRecording) {
          return ContentTile(
            entity: item,
            type: TopicType.audio,
            userId: widget.userId,
            parentTopicId: widget.entity.id,
            dropdownValue: dropdownValue,
            tileColor: widget.tileColor,
          );
        }

        return const SizedBox
            .shrink(); // Handle unexpected item types gracefully
      },
    );
  }

  void _playtts(List<dynamic> notes) async {
    if (TtsState.playing == ttsState) {
      _stop();
    } else {
      String newVoiceText = '';

      // Loop through each note and concatenate the content
      for (var note in notes) {
        if (note is Note && note.content.length > 1) {
          newVoiceText += 'Title, , ${note.title}, , , , , ';
          newVoiceText +=
              'Content, , ${note.content}, '; // Add note content to the newVoiceText string
        }
      }

      // Update the state once after the loop completes
      setState(() {
        _newVoiceText = newVoiceText;
      });

      // Now, speak the concatenated text
      _speak();
      // _showTtsBottomSheet();
    }
  }

  Widget _summarizeButton(List<dynamic> notes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(125, 15),
            padding: const EdgeInsets.all(2),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            if (notes.isNotEmpty) {
                 _showSummarizationDialog(notes);
            }
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.summarize, size: 15, color: AppColors.icon),
              SizedBox(width: 5),
              Text(
                'AI Summary',
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

  void _showSummarizationDialog(List<dynamic> notes) async {
    // Concatenate note contents
    String contentToSummarize = '';
    for (var note in notes) {
        if (note is Note) {
             contentToSummarize += "${note.title}\n${note.content}\n\n";
        }
    }
    
    if (contentToSummarize.trim().isEmpty) {
         CustomToast(context: context).showInfo(
            title: 'No content',
            description: 'There are no notes to summarize.');
        return;
    }
    
    final result = await showDialog(
      context: context,
      builder: (_) => SummarizationDialog(
          content: contentToSummarize,
          topicId: widget.entity.id,
          userId: widget.userId,
          title: 'Topic Summary: ${widget.topicTitle}',
          noteColor: widget.tileColor,
      ),
    );
    
    // Manually update the UI with the new note if created
    if (result is Note && mounted) {
       final notifier = ref.read(
           tabDataProvider(TabDataParams(widget.entity.id, dropdownValue)).notifier
       );
       notifier.updateNote(result);
    }
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

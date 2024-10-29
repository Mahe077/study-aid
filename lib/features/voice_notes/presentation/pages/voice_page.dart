import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/dialogs/dialogs.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';

class VoicePage extends ConsumerStatefulWidget {
  final String topicId;
  final String? topicTitle;
  final AudioRecording? entity;
  final Color? noteColor;
  final String userId;

  const VoicePage(
      {super.key,
      this.topicTitle,
      this.entity,
      this.noteColor,
      required this.topicId,
      required this.userId});

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage> {
  late final TextEditingController tagController;
  late final TextEditingController titleController;
  late final RecorderController recorderController;
  late final PlayerController playerController;
  late final AudioRecording audio;
  late final FocusNode focusNode;

  bool isRecording = false;
  bool isPaused = false;
  bool isLoading = true;
  bool isSaving = false;
  bool recodingInit = false;
  bool _doTranscribe = false;
  bool recordingStarted = false;
  bool isSaved = false;
  bool recordingEnded = false;
  List<double> waveformData = [];

  Duration recordedDuration = Duration.zero;
  StreamSubscription<Duration>? durationSubscription;

  String? path;
  String? musicFile;
  late String? recordPath;
  late Directory appDirectory;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entity?.title ?? '');
    tagController = TextEditingController();
    _getDir();
    _initialiseController();
    audio = widget.entity ?? getAudioRecording();

    focusNode = FocusNode();

    // Start listening to the recordedDuration stream
    durationSubscription =
        recorderController.onCurrentDuration.listen((duration) {
      setState(() {
        recordedDuration = duration;
      });
    });

    // Ensuring focus is requested after the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Logger().i("Requesting focus");
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    tagController.dispose();
    recorderController.dispose();
    focusNode.dispose();
    durationSubscription?.cancel(); // Stop listening to duration updates
    super.dispose();
  }

  // Function to generate a unique name if the user doesn't provide one
  String _generateUniqueName() {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$path/recording_$timeStamp.aac'; // Example: recording_1694959200.aac
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      path = appDirectory.path;
      isLoading = false;
    });
  }

  void _initialiseController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;

    playerController = PlayerController();
  }

  AudioRecording getAudioRecording() {
    return AudioRecording(
        id: UniqueKey().toString(),
        title: '',
        createdDate: DateTime.now(),
        color: widget.noteColor ?? AppColors.grey,
        remoteChangeTimestamp: DateTime.now(),
        tags: [],
        updatedDate: DateTime.now(),
        syncStatus: ConstantStrings.pending,
        localChangeTimestamp: DateTime.now(),
        url: '',
        localpath: '',
        parentId: widget.topicId);
  }

  void addTag(String tag) {
    if (tag.isNotEmpty) {
      tagController.clear();
      setState(() {
        audio.tags.add(tag);
      });
      // Navigator.of(context).pop();
    }
  }

  void _saveNote(BuildContext context, WidgetRef ref) {
    final toast = CustomToast(context: context);

    final audioTemp = AudioRecording(
        id: audio.id,
        title: titleController.text.trim(),
        createdDate: audio.createdDate,
        color: audio.color,
        remoteChangeTimestamp: DateTime.now(),
        tags: audio.tags,
        updatedDate: DateTime.now(),
        syncStatus: ConstantStrings.pending,
        localChangeTimestamp: DateTime.now(),
        url: '',
        localpath: recordPath ?? '',
        parentId: audio.parentId);

    Logger().i(audioTemp.toString());

    setState(() {
      isSaving = true;
    });

    final audioNotifier = ref.read(audioProvider(widget.topicId).notifier);
    var updateAudioRes = audioNotifier.createAudio(
        audioTemp, widget.topicId, widget.userId, _doTranscribe);

    if (!mounted) return;

    updateAudioRes.then((either) {
      setState(() {
        isSaving = false; // Stop loading once the operation completes
      });

      either.fold(
        (failure) {
          toast.showFailure(
              description: 'An error occurred while saving the audio clip.');
          Logger().d(failure.message);
        },
        (newNote) {
          if (!mounted) return;
          toast.showSuccess(description: 'Audio Clip updated successfully.');
          setState(() {
            isSaved = true;
          });
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        showMenu: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            AppHeadings(
                              text: widget.topicTitle ?? '',
                              alignment: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 5, 5, 10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                            color: widget.noteColor ?? AppColors.darkGrey,
                          ),
                          child: Column(
                            children: [
                              Row(children: [
                                Expanded(
                                  child: TextField(
                                    focusNode: focusNode,
                                    controller: titleController,
                                    decoration: const InputDecoration(
                                        isDense: true,
                                        icon: FaIcon(
                                            FontAwesomeIcons.microphone,
                                            size: 20),
                                        hintText: ' Enter audio title',
                                        hintStyle: TextStyle(
                                          color: AppColors.hintText,
                                        ),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        focusedBorder: InputBorder.none),
                                  ),
                                ),
                                if (recordingEnded) _saveButton(context),
                                const SizedBox(width: 2),
                                IconButton(
                                    visualDensity: VisualDensity.compact,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (!isSaving) _discardNote();
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 24,
                                    )),
                              ]),
                              Row(
                                children: [
                                  if (audio.tags.isNotEmpty)
                                    ...audio.tags.map((tag) => Row(
                                          children: [
                                            Tag(
                                                text: tag,
                                                onTap: () {
                                                  if (!isSaving) {
                                                    _confirmRemoveTag(tag);
                                                  }
                                                }),
                                            const SizedBox(width: 5),
                                          ],
                                        )),
                                  GestureDetector(
                                    onTap: () {
                                      if (!isSaving) _addTagDialog(context);
                                    },
                                    child: Container(
                                      height: 18,
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.add,
                                                size: 10,
                                                color: AppColors.primary),
                                            if (widget.entity?.tags ==
                                                null) ...[
                                              const SizedBox(width: 5),
                                              const Text(
                                                'Add a tag',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                  child: Center(
                                child: !recordingStarted
                                    ? const Text(
                                        "Click the record button below to start",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400))
                                    : !recordingEnded
                                        ? Column(
                                            children: [
                                              const Spacer(),
                                              AudioWaveforms(
                                                size: Size(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    70.0),
                                                recorderController:
                                                    recorderController,
                                                enableGesture: true,
                                                waveStyle: WaveStyle(
                                                  waveColor: AppColors.primary
                                                      .withOpacity(0.81),
                                                  extendWaveform: true,
                                                  showMiddleLine: false,
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 18),
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 10, 5),
                                              ),
                                              const SizedBox(height: 40),
                                              Text(
                                                recordedDuration.toHHMMSS(),
                                                style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              const SizedBox(height: 25),
                                            ],
                                          )
                                        : AudioFileWaveforms(
                                            size: Size(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                70.0),
                                            playerController: playerController,
                                            enableSeekGesture: true,
                                            waveformType: WaveformType.fitWidth,
                                            waveformData: waveformData,
                                            playerWaveStyle: PlayerWaveStyle(
                                              fixedWaveColor: AppColors.primary
                                                  .withOpacity(0.34),
                                              liveWaveColor: AppColors.primary
                                                  .withOpacity(0.81),
                                              spacing: 6,
                                            ),
                                            padding:
                                                const EdgeInsets.only(left: 18),
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 5, 10, 5),
                                            continuousWaveform: true,
                                          ),
                              )),
                              isRecording
                                  ? _pauseButton(_pauseRecording)
                                  : _recordButton(),
                              const SizedBox(height: 25),
                              isPaused
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          visualDensity: VisualDensity.compact,
                                          backgroundColor: AppColors.primary,
                                          iconColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      onPressed: () => _stopRecording(),
                                      child: const Text(
                                        'Complete Recording',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w500),
                                      ))
                                  : recordingStarted
                                      ? const SizedBox(height: 40)
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: _doTranscribe,
                                              onChanged: (bool? newValue) {
                                                setState(() {
                                                  _doTranscribe = newValue!;
                                                });
                                              },
                                              activeColor: AppColors.primary,
                                            ),
                                            const Text("Enable Transcribe",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ],
                                        ),
                              const SizedBox(height: 25)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  if (isSaving)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.black),
                    )
                ],
              ),
            ),
    );
  }

  GestureDetector _recordButton() {
    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        height: 84,
        width: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.34),
        ),
        child: Center(
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.81),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _pauseButton(Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 84,
        width: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.34),
        ),
        child: Center(
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.noteColor,
            ),
            child: Center(
                child: Icon(
              Icons.pause,
              size: 43,
              color: AppColors.primary.withOpacity(0.81),
            )),
          ),
        ),
      ),
    );
  }

  void _startRecording() async {
    if (recordingStarted && !isPaused) {
      // Show confirmation dialog
      bool discardConfirmed = await _showConfirmationDialog();

      if (discardConfirmed) {
        setState(() {
          recordingStarted = false;
        });
        await _startNewRecording(); // Wait for new recording to start
      } else {
        return; // User canceled the discard, so exit
      }
    } else {
      // If not recording or is paused, just start recording
      await _startNewRecording(); // Wait for new recording to start
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8)),
              // backgroundColor: AppColors.lightBackground,
              title: "Confirm Discard",
              content:
                  const Text('Are you sure you want to discard the recording?'),
              actions: <Widget>[
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.primary,
                        iconColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500),
                    )),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.grey,
                        iconColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500),
                    )),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed without selection
  }

  Future<void> _startNewRecording() async {
    Logger().d("Recording started");

    // Generate a unique file path for the new recording
    String filePath = _generateUniqueName();

    // Start recording
    await recorderController.record(path: filePath); // Await the Future

    // Update state to reflect recording status
    setState(() {
      isRecording = true;
      isPaused = false;
      recordingStarted = true;
      focusNode.unfocus();
    });
  }

  void _pauseRecording() async {
    Logger().d("recoding paused");
    await recorderController.pause();
    setState(() {
      isPaused = true;
      isRecording = false;
    });
  }

  void _stopRecording() async {
    Logger().d("recoding stoped");
    recordPath = await recorderController.stop(); // Stop recording
    if (recordPath != null) {
      setState(() {
        isRecording = false;
        isPaused = false;
        recordPath = recordPath!;
        recordingEnded = true;
      });

      waveformData = await playerController.extractWaveformData(
        path: recordPath ?? '',
        noOfSamples: 100,
      );
    }
    Logger().d("Recorded file path: $recordPath");
  }

  ElevatedButton _saveButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          visualDensity: VisualDensity.compact,
          fixedSize: const Size.fromHeight(10),
          backgroundColor: AppColors.primary,
          iconColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: () => isSaving ? () : _saveNote(context, ref),
      child: Row(
        children: [
          Icon(Icons.save, size: 17, color: AppColors.white),
          SizedBox(width: 5),
          Text(
            'Save',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.white,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  void _addTagDialog(BuildContext context) {
    showCustomDialog(
      context,
      DialogMode.add,
      'Tag',
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tagController,
            decoration: const InputDecoration(
              hintText: "Enter tag here",
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
          ),
        ],
      ),
      () => addTag(tagController.text.trim()),
    );
  }

  void _discardNote() {
    if (!isSaved) {
      showCustomDialog(context, DialogMode.gen, "Confirm Discard",
          const Text('Are you sure you want to discard changes?'), () {
        Navigator.of(context).pop();
        titleController.clear(); // Clear title on discard
      });
    } else {
      titleController.clear();
      Navigator.of(context).pop();
      Logger().w("not saved");
    }
  }

  void _confirmRemoveTag(String tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Tag'),
          content: Text('Are you sure you want to remove the tag "$tag"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  audio.tags.remove(tag);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tag "$tag" removed')),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}

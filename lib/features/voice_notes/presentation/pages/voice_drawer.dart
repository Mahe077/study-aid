import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

class ModalBottomSheet extends StatefulWidget {
  final AudioRecording entity;
  const ModalBottomSheet({super.key, required this.entity});

  @override
  State<ModalBottomSheet> createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  late PlayerController bottomSheetPlayerController;
  String? path;
  late Directory directory;

  void initState() {
    super.initState();
    _initialiseController();
    bottomSheetPlayerController.preparePlayer(path: widget.entity.localpath);
  }

  void _playandPause() async {
    bottomSheetPlayerController.playerState == PlayerState.playing
        ? await bottomSheetPlayerController.pausePlayer()
        : await bottomSheetPlayerController.startPlayer(
            finishMode: FinishMode.loop);
  }
  // @override
  // void initState() {
  //   super.initState();

  //   bottomSheetPlayerController = PlayerController();
  //   _preparePlayer(bottomSheetPlayerController, widget.entity.localpath);
  //   // playerStateSubscription =
  //   //     playerController?.onPlayerStateChanged.listen((_) {
  //   //   setState(() {});
  //   // });
  // }

  void _initialiseController() {
    bottomSheetPlayerController = PlayerController();
  }

  void _preparePlayer(PlayerController controller, String? localPath) async {
    try {
      if (localPath != null) {
        Logger().i("Audio file path: $localPath");
        File file = File(localPath);
        if (await file.exists()) {
          await controller.preparePlayer(
            path: file.toString(),
            shouldExtractWaveform: true,
            noOfSamples: 100,
            volume: 1.0,
          );
          Logger().i("Waveform Data: ${controller.waveformData}");
        } else {
          Logger().e("File does not exist at the provided path: $file");
        }
      }
    } catch (e) {
      Logger().e("Error preparing player: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a new instance of PlayerController for the BottomSheet

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.entity.color,
      ),
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(children: [
          Column(
            children: [
              _bottomSheetHeaderAction(context),
              AppSubHeadings(text: widget.entity.title, size: 18),
              const SizedBox(height: 8),
              Text(
                "Created: ${widget.entity?.createdDate}",
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              // Column(
              //   children: [
              //     FlutterLogo(
              //       size: 300,
              //       style: FlutterLogoStyle.stacked,
              //       textColor: _flag ? Colors.black : Colors.red,
              //     ),
              //     ElevatedButton(
              //       onPressed: () => setState(() => _flag = !_flag),
              //       child: Text('Change Color'),
              //     )
              //   ],
              // ),
              _bottomSheetTag(),
              const SizedBox(height: 20),
              _bottomSheedWaveForm(bottomSheetPlayerController),
              const SizedBox(height: 15),
              Text(bottomSheetPlayerController.maxDuration.toMMSS()),
              const SizedBox(height: 20),
              _playerButtonArray(bottomSheetPlayerController),
              const SizedBox(height: 20),
              _bottomSheetActionButtonArray(context)
            ],
          ),
        ]),
      ),
    );
  }

  Row _bottomSheetHeaderAction(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const FaIcon(
          FontAwesomeIcons.microphone,
          size: 20,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            size: 24,
          ),
        ),
      ],
    );
  }

  Row _bottomSheetActionButtonArray(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.black,
                iconColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Row(
              children: [
                Icon(
                  Icons.star,
                  size: 17,
                ),
                SizedBox(width: 5),
                Text(
                  'Remove from Favourite',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500),
                ),
              ],
            )),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.black,
                iconColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Row(
              children: [
                Icon(
                  Icons.delete,
                  size: 17,
                ),
                SizedBox(width: 5),
                Text(
                  'Delete',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500),
                ),
              ],
            )),
      ],
    );
  }

  Row _bottomSheetTag() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: (widget.entity.tags as List<dynamic>)
          .map<Widget>((tag) => Row(
                children: [
                  Tag(text: tag.toString()),
                  const SizedBox(width: 5),
                ],
              ))
          .toList(),
    );
  }

  AudioFileWaveforms _bottomSheedWaveForm(
      PlayerController bottomSheetPlayerController) {
    return AudioFileWaveforms(
      size: const Size(300, 40.0),
      playerController: bottomSheetPlayerController,
      enableSeekGesture: true,
      waveformType: WaveformType.fitWidth,
      // waveformData: bottomSheetPlayerController.waveformData,
      playerWaveStyle: PlayerWaveStyle(
        fixedWaveColor: AppColors.primary.withOpacity(0.81),
        liveWaveColor: AppColors.primary.withOpacity(0.34),
        spacing: 6,
      ),
    );
  }

  Row _playerButtonArray(PlayerController bottomSheetPlayerController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _seekButton(
            bottomSheetPlayerController, widget.entity.localpath, false),
        const SizedBox(width: 30),
        _playButton(bottomSheetPlayerController, widget.entity.localpath),
        const SizedBox(width: 30),
        _seekButton(bottomSheetPlayerController, widget.entity.localpath, true),
      ],
    );
  }

  GestureDetector _pauseButton(PlayerController playerController) {
    return GestureDetector(
      onTap: () => _pausePlayer(playerController),
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
              color: widget.entity.color,
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

  GestureDetector _playButton(
      PlayerController playerController, String recordPath) {
    return playerController.playerState == PlayerState.playing
        ? _bottomSheetPauseButton(playerController)
        : _bottomSheetPlayButton(playerController, recordPath);
  }

  GestureDetector _bottomSheetPauseButton(PlayerController playerController) {
    return GestureDetector(
      onTap: () => _playandPause,
      child: Container(
        height: 46,
        width: 46,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Center(
          child: Icon(Icons.pause, size: 43, color: widget.entity.color),
        ),
      ),
    );
  }

  GestureDetector _bottomSheetPlayButton(
      PlayerController playerController, String recordPath) {
    return GestureDetector(
      onTap: () => _playandPause,
      child: Container(
        height: 46,
        width: 46,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Center(
          child: Icon(Icons.play_arrow, size: 43, color: widget.entity.color),
        ),
      ),
    );
  }

  GestureDetector _seekButton(
      PlayerController playerController, String recordPath, bool forward) {
    return forward
        ? GestureDetector(
            // onTap: () => _startPlayer(playerController, recordPath),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.seek.withOpacity(0.72)),
              child: Center(
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.entity.color,
                  ),
                  child: Center(
                    child: Icon(Icons.fast_forward_outlined,
                        size: 19, color: AppColors.seek.withOpacity(0.72)),
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: () => _seekPlayer(playerController, forward),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.seek.withOpacity(0.72)),
              child: Center(
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.entity.color,
                  ),
                  child: Center(
                      child: Transform.rotate(
                    angle: 3.14159, // 180 degrees in radians
                    child: Icon(
                      Icons.fast_forward_outlined,
                      size: 19,
                      color: AppColors.seek.withOpacity(0.72),
                    ),
                  )),
                ),
              ),
            ),
          );
  }

  void _startPlayer(
      PlayerController playerController, String recordPath) async {
    // await playerController.preparePlayer(
    //   path: recordPath,
    //   shouldExtractWaveform: true,
    //   noOfSamples: 100,
    //   volume: 1.0,
    // );
    setState(() {}); // This triggers the rebuild after starting the player
    await playerController.startPlayer(finishMode: FinishMode.stop);
    Logger().d("Player started");

    // Listen for player state changes and update UI accordingly
    playerController.onPlayerStateChanged.listen((PlayerState state) {
      // If the player finished playing, reset the playFlag
      if (state == PlayerState.stopped) {
        setState(() {});
      }
      setState(() {}); // Trigger rebuild when player state changes
    });
  }

  void _seekPlayer(PlayerController playerController, bool forward) async {
    forward
        ? await playerController.seekTo(10)
        : await playerController.seekTo(-10);
  }

  void _pausePlayer(PlayerController playerController) async {
    Logger().d("Player paused");
    await playerController.pausePlayer();
    setState(() {}); // Trigger rebuild to show the play button
  }
}

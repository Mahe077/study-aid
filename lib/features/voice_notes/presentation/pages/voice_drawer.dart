import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/bannerbars/failure_bannerbar.dart';
import 'package:study_aid/common/widgets/bannerbars/success_bannerbar.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';

class ModalBottomSheet extends ConsumerStatefulWidget {
  final AudioRecording entity;
  final String userId;
  final String parentId;
  const ModalBottomSheet(
      {super.key,
      required this.entity,
      required this.userId,
      required this.parentId});

  @override
  ConsumerState<ModalBottomSheet> createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends ConsumerState<ModalBottomSheet> {
  late PlayerController bottomSheetPlayerController;
  String? path;
  late Directory directory;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initialiseController();

    if (widget.entity.localpath.isNotEmpty) {
      // Prepare the player only if the path is valid
      bottomSheetPlayerController.preparePlayer(path: widget.entity.localpath);

      // Listen for player state changes
      _playerStateSubscription = bottomSheetPlayerController
          .onPlayerStateChanged
          .listen((PlayerState state) {
        if (mounted) {
          setState(() {});
        } // Update the UI based on player state changes
      });
    } else {
      // Log or handle the case where the path is not yet available
      Logger().e("Audio path is null or empty");
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel(); // Cancel the subscription
    bottomSheetPlayerController.dispose();
    super.dispose();
  }

  void _playandPause() async {
    if (bottomSheetPlayerController.playerState == PlayerState.playing) {
      await bottomSheetPlayerController.pausePlayer();
    } else {
      await bottomSheetPlayerController.startPlayer(
          finishMode: FinishMode.pause);
    }
    setState(() {});
  }

  void _initialiseController() {
    bottomSheetPlayerController = PlayerController();
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
                "Created: ${widget.entity.createdDate}",
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              _bottomSheetTag(),
              const SizedBox(height: 20),
              _bottomSheedWaveForm(bottomSheetPlayerController),
              const SizedBox(height: 15),
              Text(formatDuration(bottomSheetPlayerController.maxDuration)),
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

  String formatDuration(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
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
            onPressed: () => _confirmDelete(),
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

  void _confirmDelete() {
    final toast = CustomToast(context: context);
    showCustomDialog(context, DialogMode.delete, "Confirm Delete",
        const Text('Are you sure you want to delete this item?'), () async {
      final audioRecordingNotifier =
          ref.read(audioProvider(widget.entity.id).notifier);

      // Stop the player before deleting the audio
      if (bottomSheetPlayerController.playerState == PlayerState.playing ||
          bottomSheetPlayerController.playerState == PlayerState.paused) {
        await bottomSheetPlayerController.stopPlayer();
      }

      try {
        Logger()
            .i("Voice_Drawer:: deleting the audio item ${widget.entity.id}");
        audioRecordingNotifier.deleteAudio(
            widget.parentId, widget.entity.id, widget.userId);
        toast.showWarning(description: "Audio clip deleted successfully.");
      } catch (e) {
        toast.showFailure(
            description: "An error occurred while deleting the audio clip.");
        Logger().d(e);
      } finally {
        Navigator.of(context).pop();
      }
    });
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

  GestureDetector _playButton(
      PlayerController playerController, String recordPath) {
    return playerController.playerState == PlayerState.playing
        ? _bottomSheetPauseButton(playerController)
        : _bottomSheetPlayButton(playerController, recordPath);
  }

  GestureDetector _bottomSheetPauseButton(PlayerController playerController) {
    return GestureDetector(
      onTap: () => _playandPause(),
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
      onTap: () => _playandPause(),
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

  void _seekPlayer(PlayerController playerController, bool forward) async {
    final currentPos = await playerController.getDuration(DurationType.current);
    final newPos =
        forward ? currentPos + 10000 : currentPos - 10000; // Seek 10 seconds
    await playerController
        .seekTo(newPos.clamp(0, playerController.maxDuration));
  }
}

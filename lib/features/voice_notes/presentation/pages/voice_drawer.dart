import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
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

  const ModalBottomSheet({
    super.key,
    required this.entity,
    required this.userId,
    required this.parentId,
  });

  @override
  ConsumerState<ModalBottomSheet> createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends ConsumerState<ModalBottomSheet> {
  late PlayerController bottomSheetPlayerController;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  var waveformData;

  @override
  void initState() {
    super.initState();
    _initialiseController();
  }

  Future<void> _initialiseController() async {
    bottomSheetPlayerController = PlayerController();

    if (widget.entity.localpath.isNotEmpty) {
      await bottomSheetPlayerController.preparePlayer(
          path: widget.entity.localpath);
      _playerStateSubscription =
          bottomSheetPlayerController.onPlayerStateChanged.listen((_) {
        if (mounted) setState(() {});
      });

      // Get waveform data asynchronously
      try {
        final waveStyle = PlayerWaveStyle();
        final samples = waveStyle.getSamplesForWidth(300.0);
        waveformData = await bottomSheetPlayerController.extractWaveformData(
            path: widget.entity.localpath, noOfSamples: samples);

        if (mounted) setState(() {});
      } catch (e) {
        Logger().e("Error extracting waveform data: $e");
      }
    } else {
      Logger().e("Audio path is null or empty");
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    bottomSheetPlayerController.dispose();
    super.dispose();
  }

  void _playAndPause() async {
    if (bottomSheetPlayerController.playerState == PlayerState.playing) {
      await bottomSheetPlayerController.pausePlayer();
    } else {
      await bottomSheetPlayerController.startPlayer(
          finishMode: FinishMode.pause);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: widget.entity.color,
      ),
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: waveformData == null
            ? Center(child: CircularProgressIndicator(color: AppColors.white))
            : Column(
                children: [
                  _buildHeader(context),
                  AppSubHeadings(text: widget.entity.title, size: 18),
                  const SizedBox(height: 8),
                  Text("Created: ${widget.entity.createdDate}",
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  _buildTags(),
                  const SizedBox(height: 20),
                  _buildWaveform(),
                  const SizedBox(height: 15),
                  Text(formatDuration(bottomSheetPlayerController.maxDuration)),
                  const SizedBox(height: 20),
                  _buildPlayerControls(),
                  Spacer(),
                  _buildActionButtons(context),
                  const SizedBox(height: 20)
                ],
              ),
      ),
    );
  }

  String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Row _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const FaIcon(FontAwesomeIcons.microphone, size: 20),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Row _buildTags() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: (widget.entity.tags as List<dynamic>)
          .map<Widget>((tag) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Tag(text: tag.toString()),
              ))
          .toList(),
    );
  }

  AudioFileWaveforms _buildWaveform() {
    return AudioFileWaveforms(
      size: const Size(300.0, 40.0),
      playerController: bottomSheetPlayerController,
      enableSeekGesture: true,
      waveformType: WaveformType.fitWidth,
      waveformData: waveformData,
      playerWaveStyle: PlayerWaveStyle(
        fixedWaveColor: AppColors.primary.withOpacity(0.81),
        liveWaveColor: AppColors.primary.withOpacity(0.34),
        spacing: 6,
        seekLineColor: Colors.white,
      ),
      continuousWaveform: true,
    );
  }

  Row _buildPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSeekButton(false),
        const SizedBox(width: 30),
        _buildPlayButton(),
        const SizedBox(width: 30),
        _buildSeekButton(true),
      ],
    );
  }

  GestureDetector _buildPlayButton() {
    return GestureDetector(
      onTap: _playAndPause,
      child: Container(
        height: 46,
        width: 46,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.primary),
        child: Center(
          child: Icon(
            bottomSheetPlayerController.playerState == PlayerState.playing
                ? Icons.pause
                : Icons.play_arrow,
            size: 43,
            color: widget.entity.color,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildSeekButton(bool forward) {
    return GestureDetector(
      onTap: () => _seekPlayer(forward),
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: AppColors.seek.withOpacity(0.72)),
        child: Center(
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: widget.entity.color),
            child: Center(
              child: Transform.rotate(
                angle: forward ? 0 : 3.14159, // 3.14159 radians is 180 degrees
                child: Icon(
                  Icons.fast_forward_outlined,
                  size: 19,
                  color: AppColors.seek.withOpacity(0.72),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(context, Icons.star, 'Remove from Favourite',
            _removeFromFavourites),
        const SizedBox(width: 10),
        _buildActionButton(context, Icons.delete, 'Delete', _confirmDelete),
      ],
    );
  }

  ElevatedButton _buildActionButton(BuildContext context, IconData icon,
      String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.icon),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final toast = CustomToast(context: context);
    showCustomDialog(
      context,
      DialogMode.delete,
      "Confirm Delete",
      const Text('Are you sure you want to delete this item?'),
      () async {
        // Stop the player before deleting the audio
        if (bottomSheetPlayerController.playerState == PlayerState.playing ||
            bottomSheetPlayerController.playerState == PlayerState.paused) {
          await bottomSheetPlayerController.stopPlayer();
        }
        await ref
            .read(audioProvider(widget.entity.id).notifier)
            .deleteAudio(widget.parentId, widget.entity.id, widget.userId);
        toast.showWarning(description: "Audio clip deleted successfully.");
        Navigator.pop(context);
      },
    );
  }

  Future<void> _removeFromFavourites() async {
    // Implement the logic to remove from favourites
    Logger().i('Removing from favourites: ${widget.entity.id}');
  }

  void _seekPlayer(bool forward) async {
    final seekAmount = forward ? 1000 : -1000; // Adjust for seconds
    final currentPosition =
        await bottomSheetPlayerController.getDuration(DurationType.current);
    final newPosition = currentPosition + seekAmount;
    bottomSheetPlayerController
        .seekTo(newPosition.clamp(0, bottomSheetPlayerController.maxDuration));
  }
}

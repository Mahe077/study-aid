import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/utils/app_logger.dart';
import '../../domain/models/tts_config.dart';
import '../../domain/models/tts_state.dart';
import '../providers/tts_provider.dart';
import '../providers/tts_settings_provider.dart';

/// Widget for displaying and controlling TTS playback
class TtsPlayerWidget extends ConsumerWidget {
  final String noteTitle;
  final VoidCallback? onClose;

  const TtsPlayerWidget({
    super.key,
    required this.noteTitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(ttsPlaybackProvider);
    final settings = ref.watch(ttsSettingsProvider);
    final notifier = ref.read(ttsPlaybackProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          _buildHeader(context, noteTitle, playbackState),
          const SizedBox(height: 12),

          // Progress bar
          _buildProgressBar(context, playbackState),
          const SizedBox(height: 4),

          // Chunk indicator
          // _buildChunkIndicator(context, playbackState),
          // const SizedBox(height: 16),

          // Buffering indicator (between chunks)
          if (playbackState.isLoading && !playbackState.isPlaying) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Buffering next section...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Playback controls
          _buildPlaybackControls(context, notifier, playbackState),
          const SizedBox(height: 12),

          // // Settings controls
          // _buildSettingsControls(context, ref, settings, notifier),

          // Error message
          if (playbackState.hasError) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(context, playbackState, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, TtsState state) {
    String statusText;
    if (state.isLoading) {
      statusText = 'Preparing audio...';
    } else if (state.isCompleted) {
      statusText = 'Completed: "$title"';
    } else {
      statusText = 'Reading: "$title"';
    }

    return Row(
      children: [
        const Icon(Icons.headphones, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onClose != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, TtsState state) {
    final hasChunks = state.totalChunks > 0;
    final chunkProgress = state.totalDuration.inMilliseconds > 0
        ? state.currentPosition.inMilliseconds / state.totalDuration.inMilliseconds
        : 0.0;
    final overallProgress = hasChunks
        ? (state.currentChunkIndex + chunkProgress) / state.totalChunks
        : 0.0;
    final overallPosition = state.cumulativeCompletedDuration + state.currentPosition;
    final overallDuration = state.estimatedTotalDuration > Duration.zero
        ? state.estimatedTotalDuration
        : state.totalDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: overallProgress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(overallPosition),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _formatDuration(overallDuration),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChunkIndicator(BuildContext context, TtsState state) {
    if (state.totalChunks <= 1) return const SizedBox.shrink();

    return Text(
      'Chunk ${state.currentChunkIndex + 1} of ${state.totalChunks}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    TtsPlaybackNotifier notifier,
    TtsState state,
  ) {
    final isEffectivelyCompleted = state.isCompleted ||
        (state.totalDuration > Duration.zero &&
            state.currentPosition >= state.totalDuration &&
            !state.isPlaying);
    final canControl = state.isPlaying || state.isPaused || isEffectivelyCompleted;
    final showSpinner = state.isLoading &&
        !state.isPlaying &&
        !state.isPaused &&
        state.currentPosition == Duration.zero;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Restart button
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: canControl ? () => notifier.restart() : null,
          tooltip: 'Restart',
        ),

        // Seek backward button
        IconButton(
          icon: const Icon(Icons.replay_10_sharp),
          onPressed: canControl ? () => notifier.seekBackward() : null,
          tooltip: 'Rewind 15s',
        ),

        // Play/Pause button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: showSpinner
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  iconSize: 48,
                  icon: Icon(
                    state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  ),
                  onPressed: () {
                    if (isEffectivelyCompleted) {
                      notifier.restart();
                    } else {
                      notifier.togglePlayPause();
                    }
                  },
                  color: Theme.of(context).primaryColor,
                  tooltip: state.isPlaying
                      ? 'Pause'
                      : (isEffectivelyCompleted ? 'Replay' : 'Play'),
                ),
        ),

        // Seek forward button
        IconButton(
          icon: const Icon(Icons.forward_10),
          onPressed: canControl ? () => notifier.seekForward() : null,
          tooltip: 'Forward 15s',
        ),

        // Next chunk button (if applicable)
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: canControl ? () => notifier.seekForward() : null,
          tooltip: 'Next section',
        ),
      ],
    );
  }

  Widget _buildSettingsControls(
    BuildContext context,
    WidgetRef ref,
    TtsConfig settings,
    TtsPlaybackNotifier notifier,
  ) {
    return Row(
      children: [
        // Speed selector
        Expanded(
          child: Row(
            children: [
              const Text('Speed: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<double>(
                  value: settings.speed,
                  isExpanded: true,
                  items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                    return DropdownMenuItem(
                      value: speed,
                      child: Text('${speed}x'),
                    );
                  }).toList(),
                  onChanged: (speed) {
                    if (speed != null) {
                      notifier.changeSpeed(speed);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    TtsState state,
    TtsPlaybackNotifier notifier,
  ) {
    final message = (state.errorMessage == null || state.errorMessage!.isEmpty)
        ? 'Something went wrong. Please try again.'
        : state.errorMessage!;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => notifier.retry(),
            child: const Text('Try again'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => notifier.clearError(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

}

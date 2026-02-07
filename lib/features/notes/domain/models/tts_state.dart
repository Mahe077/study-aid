/// Status of TTS playback
enum TtsStatus {
  idle,
  loading,
  playing,
  paused,
  completed,
  error;
}

/// State of TTS playback
class TtsState {
  final TtsStatus status;
  final String? noteId;
  final int currentChunkIndex;
  final int totalChunks;
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration cumulativeCompletedDuration;
  final Duration estimatedTotalDuration;
  final String? errorMessage;

  const TtsState({
    this.status = TtsStatus.idle,
    this.noteId,
    this.currentChunkIndex = 0,
    this.totalChunks = 0,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.cumulativeCompletedDuration = Duration.zero,
    this.estimatedTotalDuration = Duration.zero,
    this.errorMessage,
  });

  bool get isPlaying => status == TtsStatus.playing;
  bool get isPaused => status == TtsStatus.paused;
  bool get isLoading => status == TtsStatus.loading;
  bool get hasError => status == TtsStatus.error;
  bool get isIdle => status == TtsStatus.idle;
  bool get isCompleted => status == TtsStatus.completed;

  TtsState copyWith({
    TtsStatus? status,
    String? noteId,
    int? currentChunkIndex,
    int? totalChunks,
    Duration? currentPosition,
    Duration? totalDuration,
    Duration? cumulativeCompletedDuration,
    Duration? estimatedTotalDuration,
    String? errorMessage,
  }) {
    return TtsState(
      status: status ?? this.status,
      noteId: noteId ?? this.noteId,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      totalChunks: totalChunks ?? this.totalChunks,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      cumulativeCompletedDuration:
          cumulativeCompletedDuration ?? this.cumulativeCompletedDuration,
      estimatedTotalDuration:
          estimatedTotalDuration ?? this.estimatedTotalDuration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  TtsState clearError() {
    return copyWith(
      status: TtsStatus.idle,
      errorMessage: '',
    );
  }

  @override
  String toString() {
    return 'TtsState(status: $status, noteId: $noteId, chunk: $currentChunkIndex/$totalChunks, '
        'position: ${currentPosition.inSeconds}s/${totalDuration.inSeconds}s, '
        'overall: ${cumulativeCompletedDuration.inSeconds}s/${estimatedTotalDuration.inSeconds}s)';
  }
}

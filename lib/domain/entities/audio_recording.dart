class AudioRecordingEntity {
  final String? id;
  final String title;
  final String audioUrl; // Assuming audio is stored as a URL

  AudioRecordingEntity({
    this.id,
    required this.title,
    required this.audioUrl,
  });
}

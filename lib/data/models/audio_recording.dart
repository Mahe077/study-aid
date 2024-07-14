class AudioRecordingModel {
  final String id;
  final String title;
  final String audioUrl; // Assuming audio is stored as a URL

  AudioRecordingModel({
    required this.id,
    required this.title,
    required this.audioUrl,
  });

  factory AudioRecordingModel.fromJson(Map<String, dynamic> json) {
    return AudioRecordingModel(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audioUrl': audioUrl,
    };
  }
}

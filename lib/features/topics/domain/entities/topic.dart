class Topic {
  final String id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<String> subTopics;
  final List<String> notes;
  final List<String> audioRecordings;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.updatedDate,
    required this.subTopics,
    required this.notes,
    required this.audioRecordings,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });
}

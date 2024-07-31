class Note {
  final String id;
  final String title;
  final List<String> tags;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String content;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  Note({
    required this.id,
    required this.title,
    required this.tags,
    required this.createdDate,
    required this.updatedDate,
    required this.content,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });
}

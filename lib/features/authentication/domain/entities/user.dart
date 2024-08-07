class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<String> createdTopics;
  final String syncStatus;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.updatedDate,
    required this.createdTopics,
    required this.syncStatus,
  });

  User copyWith(
      {String? id,
      String? name,
      String? email,
      DateTime? createdDate,
      DateTime? updatedDate,
      List<String>? createdTopics,
      List<String>? subTopics,
      String? syncStatus}) {
    return User(
        id: id ?? this.id,
        username: name ?? this.username,
        email: email ?? this.email,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        createdTopics: createdTopics ?? this.createdTopics,
        syncStatus: syncStatus ?? this.syncStatus);
  }
}

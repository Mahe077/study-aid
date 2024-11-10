class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<String> createdTopics;
  final String syncStatus;
  final List<Map<String, dynamic>> recentItems;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.updatedDate,
    required this.createdTopics,
    required this.syncStatus,
    required this.recentItems,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<String>? createdTopics,
    List<String>? subTopics,
    String? syncStatus,
    List<Map<String, dynamic>>? recentItems,
  }) {
    return User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        createdTopics: createdTopics ?? this.createdTopics,
        syncStatus: syncStatus ?? this.syncStatus,
        recentItems: recentItems ?? this.recentItems);
  }
}

class MetdaData {
  final String reference;
  final DateTime updatedDate;
  MetdaData(this.reference, this.updatedDate);
}

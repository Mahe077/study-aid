import 'dart:ui';

class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<String> createdTopics;
  final String syncStatus;
  final List<Map<String, dynamic>> recentItems;
  final Color color;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.updatedDate,
    required this.createdTopics,
    required this.syncStatus,
    required this.recentItems,
    required this.color,
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
    Color? color,
  }) {
    return User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        createdTopics: createdTopics ?? this.createdTopics,
        syncStatus: syncStatus ?? this.syncStatus,
        recentItems: recentItems ?? this.recentItems,
        color: color ?? this.color);
  }
}

class MetdaData {
  final String reference;
  final DateTime updatedDate;
  MetdaData(this.reference, this.updatedDate);
}

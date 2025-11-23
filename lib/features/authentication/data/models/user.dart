import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel extends User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final DateTime createdDate;
  @HiveField(4)
  final DateTime updatedDate;
  @HiveField(5)
  final List<String> createdTopics;
  @HiveField(6)
  final String syncStatus;
  @HiveField(7)
  final List<Map<String, dynamic>>
      recentItems; // Updated to hold item ID and type
  @HiveField(8)
  final Color color;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.updatedDate,
    required this.createdTopics,
    required this.syncStatus,
    required this.recentItems, // Added recentItems to the constructor
    required this.color,
  }) : super(
            id: id,
            username: username,
            email: email,
            createdDate: createdDate,
            updatedDate: updatedDate,
            createdTopics: createdTopics,
            syncStatus: syncStatus,
            recentItems: recentItems,
            color: color);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      updatedDate: (data['updatedDate'] as Timestamp).toDate(),
      createdTopics: List<String>.from(data['createdTopics'] ?? []),
      syncStatus: data['syncStatus'] ?? '',
      recentItems: List<Map<String, dynamic>>.from(
          data['recentItems'] ?? []), // Initialize recentItems
      color: Color(data['color']),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      createdDate: user.createdDate,
      updatedDate: user.updatedDate,
      createdTopics: user.createdTopics,
      syncStatus: user.syncStatus,
      recentItems: user.recentItems, // Initialize recentItems if it's null
      color: user.color,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'createdTopics': createdTopics,
      'syncStatus': syncStatus,
      'recentItems': recentItems, // Add recentItems to the Firestore map
      'color': color.value,
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<String>? createdTopics,
    List<String>? subTopics,
    String? syncStatus,
    List<Map<String, dynamic>>? recentItems, // Added recentItems to copyWith
    Color? color,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdTopics: createdTopics ?? this.createdTopics,
      syncStatus: syncStatus ?? this.syncStatus,
      recentItems:
          recentItems ?? this.recentItems, // Handle recentItems in copyWith
      color: color ?? this.color,
    );
  }

  User toDomain() {
    return User(
      id: id,
      username: username,
      email: email,
      createdDate: createdDate,
      updatedDate: updatedDate,
      createdTopics: createdTopics,
      syncStatus: syncStatus,
      recentItems: recentItems,
      color: color,
    );
  }
}

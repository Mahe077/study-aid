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

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.updatedDate,
    required this.createdTopics,
  }) : super(
          id: id,
          username: username,
          email: email,
          createdDate: createdDate,
          updatedDate: updatedDate,
          createdTopics: createdTopics,
        );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      updatedDate: (data['updatedDate'] as Timestamp).toDate(),
      createdTopics: List<String>.from(data['createdTopics'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'createdTopics': createdTopics,
    };
  }
}

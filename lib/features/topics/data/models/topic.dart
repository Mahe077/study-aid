import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';

part 'topic.g.dart';

@HiveType(typeId: 1)
class TopicModel extends Topic {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final Color color;
  @HiveField(4)
  final DateTime createdDate;
  @HiveField(5)
  final DateTime updatedDate;
  @HiveField(6)
  final List<String> subTopics;
  @HiveField(7)
  final List<String> notes;
  @HiveField(8)
  final List<String> audioRecordings;
  @HiveField(9)
  final String syncStatus;
  @HiveField(10)
  final DateTime localChangeTimestamp;
  @HiveField(11)
  final DateTime remoteChangeTimestamp;
  @HiveField(12)
  final String parentId;
  @HiveField(13)
  final String titleLowerCase;
  @HiveField(14)
  final String userId;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.createdDate,
    required this.updatedDate,
    required this.subTopics,
    required this.notes,
    required this.audioRecordings,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
    required this.parentId,
    required this.titleLowerCase,
    required this.userId,
  }) : super(
          id: id,
          title: title,
          description: description,
          color: color,
          createdDate: createdDate,
          updatedDate: updatedDate,
          subTopics: subTopics,
          notes: notes,
          audioRecordings: audioRecordings,
          syncStatus: syncStatus,
          localChangeTimestamp: localChangeTimestamp,
          remoteChangeTimestamp: remoteChangeTimestamp,
          parentId: parentId,
          titleLowerCase: titleLowerCase,
          userId: userId,
        );

  factory TopicModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TopicModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      color: Color(data['color']),
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      updatedDate: (data['updatedDate'] as Timestamp).toDate(),
      subTopics: List<String>.from(data['subTopics']),
      notes: List<String>.from(data['notes']),
      audioRecordings: List<String>.from(data['audioRecordings']),
      syncStatus: data['syncStatus'],
      localChangeTimestamp:
          (data['localChangeTimestamp'] as Timestamp).toDate(),
      remoteChangeTimestamp:
          (data['remoteChangeTimestamp'] as Timestamp).toDate(),
      parentId: data['parentId'],
      titleLowerCase: data['titleLowerCase'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color.value,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'subTopics': subTopics,
      'notes': notes,
      'audioRecordings': audioRecordings,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
      'parentId': parentId,
      'titleLowerCase': titleLowerCase,
      'userId': userId,
    };
  }

  TopicModel copyWith({
    String? id,
    String? title,
    String? description,
    Color? color,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<String>? subTopics,
    List<String>? notes,
    List<String>? audioRecordings,
    String? syncStatus,
    DateTime? localChangeTimestamp,
    DateTime? remoteChangeTimestamp,
    String? parentId,
    String? titleLowerCase,
    String? userId,
  }) {
    return TopicModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      subTopics: subTopics ?? this.subTopics,
      notes: notes ?? this.notes,
      audioRecordings: audioRecordings ?? this.audioRecordings,
      syncStatus: syncStatus ?? this.syncStatus,
      localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
      remoteChangeTimestamp:
          remoteChangeTimestamp ?? this.remoteChangeTimestamp,
      parentId: parentId ?? this.parentId,
      titleLowerCase: titleLowerCase ?? this.titleLowerCase,
      userId: userId ?? this.userId,
    );
  }

  factory TopicModel.fromDomain(Topic topic) {
    return TopicModel(
      id: topic.id,
      title: topic.title,
      color: topic.color,
      syncStatus: topic.syncStatus,
      description: topic.description,
      createdDate: topic.createdDate,
      updatedDate: topic.updatedDate,
      subTopics: topic.subTopics,
      notes: topic.notes,
      audioRecordings: topic.audioRecordings,
      localChangeTimestamp: topic.localChangeTimestamp,
      remoteChangeTimestamp: topic.remoteChangeTimestamp,
      parentId: topic.parentId,
      titleLowerCase: topic.titleLowerCase,
      userId: topic.userId,
    );
  }

  Topic toDomain() {
    return Topic(
      id: id,
      title: title,
      color: color,
      syncStatus: syncStatus,
      description: description,
      createdDate: createdDate,
      updatedDate: updatedDate,
      subTopics: subTopics,
      notes: notes,
      audioRecordings: audioRecordings,
      localChangeTimestamp: localChangeTimestamp,
      remoteChangeTimestamp: remoteChangeTimestamp,
      parentId: parentId,
      titleLowerCase: titleLowerCase,
      userId: userId,
    );
  }
}

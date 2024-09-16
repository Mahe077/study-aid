import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteModel {
  final String id;
  final String title;
  // @HiveField(3)
  final Color color;
  final List<String> tags;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String content;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  NoteModel({
    required this.id,
    required this.title,
    required this.color,
    required this.tags,
    required this.createdDate,
    required this.updatedDate,
    required this.content,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: data['id'],
      title: data['title'],
      color: Color(data['color']),
      tags: List<String>.from(data['tags']),
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      updatedDate: (data['updatedDate'] as Timestamp).toDate(),
      content: data['content'],
      syncStatus: data['syncStatus'],
      localChangeTimestamp:
          (data['localChangeTimestamp'] as Timestamp).toDate(),
      remoteChangeTimestamp:
          (data['remoteChangeTimestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'tags': tags,
      'color': color.value,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'content': content,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
    };
  }
}

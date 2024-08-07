import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AudioRecordingModel {
  final String id;
  final String title;
  final Color color;
  final List<String> tags;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String url;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  AudioRecordingModel({
    required this.id,
    required this.title,
    required this.color,
    required this.tags,
    required this.createdDate,
    required this.updatedDate,
    required this.url,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });

  factory AudioRecordingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AudioRecordingModel(
      id: data['id'],
      title: data['title'],
      color: Color(data['color']),
      tags: List<String>.from(data['tags']),
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      updatedDate: (data['updatedDate'] as Timestamp).toDate(),
      url: data['url'],
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
      'color': color.value,
      'tags': tags,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'url': url,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
    };
  }
}

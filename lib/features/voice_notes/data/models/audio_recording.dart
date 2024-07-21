import 'package:cloud_firestore/cloud_firestore.dart';

class AudioRecordingModel {
  final String title;
  final String uniqueId;
  final List<String> tags;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String url;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  AudioRecordingModel({
    required this.title,
    required this.uniqueId,
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
      title: data['title'],
      uniqueId: data['uniqueId'],
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
      'title': title,
      'uniqueId': uniqueId,
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

class TopicModel {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<String> subTopics;
  final List<String> notes;
  final List<String> audioRecordings;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.createdDate,
    required this.updatedDate,
    required this.subTopics,
    required this.notes,
    required this.audioRecordings,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });

  factory TopicModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TopicModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      tags: List<String>.from(data['tags']),
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'subTopics': subTopics,
      'notes': notes,
      'audioRecordings': audioRecordings,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
    };
  }
}

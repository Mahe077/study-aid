// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

part 'audio_recording.g.dart';

@HiveType(typeId: 4)
class AudioRecordingModel extends AudioRecording {
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final Color color;
  @HiveField(4)
  final List<String> tags;
  @HiveField(5)
  final DateTime createdDate;
  @HiveField(6)
  final DateTime updatedDate;
  @HiveField(7)
  final String url;
  @HiveField(8)
  final String localpath;
  @HiveField(9)
  final String syncStatus;
  @HiveField(10)
  final DateTime localChangeTimestamp;
  @HiveField(11)
  final DateTime remoteChangeTimestamp;

  AudioRecordingModel(
      {required this.id,
      required this.title,
      required this.color,
      required this.tags,
      required this.createdDate,
      required this.updatedDate,
      required this.url,
      required this.syncStatus,
      required this.localChangeTimestamp,
      required this.remoteChangeTimestamp,
      required this.localpath})
      : super(
            id: id,
            title: title,
            color: color,
            tags: tags,
            createdDate: createdDate,
            updatedDate: updatedDate,
            url: url,
            localpath: localpath,
            syncStatus: syncStatus,
            localChangeTimestamp: localChangeTimestamp,
            remoteChangeTimestamp: remoteChangeTimestamp);

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
      localpath: data['localpath'],
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
      'localpath': localpath,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
    };
  }

  @override
  AudioRecordingModel copyWith({
    String? id,
    String? title,
    Color? color,
    List<String>? tags,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? url,
    String? localpath,
    String? syncStatus,
    DateTime? localChangeTimestamp,
    DateTime? remoteChangeTimestamp,
  }) {
    return AudioRecordingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      url: url ?? this.url,
      localpath: url ?? this.localpath,
      syncStatus: syncStatus ?? this.syncStatus,
      localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
      remoteChangeTimestamp:
          remoteChangeTimestamp ?? this.remoteChangeTimestamp,
    );
  }

  factory AudioRecordingModel.fromDomain(AudioRecording audio) {
    return AudioRecordingModel(
        id: audio.id,
        title: audio.title,
        color: audio.color,
        tags: audio.tags,
        createdDate: audio.createdDate,
        updatedDate: audio.updatedDate,
        url: audio.url,
        syncStatus: audio.syncStatus,
        localChangeTimestamp: audio.localChangeTimestamp,
        remoteChangeTimestamp: audio.remoteChangeTimestamp,
        localpath: audio.localpath);
  }
  AudioRecording toDomain() {
    return AudioRecording(
        id: id,
        title: title,
        color: color,
        tags: tags,
        createdDate: createdDate,
        updatedDate: updatedDate,
        url: url,
        localpath: localpath,
        syncStatus: syncStatus,
        localChangeTimestamp: localChangeTimestamp,
        remoteChangeTimestamp: remoteChangeTimestamp);
  }
}

import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';

class Topic extends BaseEntity {
  @override
  final String id;
  final String title;
  final String description;
  final Color color;
  final DateTime createdDate;
  @override
  final DateTime updatedDate;
  final List<String> subTopics;
  final List<String> notes;
  final List<String> audioRecordings;
  final List<String> files;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;
  final String parentId;
  final String titleLowerCase;
  final String userId;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.createdDate,
    required this.updatedDate,
    required this.subTopics,
    required this.notes,
    required this.audioRecordings,
    required this.files,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
    required this.parentId,
    required this.titleLowerCase,
    required this.userId,
  });

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    Color? color,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<String>? subTopics,
    List<String>? notes,
    List<String>? audioRecordings,
    List<String>? files,
    String? syncStatus,
    DateTime? localChangeTimestamp,
    DateTime? remoteChangeTimestamp,
    String? parentId,
    String? titleLowerCase,
    String? userId,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      subTopics: subTopics ?? this.subTopics,
      notes: notes ?? this.notes,
      audioRecordings: audioRecordings ?? this.audioRecordings,
      files: files ?? this.files,
      syncStatus: syncStatus ?? this.syncStatus,
      localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
      remoteChangeTimestamp:
          remoteChangeTimestamp ?? this.remoteChangeTimestamp,
      parentId: parentId ?? this.parentId,
      titleLowerCase: titleLowerCase ?? this.titleLowerCase,
      userId: userId ?? this.userId,
    );
  }
}

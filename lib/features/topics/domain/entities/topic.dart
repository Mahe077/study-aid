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
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;
  final String parentId;
  final String titleLowerCase;

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
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
    required this.parentId,
    required this.titleLowerCase,
  });
}

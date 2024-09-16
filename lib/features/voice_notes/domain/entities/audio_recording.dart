import 'package:flutter/material.dart';

class AudioRecording {
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

  AudioRecording({
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
}

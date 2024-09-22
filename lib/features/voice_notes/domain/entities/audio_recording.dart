// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:study_aid/core/utils/helpers/custome_types.dart';

class AudioRecording extends BaseEntity {
  @override
  final String id;
  final String title;
  final Color color;
  final List<String> tags;
  final DateTime createdDate;
  @override
  final DateTime updatedDate;
  final String url;
  final String localpath;
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
    required this.localpath,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });

  AudioRecording copyWith({
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
    return AudioRecording(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      url: url ?? this.url,
      localpath: localpath ?? this.localpath,
      syncStatus: syncStatus ?? this.syncStatus,
      localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
      remoteChangeTimestamp:
          remoteChangeTimestamp ?? this.remoteChangeTimestamp,
    );
  }
}

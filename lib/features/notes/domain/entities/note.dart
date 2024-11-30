import 'package:flutter/material.dart';

import 'package:study_aid/core/utils/helpers/custome_types.dart';

class Note extends BaseEntity {
  @override
  final String id;
  final String title;
  final Color color;
  final List<String> tags;
  final DateTime createdDate;
  @override
  final DateTime updatedDate;
  final String content;
  final String contentJson;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;
  final String parentId;
  final String titleLowerCase;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.color,
    required this.tags,
    required this.createdDate,
    required this.updatedDate,
    required this.content,
    required this.contentJson,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
    required this.parentId,
    required this.titleLowerCase,
    required this.userId,
  });

  Note copyWith({
    String? id,
    String? title,
    Color? color,
    List<String>? tags,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? content,
    String? contentJson,
    String? syncStatus,
    DateTime? localChangeTimestamp,
    DateTime? remoteChangeTimestamp,
    String? parentId,
    String? titleLowerCase,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      content: content ?? this.content,
      contentJson: contentJson ?? this.contentJson,
      syncStatus: syncStatus ?? this.syncStatus,
      localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
      remoteChangeTimestamp:
          remoteChangeTimestamp ?? this.remoteChangeTimestamp,
      parentId: parentId ?? this.parentId,
      titleLowerCase: titleLowerCase ?? this.titleLowerCase,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'color': color.value,
      'tags': tags,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'content': content,
      'contentJson': contentJson,
      'syncStatus': syncStatus,
      'localChangeTimestamp': localChangeTimestamp.millisecondsSinceEpoch,
      'remoteChangeTimestamp': remoteChangeTimestamp.millisecondsSinceEpoch,
      'parentId': parentId,
      'titleLowerCase': titleLowerCase,
      'userId': userId,
    };
  }

  List<dynamic> toList() {
    return [
      id,
      title,
      color.value,
      tags,
      createdDate.millisecondsSinceEpoch,
      updatedDate.millisecondsSinceEpoch,
      content,
      contentJson,
      syncStatus,
      localChangeTimestamp.millisecondsSinceEpoch,
      remoteChangeTimestamp.millisecondsSinceEpoch,
      parentId,
      titleLowerCase,
      userId
    ];
  }
}

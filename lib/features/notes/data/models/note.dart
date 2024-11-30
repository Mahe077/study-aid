import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';

part 'note.g.dart';

@HiveType(typeId: 3)
class NoteModel extends Note {
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
  final String content;
  @HiveField(8)
  final String contentJson;
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

  NoteModel({
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
  }) : super(
            id: id,
            title: title,
            color: color,
            tags: tags,
            createdDate: createdDate,
            updatedDate: updatedDate,
            content: content,
            contentJson: contentJson,
            syncStatus: syncStatus,
            localChangeTimestamp: localChangeTimestamp,
            remoteChangeTimestamp: remoteChangeTimestamp,
            parentId: parentId,
            titleLowerCase: titleLowerCase);

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
        contentJson: data['contentJson'],
        syncStatus: data['syncStatus'],
        localChangeTimestamp:
            (data['localChangeTimestamp'] as Timestamp).toDate(),
        remoteChangeTimestamp:
            (data['remoteChangeTimestamp'] as Timestamp).toDate(),
        parentId: data['parentId'],
        titleLowerCase: data['titleLowerCase']);
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
      'contentJson': contentJson,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
      'parentId': parentId,
      'titleLowerCase': titleLowerCase
    };
  }

  @override
  NoteModel copyWith(
      {final String? id,
      final String? title,
      final Color? color,
      final List<String>? tags,
      final DateTime? createdDate,
      final DateTime? updatedDate,
      final String? content,
      final String? contentJson,
      final String? syncStatus,
      final DateTime? localChangeTimestamp,
      final DateTime? remoteChangeTimestamp,
      final String? parentId,
      final String? titleLowerCase}) {
    return NoteModel(
        id: id ?? this.id,
        title: title ?? this.title,
        tags: tags ?? this.tags,
        color: color ?? this.color,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        content: content ?? this.content,
        contentJson: contentJson ?? this.contentJson,
        syncStatus: syncStatus ?? this.syncStatus,
        localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
        remoteChangeTimestamp:
            remoteChangeTimestamp ?? this.remoteChangeTimestamp,
        parentId: parentId ?? this.parentId,
        titleLowerCase: titleLowerCase ?? this.titleLowerCase);
  }

  factory NoteModel.fromDomain(Note note) {
    return NoteModel(
        id: note.id,
        title: note.title,
        color: note.color,
        tags: note.tags,
        createdDate: note.createdDate,
        updatedDate: note.updatedDate,
        content: note.content,
        contentJson: note.contentJson,
        syncStatus: note.syncStatus,
        localChangeTimestamp: note.localChangeTimestamp,
        remoteChangeTimestamp: note.remoteChangeTimestamp,
        parentId: note.parentId,
        titleLowerCase: note.titleLowerCase);
  }

  Note toDomain() {
    return Note(
        id: id,
        title: title,
        color: color,
        tags: tags,
        createdDate: createdDate,
        updatedDate: updatedDate,
        content: content,
        contentJson: contentJson,
        syncStatus: syncStatus,
        localChangeTimestamp: localChangeTimestamp,
        remoteChangeTimestamp: remoteChangeTimestamp,
        parentId: parentId,
        titleLowerCase: titleLowerCase);
  }
}

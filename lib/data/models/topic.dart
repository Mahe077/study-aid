import 'package:study_aid/data/models/audio_recording.dart';
import 'package:study_aid/data/models/note.dart';
import 'package:study_aid/domain/entities/audio_recording.dart';
import 'package:study_aid/domain/entities/note.dart';
import 'package:study_aid/domain/entities/topic.dart';

class TopicModel {
  final String id;
  final String title;
  final List<NoteModel> notes;
  final List<AudioRecordingModel> audioRecordings;

  TopicModel({
    required this.id,
    required this.title,
    this.notes = const [],
    this.audioRecordings = const [],
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      title: json['title'],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      audioRecordings: (json['audioRecordings'] as List<dynamic>?)
              ?.map((e) =>
                  AudioRecordingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes.map((note) => note.toJson()).toList(),
      'audioRecordings':
          audioRecordings.map((recording) => recording.toJson()).toList(),
    };
  }
}

extension TopicModelX on TopicModel {
  TopicEntity toEntity() {
    return TopicEntity(
      id: id,
      title: title,
      //   notes: notes as List<dynamic>?)
      //           ?.map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
      //           .toList() ??
      //       [],
      //   audioRecordings: (audioRecordings as List<dynamic>?)
      //           ?.map((e) =>
      //               AudioRecordingModel.fromJson(e as Map<String, dynamic>))
      //           .toList() ??
      //       [],
    );
  }
}

import 'package:study_aid/domain/entities/audio_recording.dart';
import 'package:study_aid/domain/entities/note.dart';

class TopicEntity {
  final String? id;
  final String title;
  final List<TopicEntity>? topics;
  final List<NoteEntity>? notes;
  final List<AudioRecordingEntity>? audioRecordings;

  TopicEntity({
    this.id,
    required this.title,
    this.topics = const [],
    this.notes = const [],
    this.audioRecordings = const [],
  });
}

// example_data.dart
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart'; // Import if needed

// Sample Note
final Note sampleNote = Note(
  title: 'Sample Note',
  id: 'note123',
  tags: ['tag1', 'tag2'],
  createdDate: DateTime.now(),
  updatedDate: DateTime.now(),
  content: 'This is a sample note content.',
  syncStatus: 'synced',
  localChangeTimestamp: DateTime.now(),
  remoteChangeTimestamp: DateTime.now(),
);

// Sample AudioRecording
final AudioRecording sampleAudio = AudioRecording(
  title: 'Sample Audio',
  id: 'audio123',
  tags: ['audioTag1', 'audioTag2'],
  createdDate: DateTime.now(),
  updatedDate: DateTime.now(),
  url: 'https://example.com/audio.mp3',
  syncStatus: 'synced',
  localChangeTimestamp: DateTime.now(),
  remoteChangeTimestamp: DateTime.now(),
);

// Sample Topic
final Topic sampleTopic = Topic(
  title: 'Sample Topic',
  description: 'This is a sample topic description.',
  createdDate: DateTime.now(),
  updatedDate: DateTime.now(),
  subTopics: ['subtopic1', 'subtopic2'],
  notes: [sampleNote.id],
  audioRecordings: [sampleAudio.id],
  syncStatus: 'synced',
  localChangeTimestamp: DateTime.now(),
  remoteChangeTimestamp: DateTime.now(),
  id: 'Topic 1',
);

// List of recent entities
final List<dynamic> recent = [sampleTopic, sampleNote, sampleAudio];

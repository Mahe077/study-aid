// example_data.dart
import 'package:study_aid/domain/entities/note.dart';
import 'package:study_aid/domain/entities/audio_recording.dart';
import 'package:study_aid/domain/entities/topic.dart';

List<TopicEntity> exampleTopicEntitys = [
  TopicEntity(
    id: 'TopicEntity1',
    title: 'Introduction to Flutter',
    topics: [
      TopicEntity(
        id: 'TopicEntity2',
        title: 'Dart Programming Language',
        notes: [
          NoteEntity(
            id: 'NoteEntity3',
            title: 'Variables and Data Types',
            content: 'Learn about Dart variables and various data types.',
          ),
        ],
        audioRecordings: [],
      ),
    ],
    notes: [
      NoteEntity(
        id: 'NoteEntity1',
        title: 'Widgets in Flutter',
        content: 'Flutter uses widgets to build UI components.',
      ),
      NoteEntity(
        id: 'NoteEntity2',
        title: 'State Management',
        content: 'Different approaches to manage state in Flutter apps.',
      ),
    ],
    audioRecordings: [
      AudioRecordingEntity(
        id: 'audio1',
        title: 'Introduction to Flutter',
        audioUrl: 'https://example.com/audio1.mp3',
      ),
    ],
  ),
  TopicEntity(
    id: 'TopicEntity2',
    title: 'Dart Programming Language',
    notes: [
      NoteEntity(
        id: 'NoteEntity3',
        title: 'Variables and Data Types',
        content: 'Learn about Dart variables and various data types.',
      ),
    ],
    audioRecordings: [],
  ),
  TopicEntity(
    id: 'TopicEntity3',
    title: 'Firebase Integration',
    notes: [
      NoteEntity(
        id: 'NoteEntity4',
        title: 'Firestore Database',
        content: 'Using Firestore to store and retrieve data in Flutter apps.',
      ),
    ],
    audioRecordings: [
      AudioRecordingEntity(
        id: 'audio2',
        title: 'Firebase Authentication',
        audioUrl: 'https://example.com/audio2.mp3',
      ),
    ],
  ),
];

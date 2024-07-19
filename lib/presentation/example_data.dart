// example_data.dart
import 'package:study_aid/domain/entities/note.dart';
import 'package:study_aid/domain/entities/audio_recording.dart';
import 'package:study_aid/domain/entities/topic.dart';

List<TopicEntity> exampleTopicEntitys = [
  TopicEntity(
    id: 'TopicEntity1',
    title: 'Introduction to Flutter',
    description: 'Dart Programming Language',
    subTopics: [
      TopicEntity(
        id: 'TopicEntity2',
        title: 'Dart Programming Language',
        description: 'Dart Programming Language',
        notes: [
          NoteEntity(
            id: 'NoteEntity3',
            title: 'Variables and Data Types',
            content: 'Learn about Dart variables and various data types.',
            createdAt: DateTime(2024, 7, 16, 10, 30),
            updatedAt: DateTime(2024, 7, 16, 10, 30),
          ),
        ],
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    notes: [
      NoteEntity(
        id: 'NoteEntity1',
        title: 'Widgets in Flutter',
        content: 'Flutter uses widgets to build UI components.',
        tags: ['Widgets', "UI"],
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
      NoteEntity(
        id: 'NoteEntity2',
        title: 'State Management',
        content: 'Different approaches to manage state in Flutter apps.',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    audioRecordings: [
      AudioRecordingEntity(
        id: 'audio1',
        title: 'Introduction to Flutter',
        audioUrl: 'https://example.com/audio1.mp3',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
  TopicEntity(
    id: 'TopicEntity2',
    title: 'Dart Programming Language',
    description: 'Dart Programming Language',
    notes: [
      NoteEntity(
        id: 'NoteEntity3',
        title: 'Variables and Data Types',
        content: 'Learn about Dart variables and various data types.',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
  TopicEntity(
    id: 'TopicEntity3',
    title: 'Firebase Integration',
    description: 'Dart Programming Language',
    notes: [
      NoteEntity(
        id: 'NoteEntity4',
        title: 'Firestore Database',
        content: 'Using Firestore to store and retrieve data in Flutter apps.',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    audioRecordings: [
      AudioRecordingEntity(
        id: 'audio2',
        title: 'Firebase Authentication',
        audioUrl: 'https://example.com/audio2.mp3',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
];

List<dynamic> recent = [
  TopicEntity(
    id: 'TopicEntity1',
    title: 'Introduction to Flutter',
    description: 'Dart Programming Language',
    subTopics: [
      TopicEntity(
        id: 'TopicEntity2',
        title: 'Dart Programming Language',
        description: 'Dart Programming Language',
        notes: [
          NoteEntity(
            id: 'NoteEntity3',
            title: 'Variables and Data Types',
            content: 'Learn about Dart variables and various data types.',
            createdAt: DateTime(2024, 7, 16, 10, 30),
            updatedAt: DateTime(2024, 7, 16, 10, 30),
          ),
        ],
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    notes: [
      NoteEntity(
        id: 'NoteEntity1',
        title: 'Widgets in Flutter',
        content: 'Flutter uses widgets to build UI components.',
        tags: ['Widgets', "UI"],
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
      NoteEntity(
        id: 'NoteEntity2',
        title: 'State Management',
        content: 'Different approaches to manage state in Flutter apps.',
        tags: [],
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    audioRecordings: [
      AudioRecordingEntity(
        id: 'audio1',
        title: 'Introduction to Flutter',
        audioUrl: 'https://example.com/audio1.mp3',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
  TopicEntity(
    id: 'TopicEntity2',
    title: 'Dart Programming Language',
    description: 'Dart Programming Language',
    notes: [
      NoteEntity(
        id: 'NoteEntity3',
        title: 'Variables and Data Types',
        content: 'Learn about Dart variables and various data types.',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
  TopicEntity(
    id: 'TopicEntity3',
    title: 'Firebase Integration',
    description: 'Dart Programming Language',
    notes: [
      NoteEntity(
        id: 'NoteEntity4',
        title: 'Firestore Database',
        content: 'Using Firestore to store and retrieve data in Flutter apps.',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    audioRecordings: [
      AudioRecordingEntity(
        id: 'audio2',
        title: 'Firebase Authentication',
        audioUrl: 'https://example.com/audio2.mp3',
        createdAt: DateTime(2024, 7, 16, 10, 30),
        updatedAt: DateTime(2024, 7, 16, 10, 30),
      ),
    ],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
  AudioRecordingEntity(
    id: 'audio2',
    title: 'Firebase Authentication',
    audioUrl: 'https://example.com/audio2.mp3',
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
  NoteEntity(
    id: 'NoteEntity4',
    title: 'Firestore Database',
    content: 'Using Firestore to store and retrieve data in Flutter apps.',
    tags: [],
    createdAt: DateTime(2024, 7, 16, 10, 30),
    updatedAt: DateTime(2024, 7, 16, 10, 30),
  ),
];

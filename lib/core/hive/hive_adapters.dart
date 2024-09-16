import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/notes/data/models/note_type_adapter.dart';
import 'package:study_aid/features/topics/data/models/color_type_adapter.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';

class HiveAdapters {
  static void registerAdapters() {
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ColorAdapter());
    Hive.registerAdapter(TopicModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());
  }
}

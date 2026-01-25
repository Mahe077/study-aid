// lib/core/utils/hive/hive_boxes.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';
import 'package:study_aid/features/files/data/models/file_model.dart';

class HiveBoxes {
  static Future<void> openBoxes() async {
    if (!Hive.isBoxOpen('userBox')) {
      await Hive.openBox<UserModel>('userBox');
    }

    if (!Hive.isBoxOpen('topicBox')) {
      await Hive.openBox<TopicModel>('topicBox');
    }

    if (!Hive.isBoxOpen('fileBox')) {
      await Hive.openBox<FileModel>('fileBox');
    }
  }
}

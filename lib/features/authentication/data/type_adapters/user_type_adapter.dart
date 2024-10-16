import 'package:hive/hive.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0; // Ensure this is unique for each adapter

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
        id: reader.read(),
        username: reader.read(),
        email: reader.read(),
        createdDate: reader.read(),
        updatedDate: reader.read(),
        createdTopics: reader.readList().cast<String>(),
        syncStatus: reader.read(),
        recentItems: reader.readList().cast<Map<String, dynamic>>());
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..write(obj.id)
      ..write(obj.username)
      ..write(obj.email)
      ..write(obj.createdDate)
      ..write(obj.updatedDate)
      ..writeList(obj.createdTopics)
      ..write(obj.syncStatus)
      ..writeList(obj.recentItems);
  }
}

import 'package:hive/hive.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';

abstract class LocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser(String id);
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<UserModel> userBox;

  LocalDataSourceImpl(this.userBox);

  @override
  Future<void> cacheUser(UserModel user) async {
    await userBox.put(user.id, user);
  }

  @override
  Future<UserModel?> getCachedUser(String id) async {
    return userBox.get(id);
  }
}

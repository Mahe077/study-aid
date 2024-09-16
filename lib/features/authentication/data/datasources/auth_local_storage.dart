import 'package:hive/hive.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';

abstract class LocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser(String id);
  Future<void> clearUser();
  Future<void> updateUser(User user);
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<UserModel> _userBox;

  LocalDataSourceImpl(this._userBox);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _userBox.put(user.id, user);
  }

  @override
  Future<void> clearUser() async {
    await _userBox.clear();
  }

  @override
  Future<UserModel?> getCachedUser(String id) async {
    return _userBox.get(id);
  }

  @override
  Future<void> updateUser(User user) {
    return _userBox.put(user.id, UserModel.fromEntity(user));
  }
}

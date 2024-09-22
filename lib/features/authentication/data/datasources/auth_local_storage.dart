import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
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
    try {
      await _userBox.put(user.id, user);
      // Fetch the user from the box to print it
      final cachedUser = await _userBox.get(user.id);
      Logger().d('Cached user: $cachedUser');
    } catch (e) {
      // Handle or log error
      Logger().e('Error caching user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser(String id) async {
    try {
      return _userBox.get(id);
    } catch (e) {
      // Handle or log error
      Logger().e('Error getting cached user: $e');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _userBox.clear();
    } catch (e) {
      // Handle or log error
      Logger().d('Error clearing user box: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _userBox.put(user.id, UserModel.fromEntity(user));
    } catch (e) {
      // Handle or log error
      Logger().e('Error updating user: $e');
    }
  }
}

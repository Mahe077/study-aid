import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return await _fetchUser();
  }

  Future<UserModel?> _fetchUser() async {
    try {
      Logger().d("Trying to open userBox...");

      // Open the box if it's not already open
      final userBox = Hive.isBoxOpen('userBox')
          ? Hive.box<UserModel>('userBox')
          : await Hive.openBox<UserModel>('userBox');

      Logger().d("User box opened. Box length: ${userBox.length}");

      // Fetch the user
      if (userBox.isNotEmpty) {
        final user = userBox.get(userBox.keys.first);
        Logger().d("User found in box: ${user?.email}");
        return user;
      } else {
        Logger().d("No user found in the box.");
        return null;
      }
    } catch (e) {
      Logger().e("Error opening or fetching from Hive box: $e");
      return null;
    }
  }

  // Optional: You can add methods for other user-related actions (e.g., log out)
  Future<void> logOut() async {
    final userBox = await Hive.openBox<UserModel>('userBox');
    await userBox.clear();
    Logger().d("User logged out.");
    state = const AsyncValue.data(null);
  }
}

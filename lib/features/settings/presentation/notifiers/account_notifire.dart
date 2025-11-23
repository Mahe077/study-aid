import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/settings/domain/usecase/update_username.dart';
import 'package:study_aid/features/settings/domain/usecase/update_password.dart';

class AccountNotifier extends StateNotifier<AsyncValue<void>> {
  final UpdateUsernameUseCase updateUserUsername;
  final UpdateUserPasswordUseCase updateUserPassword;

  AccountNotifier({
    required this.updateUserUsername,
    required this.updateUserPassword,
  }) : super(const AsyncValue.data(null));

  Future<Failure?> saveChanges(User? user, String? password) async {
    state = const AsyncValue.loading();
    if (password != null && password.isNotEmpty) {
      final passwordResult = await updateUserPassword.call(password);
      if (passwordResult.isLeft()) {
        final failure = passwordResult.fold((l) => l, (_) => null);
        if (failure is NoInternetFailure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return failure; // Stop here if there's no internet
        }
        state = const AsyncValue.data(null);
        return failure;
      }
    }

    if (user != null) {
      final emailResult = await updateUserUsername.call(user);
      if (emailResult.isLeft()) {
        final failure = emailResult.fold((l) => l, (_) => null);
        if (failure is NoInternetFailure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return failure; // Stop here if there's no internet
        }
        state = const AsyncValue.data(null);
        return failure;
      }
    }

    state = const AsyncValue.data(null);
    return null;
  }
}

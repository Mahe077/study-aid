import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/settings/domain/usecase/update_username.dart';
import 'package:study_aid/features/settings/domain/usecase/update_password.dart';
import 'package:study_aid/features/settings/presentation/notifiers/account_notifire.dart';

final updateUserUsernameUseCaseProvider =
    Provider<UpdateUsernameUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUsernameUseCase(repository);
});

final updateUserPasswordUseCaseProvider =
    Provider<UpdateUserPasswordUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserPasswordUseCase(repository);
});

final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, AsyncValue<void>>((ref) {
  final updateUsername = ref.watch(updateUserUsernameUseCaseProvider);
  final updatePassword = ref.watch(updateUserPasswordUseCaseProvider);
  return AccountNotifier(
    updateUserUsername: updateUsername,
    updateUserPassword: updatePassword,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>(
    (ref) => UserNotifier(ref));

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  UserNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final signInWithEmail = _ref.read(signInWithEmailProvider);
      final result = await signInWithEmail.call(email, password);

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (user) => AsyncValue.data(user),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String username) async {
    state = const AsyncValue.loading();
    try {
      final signUpWithEmail = _ref.read(signUpWithEmailProvider);
      final result = await signUpWithEmail.call(email, password, username);

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (user) => AsyncValue.data(user),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final signInWithGoogle = _ref.read(signInWithGoogleProvider);
      final result = await signInWithGoogle.call();

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (user) => AsyncValue.data(user),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    try {
      final signInWithFacebook = _ref.read(signInWithFacebookProvider);
      final result = await signInWithFacebook.call();

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (user) => AsyncValue.data(user),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final signInWithApple = _ref.read(signInWithAppleProvider);
      final result = await signInWithApple.call();

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (user) => AsyncValue.data(user),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final signOut = _ref.read(signOutProvider);
      final result = await signOut.call();

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (_) => const AsyncValue.data(
            null), // Reset state to null after successful sign out
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> resetPassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      final resetPassword = _ref.read(resetPasswordProvider);
      final result = await resetPassword.call(newPassword);

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (_) => const AsyncValue.data(null),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      final sendPasswordResetEmail = _ref.read(sendPasswordResetEmailProvider);
      final result = await sendPasswordResetEmail.call(email);

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (_) => const AsyncValue.data(null),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

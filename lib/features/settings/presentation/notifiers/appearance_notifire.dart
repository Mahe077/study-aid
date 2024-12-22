import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/settings/domain/usecase/update_color.dart';

class AppearanceNotifier extends StateNotifier<AsyncValue<void>> {
  final UpdateUserColorUseCase updateUserColor;

  AppearanceNotifier({
    required this.updateUserColor,
  }) : super(const AsyncValue.data(null));

  /// Saves changes to the user's appearance settings.
  /// 
  /// Returns a [Failure] if an error occurs, or `null` if the operation is successful.
  Future<Failure?> saveChanges(User? user) async {
    if (user == null) {
      // Handle null user explicitly.
      state = const AsyncValue.data(null);
      return null;
    }

    state = const AsyncValue.loading();

    // Update user color
    final colorResult = await updateUserColor.call(user);
    if (colorResult.isLeft()) {
      final failure = colorResult.fold((l) => l, (_) => null);
      
      // Handle specific failure cases
      if (failure is NoInternetFailure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure;
      }

      // Handle other failures
      state = AsyncValue.error(failure?.message ?? 'Unknown error', StackTrace.current);
      return failure;
    }

    // If successful
    state = const AsyncValue.data(null);
    return null;
  }
}

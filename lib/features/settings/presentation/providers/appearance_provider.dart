import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/settings/domain/usecase/update_color.dart';
import 'package:study_aid/features/settings/presentation/notifiers/appearance_notifire.dart';

final updateUserColorUseCaseProvider =
    Provider<UpdateUserColorUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserColorUseCase(repository);
});

class AppearanceState {
  final Color userColor;

  AppearanceState({Color? userColor}) : userColor = userColor ?? AppColors.defaultColor;

  AppearanceState copyWith({Color? userColor}) {
    return AppearanceState(
      userColor: userColor ?? this.userColor,
    );
  }
}

final appearanceNotifierProvider =
    StateNotifierProvider<AppearanceNotifier, AsyncValue<AppearanceState>>((ref) {
  final updateUserColor= ref.watch(updateUserColorUseCaseProvider);

  return AppearanceNotifier(
    updateUserColor: updateUserColor,
  );
});

// Define a StateNotifier to manage color state
class TileColorNotifier extends StateNotifier<Color> {
  TileColorNotifier() : super(AppColors.defaultColor); // Initial default color

  // Function to update the color
  void updateColor(Color newColor) {
    state = newColor; // Update the state with the new color
  }
}

// Correctly create a StateNotifierProvider
final tileColorProvider = StateNotifierProvider<TileColorNotifier, Color>((ref) {
  return TileColorNotifier();
});
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/settings/presentation/providers/appearance_provider.dart';

class AppearancePage extends ConsumerStatefulWidget {
  const AppearancePage({super.key});

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = AppColors.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(appearanceNotifierProvider);
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: const BasicAppbar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeadings(
                text: 'Appearance Settings',
                alignment: TextAlign.left,
              ),
              const SizedBox(height: 20),
              userAsyncValue.when(
                data: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColorPickerRow(user),
                    const SizedBox(height: 20),
                    _buildSaveButton(user, isSaving),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  Logger().e('Error loading user info',
                      error: error, stackTrace: stack);
                  return const Center(
                    child: Text("Something went wrong! Please try again."),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the color picker row in the UI.
  Widget _buildColorPickerRow(User? user) {
    return Row(
      children: [
        const Text(
          "Change the default tile color:",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showColorPickerDialog(user),
          icon: Icon(
            Icons.color_lens,
            color: user?.color ?? AppColors.defaultColor,
          ),
        ),
      ],
    );
  }

  /// Builds the save button with dynamic state handling.
  Widget _buildSaveButton(User? user, AsyncValue<void> isSaving) {
    return BasicAppButton(
      onPressed: () {
        if (isSaving.isLoading) {
          // Log or handle the case where saving is already in progress
          Logger().d("Save in progress, button disabled.");
          return;
        }

        // Check if the selected color differs from the current user color
      if (user == null || selectedColor == user.color) {
        Logger().d("No changes detected, save not triggered.");
        return;
      }

      _saveChanges(ref, user.copyWith(color: selectedColor));
      },
      title: isSaving.isLoading ? "Saving..." : "Save Changes",
    );
  }

  /// Opens a dialog for selecting a new color.
  Future<void> _showColorPickerDialog(User? user) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select a color',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              availableColors: AppColors.colors,
              pickerColor: user?.color ?? selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  /// Saves changes to the user's appearance settings.
  Future<void> _saveChanges(WidgetRef ref, User? user) async {
    if (user == null) return;

    final toast = CustomToast(context: context);

    try {
      final res =
          await ref.read(appearanceNotifierProvider.notifier).saveChanges(user);

      if (res != null) {
        toast.showFailure(description: res.message);
      } else {
        toast.showSuccess(
            description: 'Default color updated. Changes will apply after your next login.');
        ref.invalidate(userProvider); // Refresh user data

        saveColor(user.color);
        
        setState(() {
          selectedColor = user.color;
        });
      }
    } catch (error, stack) {
      Logger().e('Error saving changes', error: error, stackTrace: stack);
      toast.showFailure(description: 'Failed to update appearance settings');
    }
  }

  // Save Color
  Future<void> saveColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tileColor', color.value);
  }
}

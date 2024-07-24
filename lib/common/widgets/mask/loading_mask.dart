import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

Widget buildLoadingMask() {
  return Positioned.fill(
    child: Container(
      color: Colors.black.withOpacity(0.3), // Semi-transparent background
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary, // Customize the color if needed
        ),
      ),
    ),
  );
}

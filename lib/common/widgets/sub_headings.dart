import 'package:flutter/material.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

class AppSubHeadings extends StatelessWidget {
  final String text;
  const AppSubHeadings({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
    );
  }
}

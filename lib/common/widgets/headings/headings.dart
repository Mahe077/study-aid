import 'package:flutter/material.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

class AppHeadings extends StatelessWidget {
  final String text;
  final TextAlign? alignment;
  const AppHeadings({super.key, required this.text, this.alignment});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontSize: 24,
        ),
        textAlign: alignment.toString().isEmpty ? TextAlign.center : alignment);
  }
}

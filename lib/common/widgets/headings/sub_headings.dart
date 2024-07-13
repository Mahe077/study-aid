import 'package:flutter/material.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

class AppSubHeadings extends StatelessWidget {
  final String text;
  final TextAlign? alignment;
  final double? size;
  const AppSubHeadings(
      {super.key, required this.text, this.alignment, this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontSize: size ?? 16,
      ),
      textAlign: alignment ?? TextAlign.center,
    );
  }
}

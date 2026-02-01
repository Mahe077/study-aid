import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class AppHeadings extends StatelessWidget {
  final String text;
  final TextAlign? alignment;
  final double? size;
  const AppHeadings({super.key, required this.text, this.alignment, this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        fontSize: size ?? 24,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: alignment.toString().isEmpty ? TextAlign.center : alignment
    );
  }
}

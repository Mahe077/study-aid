import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class AppSubHeadings extends StatelessWidget {
  final String text;
  final TextAlign? alignment;
  final double? size;
  final int? maxLine;
  const AppSubHeadings(
      {super.key, required this.text, this.alignment, this.size, this.maxLine});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontSize: size ?? 16,
      ),
      overflow: maxLine != null ? TextOverflow.ellipsis : null,
      maxLines: maxLine,
      textAlign: alignment ?? TextAlign.center,
    );
  }
}

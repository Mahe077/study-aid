import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final double? fontsize;
  final FontWeight? fontweight;

  const BasicAppButton(
      {required this.onPressed,
      required this.title,
      this.height,
      super.key,
      this.fontsize,
      this.fontweight});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size.fromHeight(height ?? 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontsize ?? 16,
            fontWeight: fontweight ?? FontWeight.w600,
          ),
        ));
  }
}

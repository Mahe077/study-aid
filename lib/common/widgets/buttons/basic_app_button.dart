import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final double? fontsize;
  final FontWeight? fontweight;
  final IconData? icon;

  const BasicAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    this.fontsize,
    this.fontweight,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: Size.fromHeight(
            height ?? 50), // Default height is 50 if not provided
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16), // Add horizontal padding
      ),
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppColors.icon,
                ),
                SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontsize ??
                        16, // Default font size is 16 if not provided
                    fontWeight: fontweight ?? FontWeight.w600,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    fontsize ?? 16, // Default font size is 16 if not provided
                fontWeight: fontweight ??
                    FontWeight
                        .w600, // Default font weight is w600 if not provided
              ),
            ),
    );
  }
}

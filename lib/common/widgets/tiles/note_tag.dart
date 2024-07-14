import 'package:flutter/material.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

class Tag extends StatelessWidget {
  final String text;
  final IconData? icon;
  const Tag({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 18,
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 10,
                color: AppColors.primary,
              ),
              const SizedBox(
                width: 5,
              )
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      brightness: Brightness.light,
      fontFamily: 'Ubuntu',
      sliderTheme:
          SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          hintStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 0.4)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      )));

  static final darkTheme = ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      brightness: Brightness.dark,
      fontFamily: 'Ubuntu',
      sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          activeTrackColor: const Color(0xffB7B7B7),
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
          thumbColor: const Color(0xffB7B7B7)),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.transparent,
          hintStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          isDense: true,
          // contentPadding:
          //     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.white, width: 0.4)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.white, width: 0.4))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      )));
}

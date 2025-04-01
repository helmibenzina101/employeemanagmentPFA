import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // Adjust import path if needed

class AppTypography {
  static TextTheme get textThemeLight => GoogleFonts.latoTextTheme(
        const TextTheme(
          // Define specific styles if needed, otherwise defaults from latoTextTheme are used
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
          bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
          labelLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary), // For buttons
        ),
      );

  static TextTheme get textThemeDark => GoogleFonts.latoTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
          bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
          labelLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary), // For buttons
        ),
      );

  // Convenience methods for specific styles
  static TextStyle? bodyStyle(BuildContext context) => Theme.of(context).textTheme.bodyMedium;
  static TextStyle? titleStyle(BuildContext context) => Theme.of(context).textTheme.titleLarge;
}
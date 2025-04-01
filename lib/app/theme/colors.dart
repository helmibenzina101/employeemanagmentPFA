import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF005A9C); // Example: A corporate blue
  static const Color secondary = Color(0xFFE87722); // Example: An accent orange
  static const Color accent = Color(0xFF4CAF50); // Example: Green for success/validation

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFADB5BD);

  // Status Colors
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // On Colors (Text/Icons on Primary/Secondary/Error etc.)
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onError = Colors.white;
  static const Color onSuccess = Colors.white;

  // Greys
  static const MaterialColor grey = Colors.grey; // Use shades like grey.shade300

  // Specific Status Colors (optional)
  static const Color pending = Colors.orange;
  static const Color approved = Colors.green;
  static const Color rejected = Colors.red;

}
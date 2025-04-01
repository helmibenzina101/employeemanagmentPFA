import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // Assuming you have a colors.dart file

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.textPrimaryLight,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary, // Color of title and icons
        elevation: 1.0,
         titleTextStyle: GoogleFonts.lato( // Example font
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme).apply(
         bodyColor: AppColors.textPrimaryLight,
         displayColor: AppColors.textPrimaryLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
         color: AppColors.surfaceLight,
      ),
      // Add other theme properties (bottomNavigationBar, etc.)
       bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey.shade600,
        backgroundColor: AppColors.surfaceLight,
        type: BottomNavigationBarType.fixed, // Adjust as needed
        selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.lato(),
      ),
    );
  }

  // Optional: Define a dark theme similarly
  static ThemeData get darkTheme {
     // Define dark theme colors in colors.dart
     return ThemeData(
       useMaterial3: true,
       brightness: Brightness.dark,
       primaryColor: AppColors.primary, // Often the same primary works
       colorScheme: const ColorScheme.dark(
         primary: AppColors.primary,
         secondary: AppColors.secondary,
         surface: AppColors.surfaceDark,
         error: AppColors.error, // Adjust if needed
         onPrimary: AppColors.onPrimary,
         onSecondary: AppColors.onSecondary,
         onSurface: AppColors.textPrimaryDark,
         onError: AppColors.onError, // Adjust if needed
       ),
       scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
         backgroundColor: AppColors.surfaceDark, // Darker app bar
         foregroundColor: AppColors.textPrimaryDark,
         elevation: 1.0,
         titleTextStyle: GoogleFonts.lato(
           fontSize: 20,
           fontWeight: FontWeight.bold,
           color: AppColors.textPrimaryDark,
         ),
       ),
       textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
       ),
       elevatedButtonTheme: ElevatedButtonThemeData(
         style: ElevatedButton.styleFrom(
           backgroundColor: AppColors.primary,
           foregroundColor: AppColors.onPrimary,
           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
           textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(8),
           ),
         ),
       ),
       inputDecorationTheme: InputDecorationTheme(
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8),
           borderSide: BorderSide(color: AppColors.grey.shade700),
         ),
         enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8),
           borderSide: BorderSide(color: AppColors.grey.shade600),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8),
           borderSide: const BorderSide(color: AppColors.primary, width: 2),
         ),
         labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
       ),
       cardTheme: CardTheme(
         elevation: 2,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
         color: AppColors.surfaceDark,
       ),
       bottomNavigationBarTheme: BottomNavigationBarThemeData(
         selectedItemColor: AppColors.primary,
         unselectedItemColor: AppColors.grey.shade400,
         backgroundColor: AppColors.surfaceDark,
         type: BottomNavigationBarType.fixed,
         selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
         unselectedLabelStyle: GoogleFonts.lato(),
       ),
     );
   }
}
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: AppSpacing.md,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

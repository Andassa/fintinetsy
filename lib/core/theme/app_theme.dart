import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.charcoal,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
      onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      surfaceContainerHighest:
          isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: colorScheme.onSurface,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: colorScheme.onSurface,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: colorScheme.onSurface,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 16,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

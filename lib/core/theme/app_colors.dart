import 'package:flutter/material.dart';

/// Semantic app colors — never hardcode hex in widgets; use Theme/ColorScheme or these tokens.
abstract final class AppColors {
  static const Color primary = Color(0xFFFF7101);
  static const Color primaryLight = Color(0xFFFF9D5C);
  static const Color primarySoft = Color(0xFFFFE8D6);

  static const Color black = Color(0xFF000000);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFFB0B0B0);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderFocused = primary;

  static const Color error = Color(0xFFE53935);
  static const Color errorSoft = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE8F5E9);

  static const Color badgeBg = Color(0xFFE3F2FD);
  static const Color badgeText = Color(0xFF2F54EB);

  static const Color socialBorder = Color(0xFFE8E8E8);

  static const Color chartPurple = Color(0xFFA283F1);
  static const Color chartBlue = Color(0xFF2F69FF);
  static const Color chartGreen = Color(0xFF8CC622);
  static const Color chartRed = Color(0xFFFF4B4B);
  static const Color hydrationBlue = Color(0xFF2962FF);
  static const Color skipSoft = Color(0xFFFFE0C2);

  // Dark theme counterparts
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceAlt = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFABABAB);
}

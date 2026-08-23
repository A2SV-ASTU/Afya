import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF1B7A43);
  static const Color primaryDark = Color(0xFF145E33);
  static const Color primaryLight = Color(0xFFE8F5E9);

  // Crisis Colors
  static const Color crisis = Color(0xFFD32F2F);
  static const Color crisisBackground = Color(0xFFFFEBEE);

  // Backgrounds & Surface
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Borders & Dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Chat Bubbles
  static const Color chatBubbleUser = Color(0xFFDCF8C6);
  static const Color chatBubbleApp = Color(0xFFF1F3F4);

  // Mood Indicator Badges
  static const Color moodCalm = Color(0xFF81C784);
  static const Color moodAnxious = Color(0xFF64B5F6);
  static const Color moodSad = Color(0xFFBA68C8);
  static const Color moodStressed = Color(0xFFFFB74D);
  static const Color moodOkay = Color(0xFFFFF176);

  // Status & Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
}

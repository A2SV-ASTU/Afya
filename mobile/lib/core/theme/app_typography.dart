import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 32.0 / 24.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 24.0 / 18.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 22.0 / 16.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 20.0 / 15.0,
    color: AppColors.surface,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 16.0 / 12.0,
    color: AppColors.textSecondary,
  );
}

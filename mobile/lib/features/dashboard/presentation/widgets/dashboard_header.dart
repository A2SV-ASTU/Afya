import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/patient_user_entity.dart';

class DashboardHeader extends StatelessWidget {
  final PatientUserEntity? user;

  const DashboardHeader({
    super.key,
    this.user,
  });

  String get _greeting {
    final firstName = user?.firstName.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return 'Welcome back, $firstName!';
    }
    return 'Welcome back!';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar: "Afya" brand title
        Text(
          'Afya',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.tealPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppDimensions.space24),

        // Welcome Title
        Text(
          _greeting,
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.space4),

        // Subtitle
        Text(
          "Here's your health overview for today.",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

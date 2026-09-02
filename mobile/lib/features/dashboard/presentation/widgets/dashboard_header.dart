import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/patient_user_entity.dart';

class DashboardHeader extends StatelessWidget {
  final PatientUserEntity? user;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    this.user,
    this.onNotificationTap,
  });

  String get _greeting {
    final firstName = user?.firstName.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return 'Welcome back, $firstName!';
    }
    return 'Welcome back!';
  }

  String get _initials {
    final first = user?.firstName.trim() ?? '';
    final last = user?.lastName.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    } else if (first.isNotEmpty) {
      return first[0].toUpperCase();
    }
    return 'A';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Brand / Avatar + Notification bell
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    _initials,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  'Afya Healthcare',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: onNotificationTap,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),

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

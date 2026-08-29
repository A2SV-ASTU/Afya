import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

enum BadgeType {
  normal,
  abnormal,
  critical,
  active,
  completed,
  deactivated,
  pending
}

class AfyaStatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const AfyaStatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.normal:
      case BadgeType.completed:
      case BadgeType.active:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryDark;
        break;
      case BadgeType.abnormal:
      case BadgeType.pending:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case BadgeType.critical:
      case BadgeType.deactivated:
        bg = AppColors.urgentBackground;
        fg = AppColors.urgentAlert;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

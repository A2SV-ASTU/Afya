import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

class AfyaEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const AfyaEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: AppDimensions.space16),
            Text(title, style: AppTypography.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.space8),
              Text(subtitle!, style: AppTypography.caption, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';
import 'afya_button.dart';

class AfyaErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AfyaErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.urgentAlert, size: 48),
            const SizedBox(height: AppDimensions.space16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space24),
              SizedBox(
                width: 160,
                child: AfyaButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  isSecondary: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'pin_login_view.dart';

class PinInputModal extends StatelessWidget {
  final String title;
  final Function(String pin) onSubmit;

  const PinInputModal({
    super.key,
    required this.title,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.pinBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
          Expanded(
            child: PinLoginView(
              onSubmitPin: onSubmit,
              onSwitchToPasswordLogin: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AfyaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AfyaCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: content,
      );
    }
    return content;
  }
}

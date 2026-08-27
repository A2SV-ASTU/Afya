import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

class AfyaCountdownBadge extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback? onExpired;

  const AfyaCountdownBadge({
    super.key,
    required this.expiresAt,
    this.onExpired,
  });

  @override
  State<AfyaCountdownBadge> createState() => _AfyaCountdownBadgeState();
}

class _AfyaCountdownBadgeState extends State<AfyaCountdownBadge> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final diff = widget.expiresAt.difference(now);

    if (diff.isNegative) {
      _remaining = Duration.zero;
      _timer?.cancel();
      widget.onExpired?.call();
    } else {
      _remaining = diff;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final isZero = _remaining == Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: isZero ? AppColors.disabled.withValues(alpha: 0.2) : AppColors.urgentBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isZero ? AppColors.textSecondary : AppColors.urgentAlert,
          ),
          const SizedBox(width: AppDimensions.space4),
          Text(
            '$minutes:$seconds',
            style: AppTypography.bodyMedium.copyWith(
              color: isZero ? AppColors.textSecondary : AppColors.urgentAlert,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

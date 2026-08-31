import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/local_dose_record_entity.dart';

class ScheduleItemTile extends StatelessWidget {
  final LocalDoseRecordEntity doseRecord;
  final String? route;
  final String? instructions;
  final VoidCallback? onTap;

  const ScheduleItemTile({
    super.key,
    required this.doseRecord,
    this.route,
    this.instructions,
    this.onTap,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }

  Widget _buildStatusBadge(DoseStatus status) {
    switch (status) {
      case DoseStatus.pending:
        return const AfyaStatusBadge(
          label: 'Pending',
          type: BadgeType.pending,
        );
      case DoseStatus.taken:
        return const AfyaStatusBadge(
          label: 'Taken',
          type: BadgeType.completed,
        );
      case DoseStatus.missed:
        return const AfyaStatusBadge(
          label: 'Missed',
          type: BadgeType.critical,
        );
      case DoseStatus.skipped:
        return const AfyaStatusBadge(
          label: 'Skipped',
          type: BadgeType.deactivated,
        );
    }
  }

  IconData _getStatusIcon(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return Icons.check_circle_outline_rounded;
      case DoseStatus.missed:
        return Icons.highlight_off_rounded;
      case DoseStatus.skipped:
        return Icons.remove_circle_outline_rounded;
      case DoseStatus.pending:
        return Icons.access_time_rounded;
    }
  }

  Color _getStatusIconColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return AppColors.success;
      case DoseStatus.missed:
        return AppColors.urgentAlert;
      case DoseStatus.skipped:
        return AppColors.textSecondary;
      case DoseStatus.pending:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTime(doseRecord.scheduledTime);
    final dosageParts = [
      if (doseRecord.dose.isNotEmpty) doseRecord.dose,
      if (route != null && route!.trim().isNotEmpty) route!.trim(),
    ];
    final dosageText = dosageParts.join(' • ');

    return AfyaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doseRecord.medicationName,
                      style: AppTypography.titleMedium,
                    ),
                    if (dosageText.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        dosageText,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              _buildStatusBadge(doseRecord.status),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              Icon(
                _getStatusIcon(doseRecord.status),
                size: 16,
                color: _getStatusIconColor(doseRecord.status),
              ),
              const SizedBox(width: AppDimensions.space4),
              Text(
                formattedTime,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (doseRecord.snoozedUntil != null) ...[
                const SizedBox(width: AppDimensions.space8),
                Text(
                  '(Snoozed until ${_formatTime(doseRecord.snoozedUntil!)})',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          if (instructions != null && instructions!.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.space4),
                Expanded(
                  child: Text(
                    instructions!.trim(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

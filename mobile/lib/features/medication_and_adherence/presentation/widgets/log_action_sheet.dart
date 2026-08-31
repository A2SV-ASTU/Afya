import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_button.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/local_dose_record_entity.dart';
import 'skip_reason_dialog.dart';

class LogActionSheet extends StatelessWidget {
  final LocalDoseRecordEntity doseRecord;
  final String? route;
  final String? instructions;
  final ValueChanged<LocalDoseRecordEntity>? onTaken;
  final ValueChanged<LocalDoseRecordEntity>? onSnooze;
  final void Function(LocalDoseRecordEntity dose, String reason)? onSkip;

  const LogActionSheet({
    super.key,
    required this.doseRecord,
    this.route,
    this.instructions,
    this.onTaken,
    this.onSnooze,
    this.onSkip,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalDoseRecordEntity doseRecord,
    String? route,
    String? instructions,
    ValueChanged<LocalDoseRecordEntity>? onTaken,
    ValueChanged<LocalDoseRecordEntity>? onSnooze,
    void Function(LocalDoseRecordEntity dose, String reason)? onSkip,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LogActionSheet(
          doseRecord: doseRecord,
          route: route,
          instructions: instructions,
          onTaken: onTaken,
          onSnooze: onSnooze,
          onSkip: onSkip,
        ),
      ),
    );
  }

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

  Future<void> _handleSkip(BuildContext context) async {
    final reason = await SkipReasonDialog.show(context);
    if (reason != null && reason.trim().isNotEmpty) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      onSkip?.call(doseRecord, reason.trim());
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
    final canSnooze = doseRecord.snoozeCount < 2;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.space24,
          AppDimensions.space12,
          AppDimensions.space24,
          AppDimensions.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bottom sheet drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Header Row: Medication Name + Status Badge
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

            // Scheduled Time & Snooze Info
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.space4),
                Text(
                  'Scheduled for $formattedTime',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
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

            // Instructions (when available)
            if (instructions != null && instructions!.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
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
            const SizedBox(height: AppDimensions.space24),

            // Action CTAs
            // 1. Mark as Taken
            AfyaButton(
              text: 'Mark as Taken',
              onPressed: () {
                Navigator.of(context).pop();
                onTaken?.call(doseRecord);
              },
            ),
            const SizedBox(height: AppDimensions.space12),

            // 2. Snooze
            AfyaButton(
              text: 'Snooze (10 min)',
              isSecondary: true,
              onPressed: canSnooze
                  ? () {
                      Navigator.of(context).pop();
                      onSnooze?.call(doseRecord);
                    }
                  : null,
            ),
            if (!canSnooze) ...[
              const SizedBox(height: AppDimensions.space4),
              Center(
                child: Text(
                  'Maximum 2 snoozes reached',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.space12),

            // 3. Skip Dose
            AfyaButton(
              text: 'Skip Dose',
              isSecondary: true,
              onPressed: () => _handleSkip(context),
            ),
          ],
        ),
      ),
    );
  }
}

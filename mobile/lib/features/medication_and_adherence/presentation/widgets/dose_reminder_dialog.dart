import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_button.dart';
import '../../domain/entities/local_dose_record_entity.dart';
import 'skip_reason_dialog.dart';

class DoseReminderDialog extends StatelessWidget {
  final LocalDoseRecordEntity doseRecord;
  final String? route;
  final ValueChanged<LocalDoseRecordEntity>? onTaken;
  final ValueChanged<LocalDoseRecordEntity>? onSnooze;
  final void Function(LocalDoseRecordEntity dose, String reason)? onSkip;

  const DoseReminderDialog({
    super.key,
    required this.doseRecord,
    this.route,
    this.onTaken,
    this.onSnooze,
    this.onSkip,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalDoseRecordEntity doseRecord,
    String? route,
    ValueChanged<LocalDoseRecordEntity>? onTaken,
    ValueChanged<LocalDoseRecordEntity>? onSnooze,
    void Function(LocalDoseRecordEntity dose, String reason)? onSkip,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DoseReminderDialog(
        doseRecord: doseRecord,
        route: route,
        onTaken: onTaken,
        onSnooze: onSnooze,
        onSkip: onSkip,
      ),
    );
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
    final dosageParts = [
      if (doseRecord.dose.isNotEmpty) doseRecord.dose,
      if (route != null && route!.trim().isNotEmpty) route!.trim(),
    ];
    final dosageText = dosageParts.join(' • ');
    final canSnooze = doseRecord.snoozeCount < 2;

    String snoozeButtonLabel;
    if (doseRecord.snoozeCount == 0) {
      snoozeButtonLabel = 'Snooze (+10 min)';
    } else if (doseRecord.snoozeCount == 1) {
      snoozeButtonLabel = 'Snooze (+20 min)';
    } else {
      snoozeButtonLabel = 'Snooze';
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppDimensions.space16),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pill / Bell Icon + Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                const Expanded(
                  child: Text(
                    'Time to take medication',
                    style: AppTypography.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Medication Name and Dosage
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doseRecord.medicationName,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (dosageText.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      dosageText,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (doseRecord.snoozeCount > 0) ...[
                    const SizedBox(height: AppDimensions.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space8,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Text(
                        doseRecord.snoozeCount >= 2
                            ? 'Maximum snoozes reached (2/2)'
                            : 'Snoozed ${doseRecord.snoozeCount}/2',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Action Buttons
            // 1. Taken Button (Primary)
            AfyaButton(
              text: 'Taken',
              onPressed: () {
                Navigator.of(context).pop();
                onTaken?.call(doseRecord);
              },
            ),
            const SizedBox(height: AppDimensions.space12),

            // 2. Snooze Button
            AfyaButton(
              text: snoozeButtonLabel,
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
                  'Maximum snoozes reached (2/2)',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.space12),

            // 3. Skip Button
            AfyaButton(
              text: 'Skip',
              isSecondary: true,
              onPressed: () => _handleSkip(context),
            ),
          ],
        ),
      ),
    );
  }
}

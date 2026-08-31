import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../domain/entities/lab_result_entity.dart';

class LabResultTile extends StatelessWidget {
  final LabResultEntity labResult;

  const LabResultTile({
    super.key,
    required this.labResult,
  });

  Color _getFlagColor(LabResultFlag? flag) {
    switch (flag) {
      case LabResultFlag.normal:
        return AppColors.primaryDark;
      case LabResultFlag.abnormal:
        return AppColors.warning;
      case LabResultFlag.critical:
        return AppColors.urgentAlert;
      case null:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagColor = _getFlagColor(labResult.flag);

    return AfyaCard(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  labResult.testName,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (labResult.flag != null)
                Text(
                  labResult.flag!.name[0].toUpperCase() +
                      labResult.flag!.name.substring(1),
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: flagColor,
                  ),
                ),
            ],
          ),
          if (labResult.measurements.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: labResult.measurements.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.space4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (labResult.summaryNotes.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              labResult.summaryNotes,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

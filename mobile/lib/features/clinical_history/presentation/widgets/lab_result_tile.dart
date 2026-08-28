import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/lab_result_entity.dart';

class LabResultTile extends StatelessWidget {
  final LabResultEntity labResult;

  const LabResultTile({
    super.key,
    required this.labResult,
  });

  BadgeType _mapFlagToBadgeType(LabResultFlag? flag) {
    switch (flag) {
      case LabResultFlag.normal:
        return BadgeType.normal;
      case LabResultFlag.abnormal:
        return BadgeType.abnormal;
      case LabResultFlag.critical:
        return BadgeType.critical;
      case null:
        return BadgeType.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AfyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labResult.testName,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      labResult.category.name.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (labResult.flag != null)
                AfyaStatusBadge(
                  label: labResult.flag!.name,
                  type: _mapFlagToBadgeType(labResult.flag),
                ),
            ],
          ),
          if (labResult.measurements.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: AppTypography.bodyMedium.copyWith(
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

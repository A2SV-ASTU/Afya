import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/diagnosis_entity.dart';

class DiagnosisTile extends StatelessWidget {
  final DiagnosisEntity diagnosis;

  const DiagnosisTile({
    super.key,
    required this.diagnosis,
  });

  @override
  Widget build(BuildContext context) {
    final isFinal = diagnosis.diagnosisType == DiagnosisType.finalDiagnosis;
    final badgeLabel = isFinal ? 'FINAL' : 'PROVISIONAL';

    return AfyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  diagnosis.diagnosisText,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              AfyaStatusBadge(
                label: badgeLabel,
                type: isFinal ? BadgeType.completed : BadgeType.pending,
              ),
            ],
          ),
          if (diagnosis.icdCode != null && diagnosis.icdCode!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space4),
            Text(
              'ICD Code: ${diagnosis.icdCode}',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (diagnosis.notes != null && diagnosis.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              diagnosis.notes!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

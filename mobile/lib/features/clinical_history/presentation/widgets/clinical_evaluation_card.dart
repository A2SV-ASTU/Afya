import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../domain/entities/clinical_evaluation_entity.dart';

class ClinicalEvaluationCard extends StatelessWidget {
  final ClinicalEvaluationEntity evaluation;

  const ClinicalEvaluationCard({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    return AfyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Doctor\'s Clinical Write-Up',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.space24),

          // Chief Complaint
          _buildSectionTitle('Chief Complaint'),
          const SizedBox(height: AppDimensions.space4),
          Text(
            evaluation.chiefComplaint,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.space16),

          // History of Present Illness
          _buildSectionTitle('History of Present Illness'),
          const SizedBox(height: AppDimensions.space4),
          Text(
            evaluation.historyOfPresentIllness,
            style: AppTypography.bodyMedium,
          ),

          // Past Admissions (if any)
          if (evaluation.pastAdmissions != null &&
              evaluation.pastAdmissions!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            _buildSectionTitle('Past Admissions'),
            const SizedBox(height: AppDimensions.space4),
            Text(
              evaluation.pastAdmissions!,
              style: AppTypography.bodyMedium,
            ),
          ],

          // Family History (if any)
          if (evaluation.familyHistory != null &&
              evaluation.familyHistory!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            _buildSectionTitle('Family History'),
            const SizedBox(height: AppDimensions.space4),
            Text(
              evaluation.familyHistory!,
              style: AppTypography.bodyMedium,
            ),
          ],

          // Allergies Notes (if any)
          if (evaluation.allergiesNotes != null &&
              evaluation.allergiesNotes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            _buildSectionTitle('Allergies Notes'),
            const SizedBox(height: AppDimensions.space4),
            Text(
              evaluation.allergiesNotes!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.urgentAlert,
              ),
            ),
          ],

          // General Appearance (if any)
          if (evaluation.generalAppearance != null &&
              evaluation.generalAppearance!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            _buildSectionTitle('General Appearance'),
            const SizedBox(height: AppDimensions.space4),
            Text(
              evaluation.generalAppearance!,
              style: AppTypography.bodyMedium,
            ),
          ],

          // System Examination (if any)
          if (evaluation.systemExamination != null &&
              evaluation.systemExamination!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            _buildSectionTitle('System Examination'),
            const SizedBox(height: AppDimensions.space4),
            ...evaluation.systemExamination!.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.space4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${entry.key}: ',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${entry.value}',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

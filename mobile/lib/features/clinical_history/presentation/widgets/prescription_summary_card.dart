import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../domain/entities/encounter_detail_entity.dart';

class PrescriptionSummaryCard extends StatelessWidget {
  final EncounterPrescriptionEntity prescription;

  const PrescriptionSummaryCard({
    super.key,
    required this.prescription,
  });

  @override
  Widget build(BuildContext context) {
    return AfyaCard(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
            Text(
              'Doctor\'s Note: ${prescription.notes}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],
          ...prescription.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC8ECE8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.medicationName} ${item.dose}',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.instructions != null &&
                                  item.instructions!.isNotEmpty
                              ? item.instructions!
                              : '${item.frequency} for ${item.duration}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

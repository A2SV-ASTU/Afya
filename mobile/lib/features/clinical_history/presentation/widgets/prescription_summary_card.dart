import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/encounter_detail_entity.dart';

class PrescriptionSummaryCard extends StatelessWidget {
  final EncounterPrescriptionEntity prescription;

  const PrescriptionSummaryCard({
    super.key,
    required this.prescription,
  });

  BadgeType _mapStatusToBadgeType(EncounterPrescriptionStatus status) {
    switch (status) {
      case EncounterPrescriptionStatus.active:
        return BadgeType.active;
      case EncounterPrescriptionStatus.completed:
        return BadgeType.completed;
      case EncounterPrescriptionStatus.deactivated:
        return BadgeType.deactivated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AfyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medication_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Prescription Record',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Doctor\'s Note: ${prescription.notes}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Divider(height: AppDimensions.space24),
          ...prescription.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space12),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.medicationName,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        AfyaStatusBadge(
                          label: item.status.name,
                          type: _mapStatusToBadgeType(item.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Row(
                      children: [
                        _buildDetailChip('Dose', item.dose),
                        const SizedBox(width: AppDimensions.space8),
                        _buildDetailChip('Route', item.route),
                        const SizedBox(width: AppDimensions.space8),
                        _buildDetailChip('Freq', item.frequency),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Duration: ${item.duration}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.instructions != null &&
                        item.instructions!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Instructions: ${item.instructions}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

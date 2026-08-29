import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../domain/entities/encounter_entity.dart';

class EncounterTimelineCard extends StatelessWidget {
  final EncounterEntity encounter;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const EncounterTimelineCard({
    super.key,
    required this.encounter,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final clinicName = encounter.clinicName ?? 'City Central Clinic';
    final doctorName = encounter.doctorName ?? 'Sarah Jenkins';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline Indicator (Line + Dot)
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color:
                        isFirst ? AppColors.primary : const Color(0xFFC8ECE8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isFirst ? AppColors.primary : const Color(0xFF88D4CB),
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox.shrink()
                      : Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),

          // Main Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space16),
              child: AfyaCard(
                onTap: onTap,
                padding: const EdgeInsets.all(AppDimensions.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Category Icon Badge
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC8ECE8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // Title & Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            clinicName,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Text(
                          DateTimeFormatter.formatShortDate(
                              encounter.startedAt),
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space4),

                    // Subtitle: Doctor • Clinic
                    Text(
                      'Dr. $doctorName • $clinicName',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // Bottom Summary Chips (Pill Shaped)
                    Wrap(
                      spacing: AppDimensions.space8,
                      runSpacing: AppDimensions.space4,
                      children: [
                        _buildSummaryChip('Vitals'),
                        _buildSummaryChip('Evaluation'),
                        _buildSummaryChip('Labs'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

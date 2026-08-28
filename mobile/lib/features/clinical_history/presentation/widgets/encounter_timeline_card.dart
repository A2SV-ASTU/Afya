import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/encounter_entity.dart';

class EncounterTimelineCard extends StatelessWidget {
  final EncounterEntity encounter;
  final VoidCallback onTap;

  const EncounterTimelineCard({
    super.key,
    required this.encounter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = encounter.status == EncounterStatus.closed;
    final clinicName = encounter.clinicName ?? 'Clinic Visit';
    final doctorName = encounter.doctorName ?? 'Doctor';

    return AfyaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    DateTimeFormatter.formatShortDate(encounter.startedAt),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              AfyaStatusBadge(
                label: encounter.status.name,
                type: isClosed ? BadgeType.completed : BadgeType.active,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            clinicName,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.space4),
              Expanded(
                child: Text(
                  'Dr. $doctorName',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  BadgeType _mapStatusToBadgeType(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return BadgeType.active;
      case AppointmentStatus.attended:
        return BadgeType.completed;
      case AppointmentStatus.cancelled:
        return BadgeType.deactivated;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Icons.event_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    DateTimeFormatter.formatDateTime(appointment.scheduledAt),
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              AfyaStatusBadge(
                label: appointment.status.name,
                type: _mapStatusToBadgeType(appointment.status),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  'Clinic ID: ${appointment.clinicId}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space4),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  'Doctor ID: ${appointment.doctorId}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                'Note: ${appointment.notes}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

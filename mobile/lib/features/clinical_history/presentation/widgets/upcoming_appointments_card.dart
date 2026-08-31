import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../domain/entities/appointment_entity.dart';

class UpcomingAppointmentsCard extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final VoidCallback onViewAll;

  const UpcomingAppointmentsCard({
    super.key,
    required this.appointments,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = appointments
        .where((a) => a.status == AppointmentStatus.scheduled)
        .toList();

    return AfyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'Upcoming Appointments',
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (upcoming.isEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              'No upcoming clinic appointments scheduled.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            const SizedBox(height: AppDimensions.space8),
            ...upcoming.take(2).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateTimeFormatter.formatDateTime(
                                  item.scheduledAt),
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Clinic ID: ${item.clinicId}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

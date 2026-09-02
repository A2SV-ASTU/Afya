import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../clinical_history/domain/entities/appointment_entity.dart';
import '../../../clinical_history/presentation/widgets/appointment_card.dart';

class NextAppointmentSection extends StatelessWidget {
  final AppointmentEntity? nextAppointment;
  final VoidCallback? onAppointmentTap;
  final VoidCallback? onViewAllAppointments;

  const NextAppointmentSection({
    super.key,
    this.nextAppointment,
    this.onAppointmentTap,
    this.onViewAllAppointments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Next Appointment',
              style: AppTypography.titleMedium,
            ),
            if (nextAppointment != null && onViewAllAppointments != null)
              GestureDetector(
                onTap: onViewAllAppointments,
                child: Text(
                  'View All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),

        // Appointment Content
        if (nextAppointment != null)
          AppointmentCard(
            appointment: nextAppointment!,
            onTap: onAppointmentTap,
          )
        else
          _buildNoAppointmentsCard(),
      ],
    );
  }

  Widget _buildNoAppointmentsCard() {
    return Column(
      children: [
        AfyaCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space20,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              const Expanded(
                child: Text(
                  'No upcoming appointments.',
                  style: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Text(
                  "Tip: Approve a clinic's access request to let your doctor view your health history.",
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

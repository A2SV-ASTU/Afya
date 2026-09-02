import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_loading_indicator.dart';
import '../../../medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import '../../../medication_and_adherence/presentation/widgets/log_action_sheet.dart';
import '../../../medication_and_adherence/presentation/widgets/today_schedule_card.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/next_appointment_section.dart';
import '../widgets/today_adherence_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleDoseTap(
    BuildContext context,
    LocalDoseRecordEntity dose,
    DashboardState state,
  ) {
    final cubit = context.read<DashboardCubit>();
    final matchingRx = state.cachedPrescriptions
        .where((r) => r.id == dose.prescriptionItemId)
        .firstOrNull;

    LogActionSheet.show(
      context,
      doseRecord: dose,
      route: matchingRx?.route,
      instructions: matchingRx?.instructions,
      onTaken: (d) => cubit.markDoseTaken(d),
      onSnooze: (d) => cubit.snoozeDose(d),
      onSkip: (d, reason) => cubit.skipDose(d, reason),
    );
  }



  void _showLogVitalsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.space20,
          right: AppDimensions.space20,
          top: AppDimensions.space20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimensions.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.favorite_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    const Text(
                      'Log Vital Signs',
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'Keep track of your health measurements. Vital signs logging will sync with your clinic records once connected.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.space12,
                  ),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogVitalsBottomSheet(context),
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(
          Icons.favorite_outline,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'Log Vital Signs',
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              current.errorMessage != null &&
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.urgentAlert,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == DashboardStatus.loading) {
              return const AfyaLoadingIndicator();
            }

            if (state.status == DashboardStatus.error &&
                state.todayDoses.isEmpty) {
              return AfyaErrorView(
                message: state.errorMessage ?? 'Failed to load dashboard data.',
                onRetry: () => context
                    .read<DashboardCubit>()
                    .loadDashboard(forceRefresh: true),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context
                  .read<DashboardCubit>()
                  .loadDashboard(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space20,
                  vertical: AppDimensions.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    DashboardHeader(user: state.user),
                    const SizedBox(height: AppDimensions.space24),

                    // 2. Today's Medication Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Medication",
                          style: AppTypography.titleMedium,
                        ),
                        if (state.todayDoses.isNotEmpty)
                          GestureDetector(
                            onTap: () => context.go(RoutePaths.history),
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
                    TodayScheduleCard(
                      doses: state.todayDoses,
                      title: null,
                      emptyMessage:
                          'No reminders buzzing yet — your dose schedule will land here once it\'s set.',
                      routeBuilder: (dose) =>
                          state.cachedPrescriptions
                              .where((r) => r.id == dose.prescriptionItemId)
                              .firstOrNull
                              ?.route ??
                          '',
                      instructionsBuilder: (dose) =>
                          state.cachedPrescriptions
                              .where((r) => r.id == dose.prescriptionItemId)
                              .firstOrNull
                              ?.instructions ??
                          '',
                      onDoseTap: (dose) => _handleDoseTap(context, dose, state),
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // 3. Today's Adherence Section
                    TodayAdherenceCard(
                      takenCount: state.takenCount,
                      pendingCount: state.pendingCount,
                      missedCount: state.missedCount,
                      skippedCount: state.skippedCount,
                      totalCount: state.totalCount,
                      adherencePercentage: state.adherencePercentage,
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // 4. Next Appointment Section
                    NextAppointmentSection(
                      nextAppointment: state.nextAppointment,
                      onAppointmentTap: () =>
                          context.push(RoutePaths.appointments),
                      onViewAllAppointments: () =>
                          context.push(RoutePaths.appointments),
                    ),
                    const SizedBox(height: AppDimensions.space32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

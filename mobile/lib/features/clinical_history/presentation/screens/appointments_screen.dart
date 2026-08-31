import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_empty_state.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_loading_indicator.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  final String patientId;

  const AppointmentsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context
        .read<AppointmentsCubit>()
        .fetchAppointments(patientId: widget.patientId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context
        .read<AppointmentsCubit>()
        .fetchAppointments(patientId: widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: AppTypography.titleMedium,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past / Archive'),
          ],
        ),
      ),
      body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoadingState) {
            return const AfyaLoadingIndicator();
          }

          if (state is AppointmentsErrorState) {
            return AfyaErrorView(
              message: state.message,
              onRetry: () {
                context
                    .read<AppointmentsCubit>()
                    .fetchAppointments(patientId: widget.patientId);
              },
            );
          }

          if (state is AppointmentsLoadedState) {
            final upcoming = state.upcomingAppointments;
            final past = state.pastAppointments;

            return TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(
                  items: upcoming,
                  emptyTitle: 'No upcoming appointments scheduled',
                  emptySubtitle: 'Scheduled clinic visits will appear here.',
                ),
                _buildAppointmentsList(
                  items: past,
                  emptyTitle: 'No past appointments found',
                  emptySubtitle:
                      'Attended and cancelled appointments will be archived here.',
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAppointmentsList({
    required List<dynamic> items,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: AfyaEmptyState(
              title: emptyTitle,
              subtitle: emptySubtitle,
              icon: Icons.event_note_rounded,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.space16),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.space12),
        itemBuilder: (context, index) {
          final appointment = items[index];
          return AppointmentCard(appointment: appointment);
        },
      ),
    );
  }
}

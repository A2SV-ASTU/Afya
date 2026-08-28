import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_empty_state.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_loading_indicator.dart';
import '../bloc/history_timeline_bloc.dart';
import '../bloc/history_timeline_event.dart';
import '../bloc/history_timeline_state.dart';
import '../widgets/encounter_timeline_card.dart';

class HistoryTimelineScreen extends StatefulWidget {
  final String patientId;

  const HistoryTimelineScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<HistoryTimelineScreen> createState() => _HistoryTimelineScreenState();
}

class _HistoryTimelineScreenState extends State<HistoryTimelineScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryTimelineBloc>().add(
          FetchEncountersTimelineEvent(patientId: widget.patientId),
        );
  }

  Future<void> _onRefresh() async {
    context.read<HistoryTimelineBloc>().add(
          RefreshEncountersTimelineEvent(patientId: widget.patientId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Encounters History',
          style: AppTypography.titleMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.event_outlined),
            tooltip: 'Appointments',
            onPressed: () => context.push(RoutePaths.appointments),
          ),
        ],
      ),
      body: BlocBuilder<HistoryTimelineBloc, HistoryTimelineState>(
        builder: (context, state) {
          if (state is HistoryTimelineLoadingState) {
            return const AfyaLoadingIndicator();
          }

          if (state is HistoryTimelineErrorState) {
            return AfyaErrorView(
              message: state.message,
              onRetry: () {
                context.read<HistoryTimelineBloc>().add(
                      FetchEncountersTimelineEvent(patientId: widget.patientId),
                    );
              },
            );
          }

          if (state is HistoryTimelineLoadedState) {
            if (state.encounters.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: const AfyaEmptyState(
                      title: 'No clinical encounters recorded yet.',
                      subtitle:
                          'Your visit timeline will appear here after your first clinic appointment.',
                      icon: Icons.history_rounded,
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.space16),
                itemCount: state.encounters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppDimensions.space12),
                itemBuilder: (context, index) {
                  final encounter = state.encounters[index];
                  return EncounterTimelineCard(
                    encounter: encounter,
                    onTap: () {
                      context.push(
                        RoutePaths.encounterDetailPath(encounter.id),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

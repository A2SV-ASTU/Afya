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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryTimelineBloc>().add(
          FetchEncountersTimelineEvent(patientId: widget.patientId),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: Text(
          'Afya',
          style: AppTypography.displayLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.event_note_outlined, color: AppColors.primary),
            tooltip: 'Appointments',
            onPressed: () => context.push(RoutePaths.appointments),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                      vertical: AppDimensions.space12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search history...',
                              hintStyle: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Title: Medical History
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Text(
              'Medical History',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Timeline Content
          Expanded(
            child: BlocBuilder<HistoryTimelineBloc, HistoryTimelineState>(
              builder: (context, state) {
                if (state is HistoryTimelineLoadingState) {
                  return const AfyaLoadingIndicator();
                }

                if (state is HistoryTimelineErrorState) {
                  return AfyaErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<HistoryTimelineBloc>().add(
                            FetchEncountersTimelineEvent(
                                patientId: widget.patientId),
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
                          height: MediaQuery.of(context).size.height * 0.5,
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                      ),
                      itemCount: state.encounters.length,
                      itemBuilder: (context, index) {
                        final encounter = state.encounters[index];
                        return EncounterTimelineCard(
                          encounter: encounter,
                          isFirst: index == 0,
                          isLast: index == state.encounters.length - 1,
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
          ),
        ],
      ),
    );
  }
}

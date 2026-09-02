import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_empty_state.dart';
import '../../domain/entities/local_dose_record_entity.dart';
import 'schedule_item_tile.dart';

class TodayScheduleCard extends StatelessWidget {
  final List<LocalDoseRecordEntity> doses;
  final ValueChanged<LocalDoseRecordEntity>? onDoseTap;
  final String? title;
  final String? emptyMessage;
  final String Function(LocalDoseRecordEntity dose)? routeBuilder;
  final String Function(LocalDoseRecordEntity dose)? instructionsBuilder;
  final Map<String, String>? routes;
  final Map<String, String>? instructions;

  const TodayScheduleCard({
    super.key,
    required this.doses,
    this.onDoseTap,
    this.title = "Today's Schedule",
    this.emptyMessage,
    this.routeBuilder,
    this.instructionsBuilder,
    this.routes,
    this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.trim().isNotEmpty) ...[
            Text(
              title!.trim(),
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppDimensions.space12),
          ],
          AfyaCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.space24,
              horizontal: AppDimensions.space16,
            ),
            child: AfyaEmptyState(
              icon: Icons.medication_outlined,
              title: emptyMessage ?? 'No Scheduled Doses',
              subtitle: 'You have no medication doses scheduled for today.',
            ),
          ),
        ],
      );
    }

    final sortedDoses = List<LocalDoseRecordEntity>.from(doses)
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.trim().isNotEmpty) ...[
          Text(
            title!.trim(),
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppDimensions.space12),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDoses.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.space12),
          itemBuilder: (context, index) {
            final dose = sortedDoses[index];
            final resolvedRoute =
                routeBuilder?.call(dose) ?? routes?[dose.prescriptionItemId];
            final resolvedInstructions = instructionsBuilder?.call(dose) ??
                instructions?[dose.prescriptionItemId];

            return ScheduleItemTile(
              doseRecord: dose,
              route: resolvedRoute,
              instructions: resolvedInstructions,
              onTap: onDoseTap != null ? () => onDoseTap!(dose) : null,
            );
          },
        ),
      ],
    );
  }
}

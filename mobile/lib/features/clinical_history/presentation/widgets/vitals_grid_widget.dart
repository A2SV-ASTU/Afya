import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/encounter_detail_entity.dart';

class VitalsGridWidget extends StatelessWidget {
  final EncounterVitalEntity vital;

  const VitalsGridWidget({
    super.key,
    required this.vital,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_VitalMetricItem>[];

    if (vital.systolicBp != null && vital.diastolicBp != null) {
      items.add(_VitalMetricItem(
        label: 'Blood Pressure',
        value: '${vital.systolicBp}/${vital.diastolicBp}',
        unit: 'mmHg',
        icon: Icons.speed_rounded,
        iconBgColor: const Color(0xFFE0F2F1),
        iconColor: AppColors.primaryDark,
      ));
    }

    if (vital.pulse != null) {
      items.add(_VitalMetricItem(
        label: 'Heart Rate',
        value: '${vital.pulse}',
        unit: 'bpm',
        icon: Icons.favorite_outline_rounded,
        iconBgColor: const Color(0xFFFFEBEE),
        iconColor: const Color(0xFFD32F2F),
      ));
    }

    if (vital.temperature != null) {
      items.add(_VitalMetricItem(
        label: 'Temperature',
        value: '${vital.temperature}',
        unit: '°F',
        icon: Icons.thermostat_outlined,
        iconBgColor: const Color(0xFFFFF3E0),
        iconColor: AppColors.warning,
      ));
    }

    if (vital.spo2 != null) {
      items.add(_VitalMetricItem(
        label: 'SpO2',
        value: '${vital.spo2}',
        unit: '%',
        icon: Icons.air_rounded,
        iconBgColor: const Color(0xFFE0F2F1),
        iconColor: AppColors.primaryDark,
      ));
    } else if (vital.respiratoryRate != null) {
      items.add(_VitalMetricItem(
        label: 'Resp. Rate',
        value: '${vital.respiratoryRate}',
        unit: 'breaths/min',
        icon: Icons.air_rounded,
        iconBgColor: const Color(0xFFE0F2F1),
        iconColor: AppColors.primaryDark,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.space12,
        mainAxisSpacing: AppDimensions.space12,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: item.iconColor,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                item.label,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.unit,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VitalMetricItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _VitalMetricItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

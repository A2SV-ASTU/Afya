import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_empty_state.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../../clinical_history/domain/entities/encounter_entity.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final EncounterPrescriptionItemEntity? prescription;
  final String? doctorName;
  final String? clinicName;
  final EncounterEntity? encounter;

  const PrescriptionDetailScreen({
    super.key,
    this.prescription,
    this.doctorName,
    this.clinicName,
    this.encounter,
  });

  String get _appBarTitle {
    final rx = prescription;
    if (rx == null || rx.medicationName.isEmpty) {
      return 'Prescription Details';
    }
    if (rx.dose.isNotEmpty &&
        !rx.medicationName.toLowerCase().contains(rx.dose.toLowerCase())) {
      return '${rx.medicationName} ${rx.dose}';
    }
    return rx.medicationName;
  }

  String? get _authoringDoctor {
    final name = doctorName ?? encounter?.doctorName;
    if (name == null || name.trim().isEmpty) return null;
    return name.trim();
  }

  String? get _clinicSource {
    final clinic = clinicName ?? encounter?.clinicName;
    if (clinic == null || clinic.trim().isEmpty) return null;
    return clinic.trim();
  }

  Widget _buildStatusBadge(EncounterPrescriptionStatus status) {
    switch (status) {
      case EncounterPrescriptionStatus.active:
        return const AfyaStatusBadge(
          label: 'Active',
          type: BadgeType.active,
        );
      case EncounterPrescriptionStatus.completed:
        return const AfyaStatusBadge(
          label: 'Completed',
          type: BadgeType.completed,
        );
      case EncounterPrescriptionStatus.deactivated:
        return const AfyaStatusBadge(
          label: 'Deactivated',
          type: BadgeType.deactivated,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rx = prescription;
    final authorDoctor = _authoringDoctor;
    final clinic = _clinicSource;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _appBarTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: rx == null
          ? const Center(
              child: AfyaEmptyState(
                title: 'No prescriptions',
                subtitle: "You don't have any prescriptions at the moment.",
                icon: Icons.medication_outlined,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Read-Only Informational Notice Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            'This prescription cannot be edited — contact your clinic for changes.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Medication Summary Card
                  AfyaCard(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium,
                                ),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: AppColors.primaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Medication',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space4),
                                  Text(
                                    rx.medicationName,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            _buildStatusBadge(rx.status),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.space16,
                          ),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                label: 'Dose',
                                value: rx.dose,
                                icon: Icons.scale_outlined,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space16),
                            Expanded(
                              child: _buildInfoItem(
                                label: 'Route',
                                value: rx.route,
                                icon: Icons.alt_route_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Prescription Schedule & Details Card
                  AfyaCard(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRESCRIPTION DETAILS',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        _buildDetailRow(
                          label: 'Frequency',
                          value: rx.frequency,
                          icon: Icons.repeat_rounded,
                        ),
                        if (rx.duration.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.space12,
                            ),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.border,
                            ),
                          ),
                          _buildDetailRow(
                            label: 'Duration',
                            value: rx.duration,
                            icon: Icons.calendar_today_outlined,
                          ),
                        ],
                        if (rx.instructions != null &&
                            rx.instructions!.trim().isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.space12,
                            ),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.border,
                            ),
                          ),
                          _buildDetailRow(
                            label: 'Instructions',
                            value: rx.instructions!.trim(),
                            icon: Icons.description_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Authoring Doctor / Source Card (when available)
                  if (authorDoctor != null || clinic != null) ...[
                    const SizedBox(height: AppDimensions.space16),
                    AfyaCard(
                      padding: const EdgeInsets.all(AppDimensions.space20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRESCRIBER',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),
                          if (authorDoctor != null)
                            _buildDetailRow(
                              label: 'Authoring Doctor',
                              value: authorDoctor.startsWith('Dr.')
                                  ? authorDoctor
                                  : 'Dr. $authorDoctor',
                              icon: Icons.person_outline_rounded,
                            ),
                          if (clinic != null) ...[
                            if (authorDoctor != null)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppDimensions.space12,
                                ),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.border,
                                ),
                              ),
                            _buildDetailRow(
                              label: 'Clinic / Facility',
                              value: clinic,
                              icon: Icons.local_hospital_outlined,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.space24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.space4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          value.isNotEmpty ? value : '—',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.space8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                value.isNotEmpty ? value : '—',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

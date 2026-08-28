import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_loading_indicator.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../domain/entities/encounter_detail_entity.dart';
import '../cubit/encounter_detail_cubit.dart';
import '../cubit/encounter_detail_state.dart';
import '../widgets/clinical_evaluation_card.dart';
import '../widgets/diagnosis_tile.dart';
import '../widgets/lab_result_tile.dart';
import '../widgets/prescription_summary_card.dart';

class EncounterDetailScreen extends StatefulWidget {
  final String encounterId;

  const EncounterDetailScreen({
    super.key,
    required this.encounterId,
  });

  @override
  State<EncounterDetailScreen> createState() => _EncounterDetailScreenState();
}

class _EncounterDetailScreenState extends State<EncounterDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<EncounterDetailCubit>()
        .fetchEncounterDetail(widget.encounterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Visit Details',
          style: AppTypography.titleMedium,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<EncounterDetailCubit, EncounterDetailState>(
        builder: (context, state) {
          if (state is EncounterDetailLoadingState) {
            return const AfyaLoadingIndicator();
          }

          if (state is EncounterDetailErrorState) {
            return AfyaErrorView(
              message: state.message,
              onRetry: () {
                context
                    .read<EncounterDetailCubit>()
                    .fetchEncounterDetail(widget.encounterId);
              },
            );
          }

          if (state is EncounterDetailLoadedState) {
            final detail = state.detail;
            final encounter = detail.encounter;
            final clinicName = encounter.clinicName ?? 'Clinic Visit';
            final doctorName = encounter.doctorName ?? 'Doctor';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  AfyaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                clinicName,
                                style: AppTypography.displayLarge.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            AfyaStatusBadge(
                              label: encounter.status.name,
                              type: BadgeType.completed,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Row(
                          children: [
                            const Icon(
                              Icons.medical_services_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Text(
                              'Dr. $doctorName',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Text(
                              DateTimeFormatter.formatDateTime(
                                  encounter.startedAt),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Clinical Evaluation Section
                  if (detail.clinicalEvaluation != null) ...[
                    const SizedBox(height: AppDimensions.space16),
                    ClinicalEvaluationCard(
                      evaluation: detail.clinicalEvaluation!,
                    ),
                  ],

                  // Clinic Vitals Section
                  if (detail.vitals.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space16),
                    _buildSectionHeader(
                        'Clinic Vital Signs', Icons.favorite_border_rounded),
                    const SizedBox(height: AppDimensions.space8),
                    ...detail.vitals.map((vital) => _buildVitalCard(vital)),
                  ],

                  // Diagnoses Section
                  if (detail.diagnoses.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space16),
                    _buildSectionHeader('Diagnoses', Icons.healing_outlined),
                    const SizedBox(height: AppDimensions.space8),
                    ...detail.diagnoses.map((diag) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.space8),
                          child: DiagnosisTile(diagnosis: diag),
                        )),
                  ],

                  // Prescriptions Section
                  if (detail.prescriptions.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space16),
                    _buildSectionHeader(
                        'Prescriptions', Icons.medication_outlined),
                    const SizedBox(height: AppDimensions.space8),
                    ...detail.prescriptions.map((rx) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.space8),
                          child: PrescriptionSummaryCard(prescription: rx),
                        )),
                  ],

                  // Lab Results Section
                  if (detail.labs.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space16),
                    _buildSectionHeader(
                        'Lab & Imaging Results', Icons.science_outlined),
                    const SizedBox(height: AppDimensions.space8),
                    ...detail.labs.map((lab) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.space8),
                          child: LabResultTile(labResult: lab),
                        )),
                  ],

                  const SizedBox(height: AppDimensions.space24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppDimensions.space8),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard(EncounterVitalEntity vital) {
    return AfyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recorded at ${DateTimeFormatter.formatTime(vital.recordedAt)}',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              AfyaStatusBadge(
                label: vital.source.name.toUpperCase(),
                type: BadgeType.normal,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Wrap(
            spacing: AppDimensions.space16,
            runSpacing: AppDimensions.space8,
            children: [
              if (vital.systolicBp != null && vital.diastolicBp != null)
                _buildVitalMetric('Blood Pressure',
                    '${vital.systolicBp}/${vital.diastolicBp} mmHg'),
              if (vital.pulse != null)
                _buildVitalMetric('Pulse', '${vital.pulse} bpm'),
              if (vital.respiratoryRate != null)
                _buildVitalMetric(
                    'Resp. Rate', '${vital.respiratoryRate} /min'),
              if (vital.temperature != null)
                _buildVitalMetric('Temperature', '${vital.temperature} °C'),
              if (vital.spo2 != null)
                _buildVitalMetric('SpO2', '${vital.spo2} %'),
              if (vital.bloodSugar != null)
                _buildVitalMetric('Blood Sugar', '${vital.bloodSugar} mg/dL'),
              if (vital.weight != null)
                _buildVitalMetric('Weight', '${vital.weight} kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

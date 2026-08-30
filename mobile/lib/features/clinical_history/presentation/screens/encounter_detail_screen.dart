import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_loading_indicator.dart';
import '../cubit/encounter_detail_cubit.dart';
import '../cubit/encounter_detail_state.dart';
import '../widgets/clinical_evaluation_card.dart';
import '../widgets/diagnosis_tile.dart';
import '../widgets/lab_result_tile.dart';
import '../widgets/prescription_summary_card.dart';
import '../widgets/vitals_grid_widget.dart';

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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Encounter Details',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.primaryDark),
            onPressed: () {},
          ),
        ],
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
            final clinicName =
                encounter.clinicName ?? 'Afya Main Clinic, Nairobi';
            final doctorName = encounter.doctorName ?? 'Sarah Jenkins';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rich Dark Green Banner Card Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXLarge),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F147A72),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GENERAL CONSULTATION',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF88D4CB),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          'Dr. $doctorName',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surface,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFFC8ECE8),
                            ),
                            const SizedBox(width: AppDimensions.space4),
                            Expanded(
                              child: Text(
                                clinicName,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFFC8ECE8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMedium),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATE & TIME',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF88D4CB),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateTimeFormatter.formatDateTime(
                                    encounter.startedAt),
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vital Signs 2x2 Grid Section
                  if (detail.vitals.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space24),
                    _buildSectionHeader(
                        'VITAL SIGNS', Icons.favorite_outline_rounded),
                    const SizedBox(height: AppDimensions.space12),
                    VitalsGridWidget(vital: detail.vitals.first),
                  ],

                  // Clinical Evaluation Section
                  if (detail.clinicalEvaluation != null) ...[
                    const SizedBox(height: AppDimensions.space24),
                    ClinicalEvaluationCard(
                      evaluation: detail.clinicalEvaluation!,
                    ),
                  ],

                  // Diagnoses Section
                  if (detail.diagnoses.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space24),
                    _buildSectionHeader('DIAGNOSES', Icons.healing_outlined),
                    const SizedBox(height: AppDimensions.space12),
                    ...detail.diagnoses.map((diag) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.space12),
                          child: DiagnosisTile(diagnosis: diag),
                        )),
                  ],

                  // Lab Results Section
                  if (detail.labs.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space24),
                    _buildSectionHeader(
                        'LABORATORY RESULTS', Icons.science_outlined),
                    const SizedBox(height: AppDimensions.space12),
                    ...detail.labs.map((lab) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.space12),
                          child: LabResultTile(labResult: lab),
                        )),
                  ],

                  // Prescriptions Section
                  if (detail.prescriptions.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.space24),
                    _buildSectionHeader(
                        'PRESCRIPTIONS', Icons.medication_outlined),
                    const SizedBox(height: AppDimensions.space12),
                    ...detail.prescriptions.map((rx) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.space12),
                          child: PrescriptionSummaryCard(prescription: rx),
                        )),
                  ],

                  const SizedBox(height: AppDimensions.space32),
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
        Icon(icon, color: AppColors.primaryDark, size: 20),
        const SizedBox(width: AppDimensions.space8),
        Text(
          title,
          style: AppTypography.caption.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

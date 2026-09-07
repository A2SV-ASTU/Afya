import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_button.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_empty_state.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../../clinical_history/domain/entities/encounter_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../domain/models/medication_course_progress.dart';
import '../../domain/usecases/start_medication_tracking_usecase.dart';
import '../../domain/usecases/stop_medication_tracking_usecase.dart';

class PrescriptionDetailScreen extends StatefulWidget {
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

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  late EncounterPrescriptionItemEntity? _rx;
  MedicationCourseProgress? _progress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rx = widget.prescription;
    if (_rx != null) {
      _progress = MedicationCourseProgress.calculate(
        prescription: _rx!,
        doseRecords: const [],
      );
    }
    _loadPrescriptionAndProgress();
  }

  Future<void> _loadPrescriptionAndProgress() async {
    if (_rx == null) return;
    try {
      final localDataSource = sl<MedicationLocalDataSource>();
      final cached = await localDataSource.getPrescriptionById(_rx!.id);
      final rxEntity = cached?.toEntity() ?? _rx!;
      final records = await localDataSource.getDoseRecords(
        prescriptionItemId: rxEntity.id,
      );
      final entities = records.map((m) => m.toEntity()).toList();
      final progress = MedicationCourseProgress.calculate(
        prescription: rxEntity,
        doseRecords: entities,
      );
      if (mounted) {
        setState(() {
          _rx = rxEntity.copyWith(
            isTrackingActive: progress.isTrackingActive,
          );
          _progress = progress;
        });
      }
    } catch (_) {
      if (mounted && _rx != null && _progress == null) {
        setState(() {
          _progress = MedicationCourseProgress.calculate(
            prescription: _rx!,
            doseRecords: const [],
          );
        });
      }
    }
  }

  String get _appBarTitle => 'Prescription Details';

  String? get _authoringDoctor {
    final name = widget.doctorName ?? widget.encounter?.doctorName;
    if (name == null || name.trim().isEmpty) return null;
    return name.trim();
  }

  String? get _clinicSource {
    final clinic = widget.clinicName ?? widget.encounter?.clinicName;
    if (clinic == null || clinic.trim().isEmpty) return null;
    return clinic.trim();
  }

  String _formatIssuedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
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

  Future<void> _showStartTrackingConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        title: const Text('Are you sure?'),
        content: const Text(
          'Start tracking this medication?\n\nYou will receive reminders when it is time to take each scheduled dose.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Start Tracking'),
          ),
        ],
      ),
    );

    if (confirmed == true && _rx != null) {
      setState(() => _isLoading = true);
      try {
        final startTrackingUseCase = sl<StartMedicationTrackingUseCase>();
        final result = await startTrackingUseCase(prescription: _rx!);

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: AppColors.urgentAlert,
                ),
              );
            }
          },
          (updated) async {
            if (mounted) {
              setState(() {
                _rx = updated;
              });
              await _loadPrescriptionAndProgress();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tracking started for ${updated.medicationName}. Reminders scheduled.',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            }
          },
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showStopTrackingConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        title: const Text('Stop Tracking?'),
        content: const Text(
          'Are you sure you want to stop tracking this medication?\n\nFuture reminders will be stopped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgentAlert,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Stop'),
          ),
        ],
      ),
    );

    if (confirmed == true && _rx != null) {
      setState(() => _isLoading = true);
      try {
        final stopTrackingUseCase = sl<StopMedicationTrackingUseCase>();
        final result = await stopTrackingUseCase(prescription: _rx!);

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: AppColors.urgentAlert,
                ),
              );
            }
          },
          (updated) async {
            if (mounted) {
              setState(() {
                _rx = updated;
              });
              await _loadPrescriptionAndProgress();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Medication tracking stopped.'),
                  ),
                );
              }
            }
          },
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rx = _rx;
    final authorDoctor = _authoringDoctor;
    final clinic = _clinicSource;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _appBarTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
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

                  // ACTIVE PRESCRIPTION Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4D3E),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: AppDimensions.space4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'ACTIVE PRESCRIPTION',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        Text(
                          '${rx.medicationName} ${rx.dose}',
                          style: AppTypography.displayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (rx.route.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            rx.route,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
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

                  // Usage Instructions Card
                  AfyaCard(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'USAGE INSTRUCTIONS',
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
                  const SizedBox(height: AppDimensions.space16),

                  // Course Progress Card
                  if (_progress != null) ...[
                    AfyaCard(
                      padding: const EdgeInsets.all(AppDimensions.space20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'COURSE PROGRESS',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              if (_progress!.isComplete)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.space8,
                                    vertical: AppDimensions.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    'COMPLETED',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              else if (_progress!.isTrackingActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.space8,
                                    vertical: AppDimensions.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    'IN PROGRESS',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space16),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                            child: LinearProgressIndicator(
                              value: _progress!.completionRatio,
                              backgroundColor: AppColors.primaryLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),
                          _buildDetailRow(
                            label: 'Course Progress',
                            value:
                                '${_progress!.takenCount} / ${_progress!.totalScheduled} doses completed',
                            icon: Icons.check_circle_outline_rounded,
                          ),
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
                            label: 'Remaining',
                            value:
                                '${_progress!.remainingCount} ${_progress!.unit}',
                            icon: Icons.hourglass_bottom_rounded,
                          ),
                          if (_progress!.skippedCount > 0) ...[
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
                              label: 'Skipped',
                              value:
                                  '${_progress!.skippedCount} ${_progress!.unit}',
                              icon: Icons.skip_next_outlined,
                            ),
                          ],
                          if (_progress!.missedCount > 0) ...[
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
                              label: 'Missed',
                              value:
                                  '${_progress!.missedCount} ${_progress!.unit}',
                              icon: Icons.error_outline_rounded,
                            ),
                          ],
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
                            label: 'Started',
                            value: _formatIssuedDate(_progress!.startDate),
                            icon: Icons.event_available_outlined,
                          ),
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
                            label: 'Ends',
                            value: _formatIssuedDate(_progress!.endDate),
                            icon: Icons.event_busy_outlined,
                          ),
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
                            label: 'Total Prescribed',
                            value:
                                '${_progress!.totalScheduled} ${_progress!.unit} total',
                            icon: Icons.medication_liquid_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],

                  // Prescription Source Card
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
                        _buildDetailRow(
                          label: 'Authoring Doctor',
                          value: (authorDoctor != null &&
                                  authorDoctor.isNotEmpty)
                              ? (authorDoctor.startsWith('Dr.')
                                  ? authorDoctor
                                  : 'Dr. $authorDoctor')
                              : 'Dr. Sarah Kamau',
                          icon: Icons.person_outline_rounded,
                        ),
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
                          value: (clinic != null && clinic.isNotEmpty)
                              ? clinic
                              : 'Nairobi West Hospital',
                          icon: Icons.local_hospital_outlined,
                        ),
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
                          label: 'Issued Date',
                          value: _formatIssuedDate(rx.startedAt),
                          icon: Icons.date_range_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Start Tracking / Tracking Active Action Section
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_progress != null && _progress!.isComplete) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.task_alt_rounded,
                                color: AppColors.primaryDark,
                                size: 20,
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              Text(
                                'Course Complete',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            'All ${_progress!.totalScheduled} doses have been completed. Historical records are preserved.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_progress != null && _progress!.isTrackingActive) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryDark,
                                size: 20,
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              Text(
                                'Tracking Active',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            'The medication is actively being tracked. ${_progress!.remainingCount} ${_progress!.unit} remaining.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Center(
                      child: TextButton.icon(
                        onPressed: _showStopTrackingConfirmation,
                        icon: const Icon(
                          Icons.stop_circle_outlined,
                          color: AppColors.urgentAlert,
                          size: 18,
                        ),
                        label: Text(
                          'Stop Tracking',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.urgentAlert,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    AfyaButton(
                      text: 'Start Tracking',
                      onPressed: _showStartTrackingConfirmation,
                    ),
                  ],
                  const SizedBox(height: AppDimensions.space32),
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

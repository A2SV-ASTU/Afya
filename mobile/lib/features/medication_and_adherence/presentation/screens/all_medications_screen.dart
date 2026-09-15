import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../../clinical_history/data/models/encounter_detail_model.dart';
import '../../domain/entities/local_dose_record_entity.dart';
import '../../domain/usecases/start_medication_tracking_usecase.dart';
import '../widgets/today_schedule_card.dart';
import 'prescription_detail_screen.dart';

class AllMedicationsScreen extends StatefulWidget {
  const AllMedicationsScreen({super.key});

  @override
  State<AllMedicationsScreen> createState() => _AllMedicationsScreenState();
}

class _AllMedicationsScreenState extends State<AllMedicationsScreen> {
  List<LocalDoseRecordEntity> _doses = [];
  List<EncounterPrescriptionItemEntity> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final localDataSource = sl<MedicationLocalDataSource>();
      final now = DateTime.now();

      final doseModels = await localDataSource.getDoseRecords(forDate: now);
      final rxModels = await localDataSource.getCachedPrescriptions();

      if (mounted) {
        setState(() {
          _doses = doseModels.map((m) => m.toEntity()).toList();
          _prescriptions = rxModels.map((m) => m.toEntity()).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addDemoMedication() async {
    const prescriptionId = 'demo_medication_notification';
    final localDataSource = sl<MedicationLocalDataSource>();
    final existingDoses = await localDataSource.getDoseRecords(
      prescriptionItemId: prescriptionId,
    );
    for (final dose in existingDoses) {
      await localDataSource.deleteDoseRecord(dose.id);
    }

    final prescription = EncounterPrescriptionItemModel(
      id: prescriptionId,
      medicationName: 'Demo Vitamin D',
      dose: '1 tablet',
      route: 'oral',
      frequency: 'Once daily (OD)',
      duration: '1 day',
      status: EncounterPrescriptionStatus.active,
      instructions: 'Demo reminder for notification testing',
      startedAt: DateTime.now(),
    );

    await localDataSource.cachePrescriptions([prescription]);
    final result = await sl<StartMedicationTrackingUseCase>()(
      prescription: prescription.toEntity(),
    );

    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo reminder scheduled in about 20 seconds.'),
          ),
        );
        _loadData();
      },
    );
  }

  void _openPrescriptionDetail(EncounterPrescriptionItemEntity rx) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PrescriptionDetailScreen(
              prescription: rx,
              doctorName: 'Dr. Sarah Kamau',
              clinicName: 'Nairobi West Hospital',
            ),
          ),
        )
        .then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'All Medications',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kDebugMode) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addDemoMedication,
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('Add demo notification'),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),
                    ],
                    // Section 1: Today's Complete Schedule
                    const Text(
                      "Today's Schedule",
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    TodayScheduleCard(
                      doses: _doses,
                      title: null,
                      emptyMessage: 'No doses scheduled for today.',
                      routeBuilder: (dose) =>
                          _prescriptions
                              .where((r) => r.id == dose.prescriptionItemId)
                              .firstOrNull
                              ?.route ??
                          '',
                      instructionsBuilder: (dose) =>
                          _prescriptions
                              .where((r) => r.id == dose.prescriptionItemId)
                              .firstOrNull
                              ?.instructions ??
                          '',
                      onDoseTap: (dose) {
                        final matchingRx = _prescriptions
                            .where((r) => r.id == dose.prescriptionItemId)
                            .firstOrNull;
                        if (matchingRx != null) {
                          _openPrescriptionDetail(matchingRx);
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // Section 2: All Prescriptions
                    const Text(
                      'All Prescriptions',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    if (_prescriptions.isEmpty)
                      const Center(
                        child: Text(
                          'No prescriptions found.',
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _prescriptions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppDimensions.space12),
                        itemBuilder: (context, index) {
                          final rx = _prescriptions[index];
                          return AfyaCard(
                            onTap: () => _openPrescriptionDetail(rx),
                            padding: const EdgeInsets.all(AppDimensions.space16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMedium,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.medication_rounded,
                                    color: AppColors.primaryDark,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${rx.medicationName} ${rx.dose}',
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppDimensions.space4),
                                      Text(
                                        '${rx.route} • ${rx.frequency}',
                                        style:
                                            AppTypography.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space8),
                                if (rx.isTrackingActive)
                                  const AfyaStatusBadge(
                                    label: 'Tracking',
                                    type: BadgeType.active,
                                  )
                                else
                                  const AfyaStatusBadge(
                                    label: 'Not Tracking',
                                    type: BadgeType.pending,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: AppDimensions.space32),
                  ],
                ),
              ),
            ),
    );
  }
}

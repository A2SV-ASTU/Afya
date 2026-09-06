import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';
import '../../../../core/widgets/afya_status_badge.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../domain/entities/local_dose_record_entity.dart';
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

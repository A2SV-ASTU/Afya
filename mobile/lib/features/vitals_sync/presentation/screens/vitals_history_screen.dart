import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/vital_sign_entity.dart';
import '../bloc/vitals_sync_bloc.dart';
import '../bloc/vitals_sync_event.dart';
import '../bloc/vitals_sync_state.dart';

class VitalsHistoryScreen extends StatefulWidget {
  const VitalsHistoryScreen({super.key});

  @override
  State<VitalsHistoryScreen> createState() => _VitalsHistoryScreenState();
}

class _VitalsHistoryScreenState extends State<VitalsHistoryScreen> {
  

  // Active filters
  String _selectedVitalType = 'All';
  String _selectedSource = 'All';

  @override
  void initState() {
    super.initState();

    // Load real vitals history through the BLoC.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<VitalsSyncBloc>().add(
        LoadVitalsHistoryEvent(),
      );
    });
  }

  // ============================================================
  // FILTER MODAL
  // ============================================================

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setModalState,
          ) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // HEADER
                    // ------------------------------------------------

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Vitals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E252B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // VITAL TYPE
                    // ------------------------------------------------

                    const Text(
                      'Filter by Vital Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A6E78),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'BP',
                        'Pulse',
                        'Temperature',
                        'SpO2',
                        'Weight',
                        'Blood Sugar',
                      ].map((type) {
                        final isSelected =
                            _selectedVitalType == type;

                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor:
                              const Color(0xFFE2F4E9),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF0C6B44)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (!selected) return;

                            setModalState(() {
                              _selectedVitalType = type;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // SOURCE
                    // ------------------------------------------------

                    const Text(
                      'Filter by Source',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A6E78),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Manual Entry',
                        'Smart Watch',
                        'Hospital',
                      ].map((source) {
                        final isSelected =
                            _selectedSource == source;

                        return ChoiceChip(
                          label: Text(source),
                          selected: isSelected,
                          selectedColor:
                              const Color(0xFFE2F4E9),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF0C6B44)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (!selected) return;

                            setModalState(() {
                              _selectedSource = source;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // BUTTONS
                    // ------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedVitalType = 'All';
                                _selectedSource = 'All';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF0C6B44),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: Color(0xFF0C6B44),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF0C6B44),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // FILTER LOGIC
  // ============================================================

  List<VitalSignEntity> _filterRecords(
    List<VitalSignEntity> records,
  ) {
    return records.where((record) {
      // Source filter
      final matchesSource =
          _selectedSource == 'All' ||
          record.source == _selectedSource;

      // Vital type filter
      bool matchesType = true;

      switch (_selectedVitalType) {
        case 'BP':
          matchesType =
              record.systolicBp != null &&
              record.diastolicBp != null;
          break;

        case 'Pulse':
          matchesType = record.pulse != null;
          break;

        case 'Temperature':
          matchesType = record.temperature != null;
          break;

        case 'SpO2':
          matchesType = record.spo2 != null;
          break;

        case 'Weight':
          matchesType = record.weight != null;
          break;

        case 'Blood Sugar':
          matchesType = record.bloodSugar != null;
          break;

        case 'All':
          matchesType = true;
          break;
      }

      return matchesSource && matchesType;
    }).toList();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshHistory() async {
    context.read<VitalsSyncBloc>().add(
      LoadVitalsHistoryEvent(),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black87,
          ),
          onPressed: () {},
        ),

        title: const Text(
          'Afya',
          style: TextStyle(
            color: Color(0xFF0C6B44),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        centerTitle: false,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: BlocBuilder<VitalsSyncBloc, VitalsSyncState>(
          builder: (context, state) {
            // ------------------------------------------------------
            // LOADING
            // ------------------------------------------------------

            if (state is VitalsLoading) {
              return const Column(
                children: [
                  _HistoryHeader(),

                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0C6B44),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ------------------------------------------------------
            // ERROR
            // ------------------------------------------------------

            if (state is VitalsError) {
              return Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 56,
                              color: Colors.red,
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Unable to load vitals history',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: _refreshHistory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0C6B44),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ------------------------------------------------------
            // HISTORY LOADED
            // ------------------------------------------------------

            if (state is VitalsHistoryLoaded) {
              final filteredList =
                  _filterRecords(state.history);

              return Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF0C6B44),
                      onRefresh: _refreshHistory,
                      child: filteredList.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: 180,
                                ),
                                Center(
                                  child: Text(
                                    'No vitals history found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.all(20),
                              itemCount: filteredList.length,
                              separatorBuilder: (
                                context,
                                index,
                              ) {
                                return const SizedBox(
                                  height: 20,
                                );
                              },
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                final vital =
                                    filteredList[index];

                                return VitalsCard(
                                  vital: vital,
                                  activeFilter:
                                      _selectedVitalType,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }

            // ------------------------------------------------------
            // INITIAL
            // ------------------------------------------------------

            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0C6B44),
              ),
            );
          },
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Vitals History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E252B),
            ),
          ),

          InkWell(
            onTap: _showFilterModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F4E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 18,
                    color: Color(0xFF0C6B44),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    (_selectedVitalType != 'All' ||
                            _selectedSource != 'All')
                        ? 'Filter • Active'
                        : 'Filter',
                    style: const TextStyle(
                      color: Color(0xFF0C6B44),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SIMPLE HEADER FOR LOADING STATE
// ================================================================

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Vitals History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E252B),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// VITALS CARD
// ================================================================

class VitalsCard extends StatelessWidget {
  final VitalSignEntity vital;
  final String activeFilter;

  const VitalsCard({
    super.key,
    required this.vital,
    required this.activeFilter,
  });

  // ==============================================================
  // DATE
  // ==============================================================

  String _getDateText() {
    final date = vital.recordedAt;
    final now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) {
      return 'Today';
    }

    final yesterday =
        now.subtract(const Duration(days: 1));

    if (DateUtils.isSameDay(date, yesterday)) {
      return 'Yesterday';
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  // ==============================================================
  // TIME
  // ==============================================================

  String _getTimeText() {
    return DateFormat(
      'hh:mm a',
    ).format(vital.recordedAt);
  }

  // ==============================================================
  // FILTER
  // ==============================================================

  bool _shouldShow(String type) {
    if (activeFilter == 'All') {
      return true;
    }

    return activeFilter == type;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final hasBloodPressure =
        vital.systolicBp != null &&
        vital.diastolicBp != null;

    final hasTemperature =
        vital.temperature != null;

    final hasWeight =
        vital.weight != null;

    final hasPulse =
        vital.pulse != null;

    final hasSpo2 =
        vital.spo2 != null;

    final hasBloodSugar =
        vital.bloodSugar != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ----------------------------------------------------
              // ACCENT STRIP
              // ----------------------------------------------------

              Container(
                width: 6,
                color: const Color(0xFFC3D9CE),
              ),

              // ----------------------------------------------------
              // CARD CONTENT
              // ----------------------------------------------------

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // HEADER
                      // ------------------------------------------------

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF0C6B44),
                            size: 24,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              _getDateText(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xFF1E252B),
                              ),
                            ),
                          ),

                          Text(
                            _getTimeText(),
                            style: const TextStyle(
                              fontSize: 15,
                              color:
                                  Color(0xFF5A6E78),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Divider(
                        color: Color(0xFFE5E9EB),
                        thickness: 1,
                      ),

                      const SizedBox(height: 12),

                      // ------------------------------------------------
                      // VITALS
                      // ------------------------------------------------

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (_shouldShow('BP') &&
                                    hasBloodPressure)
                                  _buildVitalItem(
                                    icon: Icons
                                        .favorite_border,
                                    label:
                                        'Blood Pressure',
                                    value:
                                        '${vital.systolicBp!.toStringAsFixed(0)}/${vital.diastolicBp!.toStringAsFixed(0)}',
                                    unit: 'mmHg',
                                  ),

                                if (_shouldShow('BP') &&
                                    hasBloodPressure &&
                                    _shouldShow(
                                        'Temperature') &&
                                    hasTemperature)
                                  const SizedBox(
                                    height: 16,
                                  ),

                                if (_shouldShow(
                                        'Temperature') &&
                                    hasTemperature)
                                  _buildVitalItem(
                                    icon: Icons
                                        .thermostat_outlined,
                                    label: 'Temperature',
                                    value: vital
                                        .temperature!
                                        .toStringAsFixed(1),
                                    unit: '°F',
                                  ),

                                if ((_shouldShow(
                                            'Temperature') &&
                                        hasTemperature) &&
                                    _shouldShow('Weight') &&
                                    hasWeight)
                                  const SizedBox(
                                    height: 16,
                                  ),

                                if (_shouldShow('Weight') &&
                                    hasWeight)
                                  _buildVitalItem(
                                    icon: Icons
                                        .scale_outlined,
                                    label: 'Weight',
                                    value: vital.weight!
                                        .toStringAsFixed(1),
                                    unit: 'lbs',
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // RIGHT COLUMN
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (_shouldShow('Pulse') &&
                                    hasPulse)
                                  _buildVitalItem(
                                    icon: Icons
                                        .monitor_heart_outlined,
                                    label: 'Pulse',
                                    value:
                                        vital.pulse.toString(),
                                    unit: 'bpm',
                                  ),

                                if (_shouldShow('Pulse') &&
                                    hasPulse &&
                                    _shouldShow('SpO2') &&
                                    hasSpo2)
                                  const SizedBox(
                                    height: 16,
                                  ),

                                if (_shouldShow('SpO2') &&
                                    hasSpo2)
                                  _buildVitalItem(
                                    icon: Icons
                                        .water_drop_outlined,
                                    label: 'SpO2',
                                    value: vital.spo2!
                                        .toStringAsFixed(0),
                                    unit: '%',
                                  ),

                                if ((_shouldShow('SpO2') &&
                                        hasSpo2) &&
                                    _shouldShow(
                                        'Blood Sugar') &&
                                    hasBloodSugar)
                                  const SizedBox(
                                    height: 16,
                                  ),

                                if (_shouldShow(
                                        'Blood Sugar') &&
                                    hasBloodSugar)
                                  _buildVitalItem(
                                    icon: Icons
                                        .bloodtype_outlined,
                                    label: 'Blood Sugar',
                                    value: vital
                                        .bloodSugar!
                                        .toStringAsFixed(0),
                                    unit: 'mg/dL',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // SOURCE
                      // ------------------------------------------------

                      Row(
                        children: [
                          const Icon(
                            Icons.source_outlined,
                            size: 16,
                            color: Color(0xFF43766C),
                          ),

                          const SizedBox(width: 6),

                          const Text(
                            'Source:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w500,
                              color: Color(0xFF43766C),
                            ),
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              vital.source,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    Color(0xFF1E252B),
                              ),
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // VITAL ITEM
  // ==============================================================

  Widget _buildVitalItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF43766C),
            ),

            const SizedBox(width: 6),

            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF43766C),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E252B),
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
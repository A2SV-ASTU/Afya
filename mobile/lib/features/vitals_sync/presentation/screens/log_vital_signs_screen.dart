import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/vital_sign_entity.dart';
import '../bloc/vitals_sync_bloc.dart';
import '../bloc/vitals_sync_event.dart';

// ==========================================
// 3.1 LOG ACTION MODAL (LogActionSheet)
// ==========================================
class LogActionSheet extends StatefulWidget {
  final String medicationName;
  final String dosage;
  final String route;
  final String instructions;
  final String scheduledTime;
  final int prescriptionId;
  final int currentSnoozeCount;
  final bool isFinalDose;

  const LogActionSheet({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.route,
    required this.instructions,
    required this.scheduledTime,
    required this.prescriptionId,
    this.currentSnoozeCount = 0,
    this.isFinalDose = false,
  });

  @override
  State<LogActionSheet> createState() => _LogActionSheetState();
}

class _LogActionSheetState extends State<LogActionSheet> {
  late int _snoozeCount;

  @override
  void initState() {
    super.initState();
    _snoozeCount = widget.currentSnoozeCount;
  }

  void _markAsTaken() async {
    if (widget.isFinalDose) {
      _triggerCourseCompletion(widget.prescriptionId);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dose recorded successfully'),
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _snoozeDose() {
    if (_snoozeCount >= 2) return;

    setState(() {
      _snoozeCount++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Snoozed for 10 minutes '
          '(Snooze $_snoozeCount/2)',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  void _openSkipReasonDialog() {
    final TextEditingController reasonController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason for Skipping'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason (e.g., Side effects, Nausea)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006837),
            ),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                return;
              }

              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dose skipped and recorded'),
                ),
              );
            },
            child: const Text(
              'Confirm Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerCourseCompletion(int id) async {
    // Background call placeholder.
  }

  @override
  Widget build(BuildContext context) {
    final bool maxSnoozeReached = _snoozeCount >= 2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.medicationName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.scheduledTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.dosage} • ${widget.route}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.instructions,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _markAsTaken,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006837),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mark as Taken',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: maxSnoozeReached ? null : _snoozeDose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    maxSnoozeReached
                        ? 'Max Snoozes Reached'
                        : 'Snooze (10 min)',
                    style: TextStyle(
                      color: maxSnoozeReached
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _openSkipReasonDialog,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Colors.red,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Skip Dose',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3.2 VITAL SIGN INPUT MODAL
// ==========================================
class VitalSignInputDialog extends StatefulWidget {
  const VitalSignInputDialog({
    super.key,
  });

  @override
  State<VitalSignInputDialog> createState() => _VitalSignInputDialogState();
}

class _VitalSignInputDialogState extends State<VitalSignInputDialog> {
  final Uuid _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();

  final _systolicController = TextEditingController(text: '120');
  final _diastolicController = TextEditingController(text: '80');
  final _pulseController = TextEditingController(text: '72');
  final _spo2Controller = TextEditingController(text: '98');
  final _tempController = TextEditingController(text: '98.6');
  final _respController = TextEditingController(text: '16');
  final _sugarController = TextEditingController(text: '100');
  final _weightController = TextEditingController(text: '150');

  bool _isFahrenheit = true;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _spo2Controller.dispose();
    _tempController.dispose();
    _respController.dispose();
    _sugarController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _formattedTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$minute $period';
  }

  void _onToggleTemperatureUnit(bool toFahrenheit) {
    if (_isFahrenheit == toFahrenheit) return;
    setState(() {
      _isFahrenheit = toFahrenheit;
      final current = double.tryParse(_tempController.text);
      if (current != null) {
        if (_isFahrenheit) {
          // Converted from Celsius to Fahrenheit
          final f = (current * 9 / 5) + 32;
          _tempController.text = f.toStringAsFixed(1);
        } else {
          // Converted from Fahrenheit to Celsius
          final c = (current - 32) * 5 / 9;
          _tempController.text = c.toStringAsFixed(1);
        }
      }
    });
  }

  void _saveReadings() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? tempVal = double.tryParse(_tempController.text);
    if (tempVal != null && !_isFahrenheit) {
      tempVal = (tempVal * 9 / 5) + 32;
    }

    final vital = VitalSignEntity(
      clientId: _uuid.v4(),
      systolicBp: double.tryParse(_systolicController.text),
      diastolicBp: double.tryParse(_diastolicController.text),
      pulse: int.tryParse(_pulseController.text),
      temperature: tempVal,
      spo2: double.tryParse(_spo2Controller.text),
      bloodSugar: double.tryParse(_sugarController.text),
      weight: double.tryParse(_weightController.text),
      source: 'Manual Entry',
      recordedAt: DateTime.now(),
      synced: false,
    );

    context.read<VitalsSyncBloc>().add(
      SaveVitalEvent(vital),
    );

    Navigator.of(context).pop(vital);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 420,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Header Area
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Mint Date Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFC2ECE2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 15,
                                color: Color(0xFF0E766E),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formattedTime(),
                                style: const TextStyle(
                                  color: Color(0xFF0E766E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Circular Close Button
                        Material(
                          color: const Color(0xFFF1F5F9),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Log Vital Signs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Record today's health measurements",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Vital Cards
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Blood Pressure Dual Box Card
                      _buildBloodPressureCard(),
                      const SizedBox(height: 12),

                      // Pulse Rate Card
                      _buildSingleVitalCard(
                        icon: Icons.monitor_heart_outlined,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                        title: 'PULSE RATE',
                        controller: _pulseController,
                        unitBadge: 'bpm',
                        isInteger: true,
                      ),
                      const SizedBox(height: 12),

                      // Blood Oxygen Card
                      _buildSingleVitalCard(
                        icon: Icons.air_rounded,
                        iconBg: const Color(0xFFE0F2FE),
                        iconColor: const Color(0xFF0284C7),
                        title: 'BLOOD OXYGEN',
                        controller: _spo2Controller,
                        unitBadge: '% SpO2',
                        maxValue: 100,
                      ),
                      const SizedBox(height: 12),

                      // Temperature Card with Segmented Toggle
                      _buildTemperatureCard(),
                      const SizedBox(height: 12),

                      // Respiration Card
                      _buildSingleVitalCard(
                        icon: Icons.air,
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFF9333EA),
                        title: 'RESPIRATION',
                        controller: _respController,
                        unitBadge: 'breaths/m',
                        isInteger: true,
                      ),
                      const SizedBox(height: 12),

                      // Blood Sugar Card
                      _buildSingleVitalCard(
                        icon: Icons.water_drop_outlined,
                        iconBg: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF16A34A),
                        title: 'BLOOD SUGAR',
                        controller: _sugarController,
                        unitBadge: 'mg/dL',
                        isInteger: true,
                      ),
                      const SizedBox(height: 12),

                      // Body Weight Card
                      _buildSingleVitalCard(
                        icon: Icons.scale_outlined,
                        iconBg: const Color(0xFFF1F5F9),
                        iconColor: const Color(0xFF475569),
                        title: 'BODY WEIGHT',
                        controller: _weightController,
                        unitBadge: 'lbs',
                        isDecimal: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. Pinned Bottom Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save Reading Button
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _saveReadings,
                          icon: const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Save Reading',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D7A68),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARD BUILDERS
  // ==========================================
  Widget _buildBloodPressureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mint Heart Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Color(0xFF0E766E),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BLOOD PRESSURE',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'mmHg',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Systolic sub-box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SYSTOLIC',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            TextFormField(
                              controller: _systolicController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Req' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Diastolic sub-box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DIASTOLIC',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            TextFormField(
                              controller: _diastolicController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Req' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleVitalCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required TextEditingController controller,
    required String unitBadge,
    bool isInteger = false,
    bool isDecimal = false,
    double? maxValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Input & Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: isDecimal,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        isDecimal ? r'^\d*\.?\d*' : r'^\d*',
                      ),
                    ),
                  ],
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final numVal = double.tryParse(val);
                    if (numVal == null) return 'Invalid';
                    if (maxValue != null && numVal > maxValue) {
                      return 'Max $maxValue';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          // Trailing Unit Pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unitBadge,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rose Thermometer Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.thermostat_rounded,
              color: Color(0xFFE11D48),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Temperature Input & Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TEMPERATURE',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _tempController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final numVal = double.tryParse(val);
                    if (numVal == null) return 'Invalid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          // Segmented Toggle Pill (°F / °C)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _onToggleTemperatureUnit(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isFahrenheit ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isFahrenheit
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '°F',
                      style: TextStyle(
                        color: _isFahrenheit
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onToggleTemperatureUnit(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: !_isFahrenheit ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: !_isFahrenheit
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        color: !_isFahrenheit
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3.3 PRESCRIPTION DETAIL SCREEN
// ==========================================
class PrescriptionDetailScreen
    extends StatelessWidget {
  final String medicationName;
  final String dose;
  final String route;
  final String frequency;
  final String duration;
  final String instructions;
  final String prescribingDoctor;
  final String status;

  const PrescriptionDetailScreen({
    super.key,
    required this.medicationName,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.prescribingDoctor,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    medicationName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor()
                        .withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Dose', dose),
            _buildDetailRow('Route', route),
            _buildDetailRow('Frequency', frequency),
            _buildDetailRow('Duration', duration),
            _buildDetailRow(
              'Prescribing Doctor',
              prescribingDoctor,
            ),
            _buildDetailRow(
              'Instructions',
              instructions,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Prescription modifications are made exclusively by your doctor.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
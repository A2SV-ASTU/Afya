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
  State<VitalSignInputDialog> createState() =>
      _VitalSignInputDialogState();
}

class _VitalSignInputDialogState
    extends State<VitalSignInputDialog> {
  final Uuid _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();

  final _systolicController =
      TextEditingController(text: '120');

  final _diastolicController =
      TextEditingController(text: '80');

  final _pulseController =
      TextEditingController(text: '72');

  final _spo2Controller =
      TextEditingController(text: '98');

  final _tempController =
      TextEditingController(text: '98.6');

  final _respController =
      TextEditingController(text: '16');

  final _sugarController =
      TextEditingController(text: '100');

  final _weightController =
      TextEditingController(text: '150');

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

  // ==========================================
  // SAVE VITALS
  // ==========================================
  void _saveReadings() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vital = VitalSignEntity(
      clientId: _uuid.v4(),
      systolicBp: double.tryParse(
        _systolicController.text,
      ),
      diastolicBp: double.tryParse(
        _diastolicController.text,
      ),
      pulse: int.tryParse(
        _pulseController.text,
      ),
      temperature: double.tryParse(
        _tempController.text,
      ),
      spo2: double.tryParse(
        _spo2Controller.text,
      ),
      bloodSugar: double.tryParse(
        _sugarController.text,
      ),
      weight: double.tryParse(
        _weightController.text,
      ),
      source: 'Manual Entry',
      recordedAt: DateTime.now(),
      synced: false,
    );

    debugPrint('=================================');
    debugPrint('Saving vital through VitalsSyncBloc');
    debugPrint('Client ID: ${vital.clientId}');
    debugPrint(
      'Blood Pressure: '
      '${vital.systolicBp}/${vital.diastolicBp}',
    );
    debugPrint('Pulse: ${vital.pulse}');
    debugPrint('Temperature: ${vital.temperature}');
    debugPrint('SpO2: ${vital.spo2}');
    debugPrint('Blood Sugar: ${vital.bloodSugar}');
    debugPrint('Weight: ${vital.weight}');
    debugPrint('Source: ${vital.source}');
    debugPrint('Recorded At: ${vital.recordedAt}');
    debugPrint('Synced: ${vital.synced}');
    debugPrint('=================================');

    context.read<VitalsSyncBloc>().add(
      SaveVitalEvent(vital),
    );

    Navigator.of(context).pop(vital);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Your Vitals',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black87,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDualVitalInput(
                        icon: Icons.favorite_border,
                        leftTitle: 'Systolic',
                        leftController: _systolicController,
                        rightTitle: 'Diastolic',
                        rightController: _diastolicController,
                        unit: 'mmHg',
                      ),
                      const SizedBox(height: 12),

                      _buildSingleVitalInput(
                        icon: Icons.show_chart,
                        title: 'Pulse',
                        controller: _pulseController,
                        unit: 'bpm',
                      ),
                      const SizedBox(height: 12),

                      _buildSingleVitalInput(
                        icon: Icons.air,
                        title: 'SpO2',
                        controller: _spo2Controller,
                        unit: '%',
                        maxValue: 100,
                      ),
                      const SizedBox(height: 12),

                      _buildSingleVitalInput(
                        icon: Icons.thermostat,
                        title: 'Temperature',
                        controller: _tempController,
                        unit: '°F',
                        isDecimal: true,
                      ),
                      const SizedBox(height: 12),

                      _buildSingleVitalInput(
                        icon: Icons.personal_injury_outlined,
                        title: 'Respiration',
                        controller: _respController,
                        unit: 'bpm',
                      ),
                      const SizedBox(height: 12),

                      _buildSingleVitalInput(
                        icon: Icons.water_drop_outlined,
                        title: 'Blood Sugar',
                        controller: _sugarController,
                        unit: 'mg/dL',
                      ),
                      const SizedBox(height: 12),

                      _buildSingleVitalInput(
                        icon: Icons.scale_outlined,
                        title: 'Weight',
                        controller: _weightController,
                        unit: 'lbs',
                        isDecimal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveReadings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF006837),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Reading',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SINGLE VITAL INPUT
  // ==========================================
  Widget _buildSingleVitalInput({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String unit,
    bool isDecimal = false,
    double? maxValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1F5F5B),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: controller,
                  keyboardType:
                      TextInputType.numberWithOptions(
                    decimal: isDecimal,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        isDecimal
                            ? r'^\d*\.?\d*'
                            : r'^\d*',
                      ),
                    ),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Required';
                    }

                    final numVal = double.tryParse(val);

                    if (numVal == null) {
                      return 'Invalid';
                    }

                    if (maxValue != null &&
                        numVal > maxValue) {
                      return 'Max $maxValue';
                    }

                    return null;
                  },
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),

                  // THIS MAKES THE PATIENT INPUT AREA GREEN
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xFFE8F2EC),
                  ),
                ),
              ],
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ==========================================
  // DUAL VITAL INPUT
  // ==========================================
  Widget _buildDualVitalInput({
    required IconData icon,
    required String leftTitle,
    required TextEditingController leftController,
    required String rightTitle,
    required TextEditingController rightController,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1F5F5B),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  leftTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: leftController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) =>
                      v == null || v.isEmpty
                          ? 'Req'
                          : null,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),

                  // SYSTOLIC INPUT AREA
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xFFE8F2EC),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.black12,
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  rightTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: rightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) =>
                      v == null || v.isEmpty
                          ? 'Req'
                          : null,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),

                  // DIASTOLIC INPUT AREA
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xFFE8F2EC),
                  ),
                ),
              ],
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
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
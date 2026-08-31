class VitalSignEntity {
  final String clientId;
  final double? systolicBp;
  final double? diastolicBp;
  final int? pulse;
  final double? temperature;
  final double? spo2;
  final double? bloodSugar;
  final double? weight;
  final String source;
  final DateTime recordedAt;
  final bool synced;

  const VitalSignEntity({
    required this.clientId,
    this.systolicBp,
    this.diastolicBp,
    this.pulse,
    this.temperature,
    this.spo2,
    this.bloodSugar,
    this.weight,
    required this.source,
    required this.recordedAt,
    this.synced = false,
  });
}
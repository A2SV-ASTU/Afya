import 'package:equatable/equatable.dart';

class DoseTime extends Equatable {
  final int hour;
  final int minute;

  const DoseTime({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour < 24, 'Hour must be between 0 and 23'),
        assert(minute >= 0 && minute < 60, 'Minute must be between 0 and 59');

  const DoseTime.at(this.hour, [this.minute = 0])
      : assert(hour >= 0 && hour < 24, 'Hour must be between 0 and 23'),
        assert(minute >= 0 && minute < 60, 'Minute must be between 0 and 59');

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class PosologyParser {
  const PosologyParser();

  static const DoseTime morning = DoseTime(hour: 8, minute: 0);
  static const DoseTime midday = DoseTime(hour: 12, minute: 0);
  static const DoseTime afternoon = DoseTime(hour: 14, minute: 0);
  static const DoseTime lateAfternoon = DoseTime(hour: 16, minute: 0);
  static const DoseTime evening = DoseTime(hour: 20, minute: 0);

  /// Parses a freeform or preset frequency string into scheduled daily [DoseTime] slots.
  ///
  /// Returns:
  /// - An empty list `[]` for PRN / "as needed" dosing (no scheduled alarms).
  /// - A list of [DoseTime] objects for recognized daily frequencies.
  /// - `null` for unknown / unrecognized frequencies.
  List<DoseTime>? parseFrequency(String frequency) {
    final clean = frequency.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 1. As needed (PRN)
    if (clean == 'prn' ||
        clean.contains('as needed') ||
        clean.contains('(prn)')) {
      return const [];
    }

    // 2. Once daily Evening
    if (clean.contains('evening') || clean.contains('night')) {
      if (clean.contains('od') ||
          clean.contains('once daily') ||
          clean.contains('once a day')) {
        return const [evening];
      }
    }

    // 3. Four times daily (QDS / QID)
    if (clean.contains('qds') ||
        clean.contains('qid') ||
        clean.contains('four times') ||
        clean.contains('4 times') ||
        clean == 'every 6 hours') {
      return const [morning, midday, lateAfternoon, evening];
    }

    // 4. Three times daily (TDS / TID / Every 8 hours)
    if (clean.contains('tds') ||
        clean.contains('tid') ||
        clean.contains('three times') ||
        clean.contains('3 times') ||
        clean.contains('every 8 hours') ||
        clean == 'every 8 hours' ||
        clean == 'every 8 hrs' ||
        clean == 'q8h') {
      return const [morning, afternoon, evening];
    }

    // 5. Twice daily (BD / BID / Every 12 hours)
    if (clean.contains('bd') ||
        clean.contains('bid') ||
        clean.contains('twice daily') ||
        clean.contains('twice a day') ||
        clean.contains('2 times') ||
        clean == 'every 12 hours' ||
        clean == 'every 12 hrs' ||
        clean == 'q12h') {
      return const [morning, evening];
    }

    // 6. Once daily (OD / QD / Morning default)
    if (clean.contains('od') ||
        clean.contains('qd') ||
        clean.contains('once daily') ||
        clean.contains('once a day') ||
        clean.contains('1 time') ||
        clean.contains('daily')) {
      return const [morning];
    }

    return null;
  }

  /// Parses a duration string into total duration in days.
  ///
  /// Supports days, weeks, months.
  /// Returns `null` for invalid or unparseable input (never defaults).
  int? parseDurationInDays(String duration) {
    final clean = duration.trim().toLowerCase();
    if (clean.isEmpty) return null;

    if (clean.startsWith('-') || clean.contains(' -')) {
      return null;
    }

    final regex =
        RegExp(r'(\d+)\s*(day|days|week|weeks|month|months|mo|d|wk)?');
    final match = regex.firstMatch(clean);
    if (match == null) return null;

    final numberStr = match.group(1);
    if (numberStr == null) return null;

    final number = int.tryParse(numberStr);
    if (number == null || number <= 0) return null;

    final unit = match.group(2);
    if (unit != null) {
      if (unit.startsWith('month') || unit == 'mo') {
        return number * 30;
      } else if (unit.startsWith('week') || unit == 'wk') {
        return number * 7;
      } else if (unit.startsWith('day') || unit == 'd') {
        return number;
      }
    }

    if (clean.contains('day') || clean.contains(' d')) {
      return number;
    } else if (clean.contains('month') || clean.contains(' mo')) {
      return number * 30;
    } else if (clean.contains('week') || clean.contains(' wk')) {
      return number * 7;
    }

    if (RegExp(r'^\d+$').hasMatch(clean)) {
      return number;
    }

    return null;
  }
}

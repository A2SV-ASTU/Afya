import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/posology_parser.dart';

void main() {
  const parser = PosologyParser();

  group('PosologyParser - Frequency Parsing', () {
    test('parses Once daily (OD) variations to 08:00', () {
      const expected = [DoseTime(hour: 8, minute: 0)];

      expect(parser.parseFrequency('Once daily (OD)'), expected);
      expect(parser.parseFrequency('OD'), expected);
      expect(parser.parseFrequency('Once daily'), expected);
      expect(parser.parseFrequency('Once daily (OD - Morning)'), expected);
      expect(parser.parseFrequency('Once daily (OD) in the morning'), expected);
      expect(parser.parseFrequency('once daily'), expected);
      expect(parser.parseFrequency('od'), expected);
      expect(parser.parseFrequency('  OD  '), expected);
    });

    test('parses Once daily Evening to 20:00', () {
      const expected = [DoseTime(hour: 20, minute: 0)];

      expect(parser.parseFrequency('Once daily (OD - Evening)'), expected);
      expect(parser.parseFrequency('Once daily at night'), expected);
      expect(parser.parseFrequency('OD evening'), expected);
      expect(parser.parseFrequency('ONCE DAILY AT NIGHT'), expected);
    });

    test('parses Twice daily (BD / BID) to 08:00, 20:00', () {
      const expected = [
        DoseTime(hour: 8, minute: 0),
        DoseTime(hour: 20, minute: 0),
      ];

      expect(parser.parseFrequency('Twice daily (BD)'), expected);
      expect(parser.parseFrequency('BD'), expected);
      expect(parser.parseFrequency('BID'), expected);
      expect(parser.parseFrequency('Twice daily'), expected);
      expect(parser.parseFrequency('Twice daily (BD) after meals'), expected);
      expect(parser.parseFrequency('every 12 hours'), expected);
      expect(parser.parseFrequency('Every 12 hours'), expected);
      expect(parser.parseFrequency('EVERY 12 HOURS'), expected);
    });

    test(
        'parses Three times daily (TDS / TID / Every 8 hours) to 08:00, 14:00, 20:00',
        () {
      const expected = [
        DoseTime(hour: 8, minute: 0),
        DoseTime(hour: 14, minute: 0),
        DoseTime(hour: 20, minute: 0),
      ];

      expect(parser.parseFrequency('Three times daily (TDS)'), expected);
      expect(parser.parseFrequency('TDS'), expected);
      expect(parser.parseFrequency('TID'), expected);
      expect(parser.parseFrequency('Three times daily'), expected);
      expect(parser.parseFrequency('Every 8 hours'), expected);
      expect(parser.parseFrequency('every 8 hours'), expected);
    });

    test('parses Four times daily (QDS / QID) to 08:00, 12:00, 16:00, 20:00',
        () {
      const expected = [
        DoseTime(hour: 8, minute: 0),
        DoseTime(hour: 12, minute: 0),
        DoseTime(hour: 16, minute: 0),
        DoseTime(hour: 20, minute: 0),
      ];

      expect(parser.parseFrequency('Four times daily (QDS)'), expected);
      expect(parser.parseFrequency('QDS'), expected);
      expect(parser.parseFrequency('QID'), expected);
      expect(parser.parseFrequency('Four times daily'), expected);
      expect(parser.parseFrequency('every 6 hours'), expected);
      expect(parser.parseFrequency('Every 6 hours'), expected);
    });

    test('parses As needed (PRN) to empty list (no scheduled alarms)', () {
      expect(parser.parseFrequency('As needed (PRN)'), isEmpty);
      expect(parser.parseFrequency('PRN'), isEmpty);
      expect(parser.parseFrequency('As needed'), isEmpty);
      expect(parser.parseFrequency('prn'), isEmpty);
      expect(parser.parseFrequency('  as needed (prn)  '), isEmpty);
    });

    test(
        'returns null for unknown or empty frequency without creating fake schedule',
        () {
      expect(parser.parseFrequency(''), isNull);
      expect(parser.parseFrequency('   '), isNull);
      expect(parser.parseFrequency('random unknown text'), isNull);
      expect(parser.parseFrequency('stat'), isNull);
      expect(parser.parseFrequency('weekly'), isNull);
    });
  });

  group('PosologyParser - Duration Parsing', () {
    test('parses day durations correctly', () {
      expect(parser.parseDurationInDays('1 day'), 1);
      expect(parser.parseDurationInDays('3 days'), 3);
      expect(parser.parseDurationInDays('5 days'), 5);
      expect(parser.parseDurationInDays('7 days'), 7);
      expect(parser.parseDurationInDays('14 days'), 14);
      expect(parser.parseDurationInDays('30 days'), 30);
      expect(parser.parseDurationInDays('90 days'), 90);
      expect(parser.parseDurationInDays('120 days'), 120);
      expect(parser.parseDurationInDays('30 days (1 month refill)'), 30);
    });

    test('parses week durations correctly (x7)', () {
      expect(parser.parseDurationInDays('1 week'), 7);
      expect(parser.parseDurationInDays('2 weeks'), 14);
      expect(parser.parseDurationInDays('3 weeks'), 21);
      expect(parser.parseDurationInDays('4 weeks'), 28);
      expect(parser.parseDurationInDays('12 weeks'), 84);
    });

    test('parses month durations correctly (x30)', () {
      expect(parser.parseDurationInDays('1 month'), 30);
      expect(parser.parseDurationInDays('2 months'), 60);
      expect(parser.parseDurationInDays('3 months'), 90);
      expect(parser.parseDurationInDays('6 months'), 180);
      expect(parser.parseDurationInDays('12 months'), 360);
    });

    test('handles case variations and whitespace', () {
      expect(parser.parseDurationInDays(' 7 DAYS '), 7);
      expect(parser.parseDurationInDays('2 Weeks'), 14);
      expect(parser.parseDurationInDays('1 Month'), 30);
      expect(parser.parseDurationInDays('  3 MONTHS  '), 90);
    });

    test(
        'returns null for invalid/empty durations without defaulting to 7 days',
        () {
      expect(parser.parseDurationInDays(''), isNull);
      expect(parser.parseDurationInDays('   '), isNull);
      expect(parser.parseDurationInDays('no duration'), isNull);
      expect(parser.parseDurationInDays('0 days'), isNull);
      expect(parser.parseDurationInDays('-5 days'), isNull);
      expect(parser.parseDurationInDays('0 weeks'), isNull);
      expect(parser.parseDurationInDays('-1 month'), isNull);
      expect(parser.parseDurationInDays('abc days'), isNull);
    });
  });

  group('DoseTime Value Object', () {
    test('equality and props work accurately', () {
      const dt1 = DoseTime(hour: 8, minute: 30);
      const dt2 = DoseTime(hour: 8, minute: 30);
      const dt3 = DoseTime(hour: 20, minute: 0);

      expect(dt1, equals(dt2));
      expect(dt1, isNot(equals(dt3)));
      expect(dt1.toString(), '08:30');
      expect(dt3.toString(), '20:00');
    });

    test('DoseTime.at constructor defaults minute to 0', () {
      const dt = DoseTime.at(14);
      expect(dt.hour, 14);
      expect(dt.minute, 0);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/access_requests/presentation/utils/countdown_timer_helper.dart';

void main() {
  group('CountdownTimerHelper', () {
    group('remainingSeconds', () {
      test('should return 0 when expiresAt is in the past', () {
        final past = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
        expect(CountdownTimerHelper.remainingSeconds(past), 0);
      });

      test('should return positive seconds when expiresAt is in the future', () {
        final future = DateTime.now().toUtc().add(const Duration(seconds: 120));
        final result = CountdownTimerHelper.remainingSeconds(future);
        expect(result, greaterThanOrEqualTo(119));
        expect(result, lessThanOrEqualTo(121));
      });

      test('should return 0 when expiresAt is exactly now', () {
        final now = DateTime.now().toUtc();
        final result = CountdownTimerHelper.remainingSeconds(now);
        expect(result, inInclusiveRange(0, 1));
      });
    });

    group('formatRemaining', () {
      test('should format seconds as M:SS', () {
        expect(CountdownTimerHelper.formatRemaining(245), '4:05');
      });

      test('should format zero seconds as 0:00', () {
        expect(CountdownTimerHelper.formatRemaining(0), '0:00');
      });

      test('should pad single digit seconds', () {
        expect(CountdownTimerHelper.formatRemaining(12), '0:12');
      });

      test('should format exact minute as M:00', () {
        expect(CountdownTimerHelper.formatRemaining(60), '1:00');
      });

      test('should format 59 seconds as 0:59', () {
        expect(CountdownTimerHelper.formatRemaining(59), '0:59');
      });

      test('should format large values correctly', () {
        expect(CountdownTimerHelper.formatRemaining(3661), '61:01');
      });
    });
  });
}

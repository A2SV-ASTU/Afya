/// Helper utility for calculating and formatting remaining time on access requests.
class CountdownTimerHelper {
  const CountdownTimerHelper._();

  /// Calculates remaining seconds from [expiresAt] to now (both UTC).
  static int remainingSeconds(DateTime expiresAt) {
    final now = DateTime.now().toUtc();
    final expires = expiresAt.toUtc();
    final difference = expires.difference(now).inSeconds;
    return difference < 0 ? 0 : difference;
  }

  /// Formats remaining [seconds] into `M:SS` string (e.g. `4:05`, `0:12`).
  static String formatRemaining(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

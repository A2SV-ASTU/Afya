class CountdownTimerHelper {
  CountdownTimerHelper._();

  static int remainingSeconds(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }

  static String formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) return '0:00';
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static bool isExpired(DateTime target) {
    return DateTime.now().isAfter(target);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that displays a live countdown until [expiresAt].
/// It updates every second and changes colour based on the remaining minutes.
class CountdownTimerWidget extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback? onTimerComplete;
  const CountdownTimerWidget({super.key, required this.expiresAt, this.onTimerComplete});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with WidgetsBindingObserver {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateRemaining();
    }
  }

  void _startTimer() {
    _updateRemaining();
    if (_remaining > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
    }
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = widget.expiresAt.difference(now);
      if (_remaining.isNegative || _remaining == Duration.zero) {
        final wasActive = _timer?.isActive ?? false;
        _remaining = Duration.zero;
        _timer?.cancel();
        _timer = null;
        if (wasActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onTimerComplete?.call();
          });
        }
      }
    });
  }

  /// Returns a human-readable label for [_remaining]:
  ///   ≥ 60 min  → "Xh Ym left"
  ///   1–59 min  → "Xm Ys left"
  ///   < 1 min   → "Xs left"
  ///   zero      → "Expired"
  String _formatRemaining() {
    if (_remaining == Duration.zero) return 'Expired';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h >= 1) return '${h}h ${m}m left';
    if (m >= 1) return '${m}m ${s}s left';
    return '${s}s left';
  }

  @override
  Widget build(BuildContext context) {
    final minutesLeft = _remaining.inMinutes;
    final bool expired = _remaining == Duration.zero;

    final Color bgColor;
    final Color textColor;

    if (expired || minutesLeft <= 2) {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else if (minutesLeft <= 60) {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
    } else {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        _formatRemaining(),
        style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedFloatingBackground extends StatefulWidget {
  final Widget child;

  const AnimatedFloatingBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedFloatingBackground> createState() => _AnimatedFloatingBackgroundState();
}

class _AnimatedFloatingBackgroundState extends State<AnimatedFloatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF004D47),
            Color(0xFF006A60),
            Color(0xFF005B52),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated floating pill shapes matching design
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final val = _controller.value;
              final sinVal = math.sin(val * math.pi * 2);
              final cosVal = math.cos(val * math.pi * 2);

              return Stack(
                children: [
                  // Pill 1 - Top Left
                  Positioned(
                    top: size.height * 0.16 + (sinVal * 12),
                    left: size.width * 0.12 + (cosVal * 8),
                    child: _buildFloatingPill(width: 80, height: 38, opacity: 0.18),
                  ),

                  // Pill 2 - Top Right
                  Positioned(
                    top: size.height * 0.25 - (cosVal * 15),
                    right: size.width * 0.22 + (sinVal * 10),
                    child: _buildFloatingPill(width: 44, height: 20, opacity: 0.15),
                  ),

                  // Pill 3 - Middle Right
                  Positioned(
                    top: size.height * 0.40 + (sinVal * 18),
                    right: -20 + (cosVal * 12),
                    child: _buildFloatingPill(width: 100, height: 56, opacity: 0.20),
                  ),

                  // Pill 4 - Middle Left
                  Positioned(
                    top: size.height * 0.58 - (sinVal * 10),
                    left: size.width * 0.52 + (cosVal * 14),
                    child: _buildFloatingPill(width: 86, height: 40, opacity: 0.16),
                  ),

                  // Pill 5 - Bottom Left
                  Positioned(
                    top: size.height * 0.68 + (cosVal * 12),
                    left: size.width * 0.20 - (sinVal * 8),
                    child: _buildFloatingPill(width: 62, height: 30, opacity: 0.18),
                  ),

                  // Pill 6 - Center top subtle accent
                  Positioned(
                    top: size.height * 0.08 + (cosVal * 6),
                    left: size.width * 0.40 - (sinVal * 10),
                    child: _buildFloatingPill(width: 50, height: 24, opacity: 0.12),
                  ),
                ],
              );
            },
          ),

          // Foreground child
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPill({
    required double width,
    required double height,
    required double opacity,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center circular icon badge with green sprout
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFA2C7BB), // Soft sage green circle matching design
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(44, 44),
                  painter: _SproutIconPainter(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'How can I help you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2825),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Ask Afya AI a health-related\nquestion or ask about your\ninformation in the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: Color(0xFF6B7A75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the exact two-leaf sprout icon from the design
class _SproutIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF125648) // Dark teal green sprout color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Stem
    path.moveTo(width * 0.47, height * 0.9);
    path.quadraticBezierTo(
      width * 0.48,
      height * 0.55,
      width * 0.49,
      height * 0.45,
    );

    // Left leaf
    final leftLeaf = Path();
    leftLeaf.moveTo(width * 0.48, height * 0.55);
    leftLeaf.cubicTo(
      width * 0.15, height * 0.5,
      width * 0.1, height * 0.25,
      width * 0.35, height * 0.25,
    );
    leftLeaf.cubicTo(
      width * 0.45, height * 0.25,
      width * 0.48, height * 0.4,
      width * 0.48, height * 0.55,
    );

    // Right leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(width * 0.5, height * 0.45);
    rightLeaf.cubicTo(
      width * 0.52, height * 0.25,
      width * 0.65, height * 0.1,
      width * 0.88, height * 0.12,
    );
    rightLeaf.cubicTo(
      width * 0.92, height * 0.35,
      width * 0.72, height * 0.45,
      width * 0.5, height * 0.45,
    );

    // Small highlight accent dot on top right
    final accentPaint = Paint()
      ..color = const Color(0xFF125648)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width * 0.86, height * 0.08), 2.5, accentPaint);

    canvas.drawPath(leftLeaf, paint);
    canvas.drawPath(rightLeaf, paint);

    // Draw thick stem line
    final stemPaint = Paint()
      ..color = const Color(0xFF125648)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final stemPath = Path();
    stemPath.moveTo(width * 0.48, height * 0.95);
    stemPath.quadraticBezierTo(
      width * 0.48,
      height * 0.65,
      width * 0.49,
      height * 0.45,
    );
    canvas.drawPath(stemPath, stemPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

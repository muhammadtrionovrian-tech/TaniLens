import 'package:flutter/material.dart';

class ScannerLinePainter extends CustomPainter {
  final double position; // Ranges from 0.0 to 1.0
  final Color scannerColor;

  ScannerLinePainter({
    required this.position,
    this.scannerColor = const Color(0xFF66BB6A), // Bright neon-like green
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * position;
    
    // 1. Draw a soft, semi-transparent green glow trailing above and below the scanner line
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          scannerColor.withValues(alpha: 0.0),
          scannerColor.withValues(alpha: 0.15),
          scannerColor.withValues(alpha: 0.4), // Core glow intensity
          scannerColor.withValues(alpha: 0.15),
          scannerColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(
        Rect.fromLTRB(0, y - 25, size.width, y + 25),
      );

    // Glow boundary rect
    final glowRect = Rect.fromLTRB(0, y - 25, size.width, y + 25);
    canvas.drawRect(glowRect, glowPaint);

    // 2. Draw the core sharp laser line
    final linePaint = Paint()
      ..color = scannerColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Optional horizontal blur/shadow to make the core line look extremely high-end
    final shadowPaint = Paint()
      ..color = scannerColor.withValues(alpha: 0.8)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(Offset(0, y), Offset(size.width, y), shadowPaint);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant ScannerLinePainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.scannerColor != scannerColor;
  }
}

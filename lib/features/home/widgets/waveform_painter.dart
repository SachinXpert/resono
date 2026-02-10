import 'dart:math';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final Color color;
  final double progress; // 0.0 to 1.0

  WaveformPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final barWidth = 2.0;
    final gap = 1.5;
    final totalBars = size.width / (barWidth + gap);
    
    // Use a fixed seed so the waveform looks the same for the same width
    final random = Random(42); 

    for (int i = 0; i < totalBars; i++) {
        final x = i * (barWidth + gap);
        // Random height between 20% and 100% of height
        final height = (random.nextDouble() * 0.8 + 0.2) * size.height;
        final y = (size.height - height) / 2;

        final isPlayed = (i / totalBars) <= progress;
        paint.color = isPlayed ? color : color.withOpacity(0.3);

        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barWidth, height),
            const Radius.circular(2)
        );
        canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
     return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

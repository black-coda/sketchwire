import 'package:flutter/material.dart';

/// Custom painter for drawing a sketchy grid pattern
class SketchyGridPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;
  final double roughness;

  SketchyGridPainter({
    required this.gridSize,
    required this.gridColor,
    this.roughness = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      _drawSketchyLine(canvas, paint, Offset(x, 0), Offset(x, size.height));
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      _drawSketchyLine(canvas, paint, Offset(0, y), Offset(size.width, y));
    }
  }

  /// Draw a sketchy line with slight variations for hand-drawn effect
  void _drawSketchyLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Calculate the distance and number of segments
    final distance = (end - start).distance;
    final segments = (distance / 10).ceil();

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;

      // Add slight random variation for sketchy effect
      final variation = roughness * 0.5;
      final offsetX = (i % 2 == 0 ? variation : -variation) * 0.3;
      final offsetY = (i % 3 == 0 ? variation : -variation) * 0.3;

      path.lineTo(x + offsetX, y + offsetY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SketchyGridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.roughness != roughness;
  }
}

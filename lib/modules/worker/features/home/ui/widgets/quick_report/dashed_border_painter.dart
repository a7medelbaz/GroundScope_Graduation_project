import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for drawing dashed borders with rounded corners
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  const DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double totalDashLength = dashWidth + dashSpace;

    // Top line
    double currentOffset = 0;
    while (currentOffset < size.width - borderRadius * 2) {
      canvas.drawLine(
        Offset(borderRadius + currentOffset, strokeWidth / 2),
        Offset(borderRadius + currentOffset + dashWidth, strokeWidth / 2),
        dashPaint,
      );
      currentOffset += totalDashLength;
    }

    // Bottom line
    currentOffset = 0;
    while (currentOffset < size.width - borderRadius * 2) {
      canvas.drawLine(
        Offset(borderRadius + currentOffset, size.height - strokeWidth / 2),
        Offset(borderRadius + currentOffset + dashWidth, size.height - strokeWidth / 2),
        dashPaint,
      );
      currentOffset += totalDashLength;
    }

    // Left line
    currentOffset = 0;
    while (currentOffset < size.height - borderRadius * 2) {
      canvas.drawLine(
        Offset(strokeWidth / 2, borderRadius + currentOffset),
        Offset(strokeWidth / 2, borderRadius + currentOffset + dashWidth),
        dashPaint,
      );
      currentOffset += totalDashLength;
    }

    // Right line
    currentOffset = 0;
    while (currentOffset < size.height - borderRadius * 2) {
      canvas.drawLine(
        Offset(size.width - strokeWidth / 2, borderRadius + currentOffset),
        Offset(size.width - strokeWidth / 2, borderRadius + currentOffset + dashWidth),
        dashPaint,
      );
      currentOffset += totalDashLength;
    }

    // Draw rounded corners with arcs
    // Top-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, 0, borderRadius * 2, borderRadius * 2),
      math.pi,
      math.pi / 2,
      false,
      dashPaint,
    );

    // Top-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - borderRadius * 2, 0, borderRadius * 2, borderRadius * 2),
      -math.pi / 2,
      math.pi / 2,
      false,
      dashPaint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - borderRadius * 2, borderRadius * 2, borderRadius * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      dashPaint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - borderRadius * 2, size.height - borderRadius * 2, borderRadius * 2, borderRadius * 2),
      0,
      math.pi / 2,
      false,
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}





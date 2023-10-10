import 'dart:math' as math;
import 'package:flutter/material.dart';

class EcgPainter extends CustomPainter {
  final List<int> data;

  // Add a flag to switch between the views.
  final bool renderFromRightToLeft;

  EcgPainter({
    required this.data,
    this.renderFromRightToLeft = true, // by default, it's set to true.
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (data.isEmpty) {
      return;
    }

    double maxValue = data.reduce(math.max).toDouble();
    double minValue = data.reduce(math.min).toDouble();
    double dx = size.width / (data.length - 1);
    double paddingFactor = 0.1; // 10% padding.

    double range = maxValue - minValue;
    if (range == 0) {
      range = 1; // To prevent division by zero.
    }

    double effectiveHeight =
        size.height * (1 - 2 * paddingFactor); // 80% of the total height.
    double verticalScaling = effectiveHeight / range;

    for (int i = 0; i < data.length - 1; i++) {
      double startX = renderFromRightToLeft ? size.width - dx * i : dx * i;
      double endX =
      renderFromRightToLeft ? size.width - dx * (i + 1) : dx * (i + 1);

      double startY = size.height -
          (data[i] - minValue) * verticalScaling -
          size.height * paddingFactor;
      double endY = size.height -
          (data[i + 1] - minValue) * verticalScaling -
          size.height * paddingFactor;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint to reflect real-time changes.
  }
}

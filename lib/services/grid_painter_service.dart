import 'package:flutter/material.dart';

//수정할 거 없음. 검토 완료.

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintThin = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    final paintThick = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double stepSizeX = size.width / 50;
    double stepSizeY = size.height / 25;

    for (int i = 0; i <= 50; i++) {
      double x = stepSizeX * i;
      if (i % 5 == 0) { // 큰 사각형의 선
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintThick);
      } else { // 작은 사각형의 선
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintThin);
      }
    }

    for (int j = 0; j <= 25; j++) {
      double y = stepSizeY * j;
      if (j % 5 == 0) { // 큰 사각형의 선.
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paintThick);
      } else { // 작은 사각형의 선.
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paintThin);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

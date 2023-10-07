import 'package:flutter/material.dart';
import 'dart:math' as math;

//CustomPainter로 차트를 그려 보자.
//Flutter에서 캔버스에 직접 그림을 그릴 때 CustomPainter를 사용한다.
class EcgPainter extends CustomPainter {
  //ECG 데이터를 저장하는 멤버 변수.
  final List<int> data;

  //생성자가 ECG 데이터를 받아 와서 클래스 내부의 data 변수에 할당한다.
  EcgPainter({required this.data});

  //paint 메서드가 실제로 그림을 그린다.
  @override
  void paint(Canvas canvas, Size size) {
    //Paint 객체는 그림을 그릴 때 필요한 정보(색상, 선 스타일, 두께 등)을 포함한다.
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    //Path 객체는 차트를 그릴 경로를 정의한다.
    final path = Path();
    //화면의 높이와 데이터의 최대 및 최소값을 기반으로 ECG 데이터를 화면에 맞게 조절한다.
    final scaleFactor =
        size.height / (data.reduce(math.max) - data.reduce(math.min));
    //middle은 화면의 중간 높이다.
    final middle = size.height / 2;

    //for 루프는 각 ECG 데이터 포인트를 순회하며 경로에 라인을 추가한다.
    //x축은 시간(샘플링 주파수에 따른 시간).
    //y축은 ECG의 전압이다.
    for (int i = 0; i < data.length; i++) {
      final pointY = middle - data[i] * scaleFactor;
      if (i == 0) {
        path.moveTo(0, pointY);
      } else {
        path.lineTo(i.toDouble(), pointY);
      }
    }

    //얘가 위 내용을 바탕으로 경로를 화면에 그린다.
    canvas.drawPath(path, paint);
  }

  //새 데이터가 제공될 때마다 그림을 다시 그려야 하는 지 여부를 결정하는 메서드.
  //본 프로젝트에서 사용되지 않음.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'ecg_painter_service.dart';
import 'grid_painter_service.dart';

class RealTimeEcgChart extends StatefulWidget {
  final List<int> allData;

  const RealTimeEcgChart({super.key, required this.allData});

  @override
  RealTimeEcgChartState createState() => RealTimeEcgChartState();
}

class RealTimeEcgChartState extends State<RealTimeEcgChart> {
  late Timer _timer;
  List<int> currentData = [];
  int currentDataIndex = 0;
  int dataPointsPerUpdate = 100; // 이 값을 조절하여 업데이트 속도를 조절.

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 240), (timer) {
      // 250 data points in 1 minute => 4 updates per second
      _updateChartData();
    });
  }

  void _updateChartData() {
    setState(() {
      int nextDataIndex = currentDataIndex + dataPointsPerUpdate;
      if (nextDataIndex >= widget.allData.length) {
        // 리스트를 초기화하고 인덱스를 0으로 리셋.
        currentData.clear();
        currentDataIndex = 0;
      } else {
        currentData
            .addAll(widget.allData.sublist(currentDataIndex, nextDataIndex));
        currentDataIndex = nextDataIndex;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      child: CustomPaint(
        painter: EcgPainter(data: currentData),
        child: Container(),
      ),
    );
  }
}

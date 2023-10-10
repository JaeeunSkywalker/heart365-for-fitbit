import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../models/ecg_reading.dart';

//수정할 거 없음. 검토 완료.

//현재 스트림을 3개 관리 중.
//그 중 두 번째가 ECG Data Stream(내가 지은 이름)!
//값이 다음과 같이 리턴됩니다.
// [EcgReading
// (startTime: 2023-09-27T13:37:17.934,
// averageHeartRate: 63,
// resultClassification: Normal Sinus Rhythm,
// waveformSamples: [2780, 2795, 2785, 2716, 2586, 2448, 2360, 2321, 2296, 2274, 2260, 2256, 2255, 2253, 2250, 2246, 2235, 2214, 2188, 2159, 2124, 2101, 2149, 2278, 2363, 2285, 2072, 1828, 1642, 1591, 1712, 1924, 2082, 2017, 1479, 295, -1380, -3154, -4639, -5474, -5410, -4531, -3187, -1785, -725, -223, -152, -237, -314, -351, -363, -372, -395, -447, -529, -618, -675, -687, -664, -627, -598, -601, -664, -791, -932, -1020, -1045, -1044, -1050, -1078, -1133, -1201, -1250, -1268, -1274, -1299, -1360, -1447, -1534, -1604, -1655, -1700, -1789, -1961, -2174, -2346, -2462, -2568, -2693, -2844, -3020, -3196, -3330, -3410, -3471, -3559, -3684, -3810, -3914, -4018, -4126, -4205, -4238, -4244, -4247, -4267, -4307, -4353, -4375, -4359, -4292, -4133, -3819, -3379, -2904, -2449, -2067, -1839, -1757, -1719, -1638, -1496, -1331, -1188, -1059, -917, -792, -713, -650, -552,

class EcgDataController {
  final ecgReadingDataController = BehaviorSubject<List<EcgReading>>.seeded([
    EcgReading(
      waveformSamples: [],
      startTime: '',
      averageHeartRate: 0,
      resultClassification: '',
    )
  ]);

  static StreamController<List<EcgReading>> _createEcgReadingDataController() {
    return StreamController<List<EcgReading>>.broadcast();
  }
}

final ecgDataController = EcgDataController();

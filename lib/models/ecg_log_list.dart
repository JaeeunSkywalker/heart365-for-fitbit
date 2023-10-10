import 'ecg_reading.dart';
import 'pagination.dart';

//수정할 거 없음. 검토 완료.

//핏빗 API에서 ECG Data request 했을 때 받는 정보 모델
//ecgReadings, pagination 두 정보를 받는다.

class EcgLogList {
  final List<EcgReading> ecgReadings;
  final Pagination pagination;

  EcgLogList({required this.ecgReadings, required this.pagination});

  @override
  String toString() {
    return 'EcgLogList(readings: $ecgReadings, pagination: $pagination)';
  }

  Map<String, dynamic> toJson() {
    return {
      'readings': ecgReadings.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

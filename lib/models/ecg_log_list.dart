import 'ecg_reading.dart';
import 'pagination.dart';

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

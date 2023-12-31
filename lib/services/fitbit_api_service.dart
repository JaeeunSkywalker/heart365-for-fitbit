import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/ecg_log_list.dart';
import '../models/ecg_reading.dart';
import '../models/pagination.dart';
import '../models/user_profile.dart';
import 'custom_interceptors_service.dart';

//수정할 거 없음. 검토 완료.

class FitbitApiService {
  final Dio _dio = Dio();

  void _initializeDio() {
    _dio.interceptors.add(CustomInterceptors(_dio));
  }

  final String _baseUrl = 'https://api.fitbit.com';
  String? accessToken;
  static const storage = FlutterSecureStorage();

  static final FitbitApiService _instance = FitbitApiService._internal();

  factory FitbitApiService() => _instance;

  FitbitApiService._internal();

  Future<void> initialize(String token) async {
    accessToken = token;
    await storage.write(key: 'accessToken', value: token);
  }

  Future<dynamic> getUserProfile(String userId) async {
    // 토큰이 없다면 저장소에서 가져옵니다.
    accessToken = await storage.read(key: 'accessToken');
    final jsonResponse = await _get('/1/user/$userId/profile.json');

    return UserProfile.fromJson(jsonResponse);
  }

  Future<EcgLogList> getEcgLogList(String userId) async {
    accessToken = await storage.read(key: 'accessToken');
    DateTime now = DateTime.now();
    // DateTime oneMonthAgo = now.subtract(const Duration(days: 30));
    String beforeDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final data = {
      // 'afterDate': afterDate,
      'beforeDate': beforeDate,
      'sort': 'desc',
      'limit': 10,
      'offset': 0
    };

    final jsonResponse =
        await _get('/1/user/$userId/ecg/list.json', data: data);

    // EcgReading 리스트로 변환.
    //ECG Log List를 불러 오면 ecgReadings, pagination 두 개의 주요 키에 먼저 접근 가능하다.
    List<EcgReading> readings = (jsonResponse['ecgReadings'] as List)
        .map((e) => EcgReading.fromJson(e))
        .toList();

    Pagination pagination = Pagination.fromJson(jsonResponse['pagination']);

    return EcgLogList(ecgReadings: readings, pagination: pagination);
  }

  Future<dynamic> _get(String path,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    final defaultHeaders = {
      'Authorization': 'Bearer $accessToken',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    _initializeDio();

    final response = await _dio.get(
      '$_baseUrl$path',
      queryParameters: data, // 쿼리 파라미터로 데이터를 추가합니다.
      options: Options(
        headers: defaultHeaders,
      ),
    );
    return response.data;
  }
}

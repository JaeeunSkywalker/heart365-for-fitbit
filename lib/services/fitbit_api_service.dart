import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FitbitApiService {
  final Dio _dio = Dio();
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

    return _get('/1/user/$userId/profile.json');
  }

  Future<dynamic> _get(String path) async {
    final response = await _dio.get(
      '$_baseUrl$path',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    return response.data;
  }
}

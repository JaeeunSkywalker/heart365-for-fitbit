import 'package:dio/dio.dart';

import '../consts/about_user.dart';
import 'storage_service.dart';

//수정할 거 없음. 검토 완료.

Future<void> getRefreshToken() async {
  var storage = StorageService.storage;

  final storedRefreshToken = await storage.read(key: 'refreshToken');

  if (storedRefreshToken == null) {
    throw Exception('Refresh token이 없습니다.');
  }

  try {
    // Access token 갱신 요청.
    final tokenResponse = await Dio().post(
      'https://api.fitbit.com/oauth2/token',
      data: {
        "client_id": clientId,
        "grant_type": "refresh_token",
        "refresh_token": storedRefreshToken,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    // 응답에서 필요한 값 추출
    Map<String, String> tokenDataToStore = {
      'accessToken': tokenResponse.data['access_token'],
      'userId': tokenResponse.data['user_id'],
      'refreshToken': tokenResponse.data['refresh_token'],
    };

    // 새로운 accessToken, userId, refreshToken 저장
    tokenDataToStore.forEach((key, value) {
      storage.write(key: key, value: value);
    });
  } catch (error) {
    print('Error refreshing token: $error');
  }
}

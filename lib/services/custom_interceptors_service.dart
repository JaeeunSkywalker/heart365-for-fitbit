import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heart365_for_fitbit/services/refresh_token_service.dart';


//수정할 거 없음. 검토 완료.

//400, 401 에러에 대응.

class CustomInterceptors extends Interceptor {
  final Dio _dio;

  CustomInterceptors(this._dio);

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    const storage = FlutterSecureStorage();

    if(err.response?.statusCode == 400) {
      //1. 스토리지에서 리프레시 토큰 삭제 후 재 발행.
      await storage.delete(key: 'refrehToken');
      getRefreshToken();

      // 2. 갱신된 액세스 토큰으로 원래의 요청 재시도.
      RequestOptions requestOptions = err.requestOptions;

      // RequestOptions 객체에서 Options 객체를 생성합니다.
      Options options = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
      );

      // 액세스 토큰을 갱신한 후, 다시 같은 요청을 재시도합니다.
      // 만약 재시도 중에도 에러가 발생한다면, 그냥 에러를 반환합니다.
      try {
        Response response = await _dio.request(
          requestOptions.path,
          options: options,
          queryParameters:
          requestOptions.queryParameters, // 필요한 경우 쿼리 파라미터도 추가합니다.
        );
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    
    if (err.response?.statusCode == 401) {
      // 1. 액세스 토큰 갱신 로직 수행.
      getRefreshToken();

      // 2. 갱신된 액세스 토큰으로 원래의 요청 재시도.
      RequestOptions requestOptions = err.requestOptions;

      // RequestOptions 객체에서 Options 객체를 생성합니다.
      Options options = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
      );

      // 액세스 토큰을 갱신한 후, 다시 같은 요청을 재시도합니다.
      // 만약 재시도 중에도 에러가 발생한다면, 그냥 에러를 반환합니다.
      try {
        Response response = await _dio.request(
          requestOptions.path,
          options: options,
          queryParameters:
              requestOptions.queryParameters, // 필요한 경우 쿼리 파라미터도 추가합니다.
        );
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }
}

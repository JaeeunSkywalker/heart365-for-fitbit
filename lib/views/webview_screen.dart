import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/about_user.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../provider/data_provider.dart';
import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  final Uri uri;
  final String originalState;
  final String codeVerifier;

  const WebViewScreen({
    Key? key,
    required this.uri,
    required this.originalState,
    required this.codeVerifier,
  }) : super(key: key);

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends ConsumerState<WebViewScreen> {
  late WebViewController controller;

  final storage = StorageService.storage;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(redirectUrl)) {
              final Uri uri = Uri.parse(request.url);
              handleReceivedUri(uri);

              //웹뷰에서 'webpage not available'를 표시하지 않기 위해 리디렉션을 중지
              //하는 코드이나 실제로 적용하면 무한 로딩 발생해서 적용하지 않음
              ref.read(hasDataStateProvider.notifier).state = true;
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('웹뷰 페이지')),
      body: WebViewWidget(controller: controller),
    );
  }

  handleReceivedUri(Uri uri) async {
    String authCode = uri.queryParameters['code']!;
    String receivedState = uri.queryParameters['state']!;

    if (widget.originalState != receivedState) {
      print('2개의 state 값이 일치하지 않습니다.');
      return;
    }

    try {
      // Access token 요청
      final tokenResponse = await Dio().post(
        'https://api.fitbit.com/oauth2/token',
        data: {
          "client_id": clientId,
          "grant_type": "authorization_code",
          "code": authCode,
          "code_verifier": widget.codeVerifier,
          "redirect_uri": redirectUrl,
          // API에 넣으라고 안 되어 있지만 안 넣으면 작동 안 됨
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      //response에서 필요한 값 추출
      Map<String, String> tokenDataToStore = {
        'accessToken': tokenResponse.data['access_token'],
        'userId': tokenResponse.data['user_id'],
        'refreshToken': tokenResponse.data['refresh_token'],
      };

      //accessToken, userId 저장
      tokenDataToStore.forEach((key, value) {
        storage.write(key: key, value: value);
      });

      var service = FitbitApiService();
      service.initialize(tokenDataToStore['accessToken']!);
      var profile = await service.getUserProfile(tokenDataToStore['userId']!);

      //메인 페이지에서 보여 줄 내용들
      final user = profile['user'];

      final Map<String, dynamic> userDataToStore = {
        'displayName': user['displayName'],
        'fullName': user['fullName'],
        'age': user['age'].toString(),
        'dateOfBirth': user['dateOfBirth'],
        'gender': user['gender'],
        //지역 관련 값을 불러 오고 싶다면 location scope을 활성화 해야 함, 우선순위 낮음
        // final String country = profile['user']['country'];
        'encodedId': user['encodedId'],
        'memberSince': user['memberSince'],
        'avatar': user['avatar'],
      };

      userDataToStore.forEach((key, value) {
        storage.write(key: key, value: value.toString());
      });

      // print(
      //     'webview_screen에서 데이터를 받아 왔습니다: ${userDataToStore.values.join(', ')}');
    } catch (e) {
      print('Dio 호출 중 다음과 같은 에러가 발생했습니다. $e');
    }
  }
}

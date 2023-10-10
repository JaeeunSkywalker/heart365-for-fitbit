import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/about_user.dart';
import 'package:heart365_for_fitbit/utils/logger_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/user_profile.dart';
import '../provider/data_provider.dart';
import '../services/data_process_service.dart';
import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';
import '../viewmodels/user_data_controller.dart';

//수정할 거 없음. 검토 완료.

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
              //로그인도 했고 데이터도 담김.
              ref.read(loginStatusProvider.notifier).state = true;
              ref.read(hasDataStateProvider.notifier).state = true;

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
      safePrint('2개의 state 값이 일치하지 않습니다.');
      return;
    }

    try {
      // Access token 요청.
      final tokenResponse = await Dio().post(
        'https://api.fitbit.com/oauth2/token',
        data: {
          "client_id": clientId,
          "grant_type": "authorization_code",
          "code": authCode,
          "code_verifier": widget.codeVerifier,
          "redirect_uri": redirectUrl,
          // API에 넣으라고 안 되어 있지만 안 넣으면 작동 안 됨.
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      //response에서 필요한 값 추출.
      Map<String, String> tokenDataToStore = {
        'accessToken': tokenResponse.data['access_token'],
        'userId': tokenResponse.data['user_id'],
        'refreshToken': tokenResponse.data['refresh_token'],
      };

      //accessToken, userId, refreshToken 저장.
      tokenDataToStore.forEach(
        (key, value) async {
          await storage.write(key: key, value: value);
        },
      );

      var service = FitbitApiService();
      service.initialize(tokenDataToStore['accessToken']!);
      //유저 기본 정보
      var userData = await service.getUserProfile(tokenDataToStore['userId']!);

      final Map<String, dynamic> userDataToStore = {
        'displayName': userData.displayName,
        'fullName': userData.fullName,
        'age': userData.age,
        'dateOfBirth': userData.dateOfBirth,
        'gender': userData.gender,
        'encodedId': userData.encodedId,
        'memberSince': userData.memberSince,
        'avatar': userData.avatar,
      };

      //userData 저장.
      userDataToStore.forEach(
        (key, value) async {
          await storage.write(key: key, value: value);
        },
      );

      //스트림에 데이터 추가.
      final userProfile = UserProfile(
        displayName: userDataToStore['displayName'],
        fullName: userDataToStore['fullName'],
        age: userDataToStore['age'],
        dateOfBirth: userDataToStore['dateOfBirth'],
        gender: userDataToStore['gender'],
        encodedId: userDataToStore['encodedId'],
        memberSince: userDataToStore['memberSince'],
        avatar: userDataToStore['avatar'],
      );

      userDataController.allOfUserDataController.add(userProfile);

      await loadExistedData(ref);

      //웹뷰에서 'webpage not available'를 표시하지 않기 위해 리디렉션을 중지.
      //하는 코드이나 실제로 적용하면 무한 로딩 발생해서 적용하지 않음.
      Navigator.pop(context);
    } catch (e) {
      safePrint('Dio 호출 중 다음과 같은 에러가 발생했습니다. $e');
    }
  }
}

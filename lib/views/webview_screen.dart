import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/about_user.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../provider/data_provider.dart';
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
      print('State values do not match!');
      return;
    }

    try {
      // Access token 요청
      final response = await Dio().post(
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

      final String accessToken = response.data['access_token'];
      print('accessToken 값 받았습니다. $accessToken');
      final String userId = response.data['user_id'];
      print('userId 값 받았습니다. $userId');

      //accessToken, userId 저장
      storage.write(key: 'accessToken', value: accessToken);
      storage.write(key: 'userId', value: userId);

      // 사용자 데이터 가져오기
      final userProfile = await Dio().get(
        'https://api.fitbit.com/1/user/-/profile.json',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      // 이후, userProfile을 처리하는 코드를 여기에 추가합니다.
    } catch (e) {
      print('Error during Dio call: $e');
    }
  }
}

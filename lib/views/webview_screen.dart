import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/about_user.dart';
import 'package:heart365_for_fitbit/services/data_process_service.dart';
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
              //로그인도 했고 데이터도 담김
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
      //유저 기본 정보
      var userData = await service.getUserProfile(tokenDataToStore['userId']!);
      //심전도 데이터, 여기서 ecgReadings와 pagination 데이터가 총 2개 나온다.
      // var ecgData = await service.getEcgLogList(tokenDataToStore['userId']!);
      // print(ecgData);

      //메인 페이지에서 보여 줄 내용들
      //주의: 얘 List임
      // final ecg = ecgData['ecgReadings'] as List<dynamic>;

      //얘는 Map임
      // final pagination = ecgData['pagination'];

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

      // final List<Map<String, dynamic>> ecgDataToStore = ecg.map((reading) {
      //   return {
      //     'startTime': reading['startTime'],
      //     'averageHeartRate': reading['averageHeartRate'],
      //     'resultClassification': reading['resultClassification'],
      //     'waveformSamples': reading['waveformSamples'],
      //     'samplingFrequencyHz': reading['samplingFrequencyHz'],
      //     'scalingFactor': reading['scalingFactor'],
      //     'numberOfWaveformSamples': reading['numberOfWaveformSamples'],
      //     'leadNumber': reading['leadNumber'],
      //     'featureVersion': reading['featureVersion'],
      //     'deviceName': reading['deviceName'],
      //     'firmwareVersion': reading['firmwareVersion'],
      //   };
      // }).toList();

      // final Map<String, dynamic> paginationDataToStore = {
      //   'afterDate': pagination['afterDate'],
      //   'beforeDate': pagination['beforeDate'],
      //   'limit': pagination['limit'],
      //   'next': pagination['next'],
      //   'offset': pagination['offset'],
      //   'previous': pagination['previous'],
      //   'sort': pagination['sort'],
      // };

      //userData 저장
      userDataToStore.forEach((key, value) {
        storage.write(key: key, value: value);
      });

      //ecgData 저장

      //paginationData 저장
      // paginationDataToStore.forEach((key, value) {
      //   storage.write(key: key, value: value);
      // });

      loadData(ref);

      //웹뷰에서 'webpage not available'를 표시하지 않기 위해 리디렉션을 중지
      //하는 코드이나 실제로 적용하면 무한 로딩 발생해서 적용하지 않음
      Navigator.pop(context);
    } catch (e) {
      print('Dio 호출 중 다음과 같은 에러가 발생했습니다. $e');
    }
  }
}

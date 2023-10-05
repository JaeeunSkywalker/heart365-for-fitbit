import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/plain_consts.dart';
import 'package:rxdart/rxdart.dart';

import 'provider/data_provider.dart';
import 'services/storage_service.dart';
import 'views/my_personal_data_widget.dart';
import 'utils/encryption_utils.dart';
import 'views/webview_screen.dart';
import 'consts/about_user.dart';

void main() => runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appname,
      theme: appTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  String codeVerifier = '';
  String state = '';

  //싱글톤 객체 만들어 놓음
  var storage = StorageService.storage;

  //rxdart stream을 시작하자!
  final allOfUserDataController = BehaviorSubject<Map<String, dynamic>>();

  Future<void> _loadDate() async {
    final data = await storage.readAll();
    allOfUserDataController.add(data); // 데이터를 스트림에 추가합니다.

    if (data.isNotEmpty) {
      //기본값은 false이나 flutter_secure_storage에 잔여 데이터가 있으면 true가 된다.
      ref.read(hasDataStateProvider.notifier).state = true;
    }
  }

  @override
  void initState() {
    super.initState();
    codeVerifier = generateCodeVerifier();
    state = generateState();
    _loadDate();
  }

  @override
  void dispose() {
    super.dispose();
    allOfUserDataController.close(); // 리소스를 해제합니다.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: allOfUserDataController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(); // 로딩 인디케이터
        }
        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('메인 페이지'),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (ref.watch(loginStatusProvider)) ...[
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        //TODO:이미지를 캐싱할 수 있지 않을까?
                        image: NetworkImage(data['avatar']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '안녕하세요 ${data['displayName']}님!',
                    ),
                  ),
                  const MyPersonalDataWidget(), //내 개인 데이터 대시보드
                ] else ...[
                  const Center(
                    child: Text('핏빗 로그인을 먼저 해 주세요!'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final Uri authUrl = Uri.https(
                        'www.fitbit.com',
                        '/oauth2/authorize',
                        {
                          'response_type': 'code',
                          'client_id': clientId,
                          'scope': scope,
                          'code_challenge': createCodeChallenge(codeVerifier),
                          'code_challenge_method': 'S256',
                          'state': state,
                          'prompt': 'login',
                          'redirect_uri': redirectUrl,
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            uri: authUrl,
                            codeVerifier: codeVerifier,
                            originalState: state,
                          ),
                        ),
                      );
                    },
                    child: const Text('구글로 핏빗 로그인'),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

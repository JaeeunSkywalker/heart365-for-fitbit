import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/about_user.dart';
import 'package:heart365_for_fitbit/consts/plain_consts.dart';

import 'provider/data_provider.dart';
import 'services/storage_service.dart';
import 'views/my_personal_data_widget.dart';
import 'views/webview_screen.dart';
import 'utils/encryption_utils.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  Map<String, String> allValues = {};

  StreamSubscription? _sub;

  Future<void> _loadInitialDate() async {
    //싱글톤 객체 만들어 놓음
    const storage = StorageService.storage;

    allValues = await storage.readAll();

    if (allValues.isNotEmpty) {
      ref.read(hasDataStateProvider.notifier).state = true;
    }
  }

  @override
  void initState() {
    super.initState();
    codeVerifier = generateCodeVerifier();
    state = generateState();
    _loadInitialDate();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ref.read(hasDataStateProvider)
                ? const Text('안녕하세요!')
                : const Text('핏빗 로그인을 먼저 해 주세요!'),
            ref.watch(hasDataStateProvider)
                ? const MyPersonalDataWidget() //내 개인 데이터 대시보드
                : ElevatedButton(
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
                    child: const Text('Login to Fitbit using Google'),
                  ),
          ],
        ),
      ),
    );
  }
}

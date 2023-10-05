import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/about_user.dart';
import 'package:heart365_for_fitbit/consts/plain_consts.dart';

import 'provider/data_provider.dart';
import 'services/storage_service.dart';
import 'views/my_personal_data_widget.dart';
import 'views/webview_screen.dart';

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

    if (allValues.isNotEmpty) {}
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

  String filterAndReplace(String value) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      var char = value[i];
      if ('a'.codeUnitAt(0) <= char.codeUnitAt(0) &&
          char.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
        buffer.write(char);
      } else if ('0'.codeUnitAt(0) <= char.codeUnitAt(0) &&
          char.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String generateRandomString(int targetLength, int byteLength) {
    final random = Random();
    String result;
    do {
      final values = List<int>.generate(byteLength, (i) => random.nextInt(256));
      result = filterAndReplace(base64UrlEncode(values));
    } while (result.length < targetLength);
    return result.substring(0, targetLength);
  }

//128자 여야 함
  String generateCodeVerifier() {
    return generateRandomString(
        128, 180); // 180은 예상 최대 바이트 길이입니다. 조정이 필요할 수 있습니다.
  }

//43자 여야 함
  String createCodeChallenge(String codeVerifier) {
    List<int> codeVerifierBytes = utf8.encode(codeVerifier);
    List<int> sha256Bytes = sha256.convert(codeVerifierBytes).bytes;
    return base64UrlEncode(sha256Bytes).replaceAll('=', '');
  }

//32자 여야 함
  String generateState() {
    return generateRandomString(32, 45); // 45는 예상 최대 바이트 길이입니다. 조정이 필요할 수 있습니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 페이지'),
      ),
      body: Center(
        child: ref.watch(hasDataStateProvider)
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
      ),
    );
  }
}

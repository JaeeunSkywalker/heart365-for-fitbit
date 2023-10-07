import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/consts/plain_consts.dart';
import 'package:heart365_for_fitbit/services/data_process_service.dart';
import 'package:rxdart/rxdart.dart';

import 'models/user_profile.dart';
import 'provider/data_provider.dart';
import 'services/storage_service.dart';
import 'views/my_personal_data_widget.dart';
import 'utils/encryption_utils.dart';
import 'views/webview_screen.dart';
import 'consts/about_user.dart';

double? screenWidth;
double? screenHeight;

void main() {
  //appDataDir 얻기 위해 한 번 씀.
  // var appDataDir = Directory('/data/data/com.jaeeun.shin.heart365_for_fitbit/');
  // print(appDataDir.path);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  //싱글톤 객체 만들어 놓음.
  var storage = StorageService.storage;

  //rxdart stream을 시작하자!
  final allOfUserDataController =
      BehaviorSubject<UserProfile>.seeded(UserProfile(
    age: '0',
    avatar: '',
    dateOfBirth: '',
    displayName: '',
    encodedId: '',
    fullName: '',
    gender: '',
    memberSince: '',
  )); // 초기 빈 맵으로 시작.

  @override
  void initState() {
    super.initState();
    codeVerifier = generateCodeVerifier();
    state = generateState();
    loadData(ref).then((data) {
      final userProfile = UserProfile(
        age: data['age'] ?? '0',
        avatar: data['avatar'] ?? '',
        dateOfBirth: data['dateOfBirth'] ?? '',
        displayName: data['displayName'] ?? '',
        encodedId: data['encodedId'] ?? '',
        fullName: data['fullName'] ?? '',
        gender: data['gender'] ?? '',
        memberSince: data['memberSince'] ?? '',
      );
      allOfUserDataController.add(userProfile);
    });
  }

  @override
  void dispose() {
    super.dispose();
    allOfUserDataController.close(); // 리소스를 해제합니다.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile>(
      stream: allOfUserDataController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const CircularProgressIndicator();
        }
        final data = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: data.displayName != null
                ? Text('${data.displayName}님 차트')
                : const Text('메인 페이지'),
          ),
          body: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Column(
              children: [
                if (ref.watch(hasDataStateProvider)) ...[
                  Expanded(
                    child: MyPersonalDataWidget(
                      userData: data,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('핏빗 로그인을 먼저 해 주세요!'),
                        ElevatedButton(
                          onPressed: () {
                            final Uri authUrl = Uri.https(
                              'www.fitbit.com',
                              '/oauth2/authorize',
                              {
                                'response_type': 'code',
                                'client_id': clientId,
                                'scope': scope,
                                'code_challenge':
                                    createCodeChallenge(codeVerifier),
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
                      ],
                    ),
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

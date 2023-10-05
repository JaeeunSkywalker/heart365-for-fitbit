import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/provider/data_provider.dart';

import '../services/storage_service.dart';

class MyPersonalDataWidget extends ConsumerStatefulWidget {
  const MyPersonalDataWidget({super.key});

  @override
  MyPersonalDataWidgetState createState() => MyPersonalDataWidgetState();
}

class MyPersonalDataWidgetState extends ConsumerState<MyPersonalDataWidget> {
  static const storage = StorageService.storage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // userName != null
        //     ? Text('$userName님, 안녕하세요!')
        //     : const Text('핏빗 로그인을 먼저 해 주세요!'),
        const Text('안녕하세요!'),
        TextButton(
          onPressed: () async {
            String? userId = await storage.read(key: "userId");
            String? accessToken = await storage.read(key: "accessToken");

            print('데이터 새로 불러 올 때 $userId');
            print('데이터 새로 불러 올 때 $accessToken');

            final userProfileResponse = await Dio().get(
              'https://api.fitbit.com/1/user/$userId/profile.json',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $accessToken',
                },
              ),
            );
          },
          child: const Text('개인 데이터 새로 불러 오기'),
        ),
        TextButton(
          onPressed: () async {
            storage.deleteAll();
            ref.read(hasDataStateProvider.notifier).state = false;
          },
          child: const Text('앱 내 모든 개인 데이터 삭제하고 재로그인하기'),
        ),
      ],
    );
  }
}

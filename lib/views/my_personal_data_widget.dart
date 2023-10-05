import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/provider/data_provider.dart';

import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';

class MyPersonalDataWidget extends ConsumerStatefulWidget {
  const MyPersonalDataWidget({super.key});

  @override
  MyPersonalDataWidgetState createState() => MyPersonalDataWidgetState();
}

class MyPersonalDataWidgetState extends ConsumerState<MyPersonalDataWidget> {
  static const storage = StorageService.storage;
  var service = FitbitApiService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            String? userId = await storage.read(key: "userId");
            String? accessToken = await storage.read(key: "accessToken");

            print('데이터 새로 불러 올 때 $userId');
            print('데이터 새로 불러 올 때 $accessToken');

            //개인 데이터 불러 오는 기능
            var profile = await service.getUserProfile(userId!);
            print(profile);
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

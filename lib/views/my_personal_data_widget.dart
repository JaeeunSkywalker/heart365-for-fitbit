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
          onPressed: () {
            storage.deleteAll();
            ref.read(hasDataStateProvider.notifier).state = false;
          },
          child: const Text('현재 데이터 삭제하기'),
        ),
      ],
    );
  }
}

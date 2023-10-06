import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/data_provider.dart';
import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';
import '../utils/read_and_write_to_file_utils.dart';

class MyDataWidget extends ConsumerStatefulWidget {
  const MyDataWidget({super.key});

  @override
  MyDataWidgetState createState() => MyDataWidgetState();
}

class MyDataWidgetState extends ConsumerState<MyDataWidget> {
  String? ecgDataFromFile;
  static const storage = StorageService.storage;
  var service = FitbitApiService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (ecgDataFromFile != null) Text(ecgDataFromFile!),
        TextButton(
          onPressed: _loadData,
          child: const Text('최신 데이터 불러 오기'),
        ),
        TextButton(
          onPressed: () async {
            storage.deleteAll();
            //로그아웃하고 모든 데이터 삭제
            ref.read(loginStatusProvider.notifier).state = false;
            ref.read(hasDataStateProvider.notifier).state = false;
          },
          child: const Text('로그아웃'),
        ),
      ],
    );
  }

  Future<void> _loadData() async {
    String? userId = await storage.read(key: "userId");

    var profile = await service.getUserProfile(userId!);
    var ecg = await service.getEcgLogList(userId);

    String jsonString = jsonEncode(ecg.toJson());
    await writeToFile(jsonString, 'ecgData');

    var newEcgDataFromFile = await readFromFile('ecgData');

    setState(() {
      ecgDataFromFile = newEcgDataFromFile;
    });

    print(profile.toString());
  }
}

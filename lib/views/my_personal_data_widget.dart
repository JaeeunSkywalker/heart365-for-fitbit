import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/provider/data_provider.dart';

import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';

class MyPersonalDataWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;

  const MyPersonalDataWidget({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  MyPersonalDataWidgetState createState() => MyPersonalDataWidgetState();
}

class MyPersonalDataWidgetState extends ConsumerState<MyPersonalDataWidget> {
  static const storage = StorageService.storage;
  var service = FitbitApiService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  //TODO:이미지를 캐싱할 수 있지 않을까?
                  image: NetworkImage(widget.userData['avatar'] ??
                      'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=792&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성명: ${widget.userData['fullName']}',
                ),
                Text(
                  '나이: ${widget.userData['age']}',
                ),
                Text(
                  '생년월일: ${widget.userData['dateOfBirth']}',
                ),
                Text(
                  '성별: ${widget.userData['gender']}',
                ),
                Text(
                  '기기명: ${widget.userData['encodedId']}',
                ),
                Text(
                  '${widget.userData['memberSince']}부터 핏빗을 이용 중입니다.',
                ),
              ],
            ),
          ],
        ),
        TextButton(
          onPressed: () async {
            String? userId = await storage.read(key: "userId");
            // String? accessToken = await storage.read(key: "accessToken");

            //개인 데이터 불러 오는 기능
            var profile = await service.getUserProfile(userId!);
            // var ecg = await service.getEcgLogList(userId!);

            // safePrint(ecg);
            // print(ecg);
            print(profile.toString());
          },
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
}

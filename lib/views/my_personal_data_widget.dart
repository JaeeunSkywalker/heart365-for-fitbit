import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/models/user_profile.dart';
import 'package:heart365_for_fitbit/views/my_data_widget.dart';

import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';

class MyPersonalDataWidget extends ConsumerStatefulWidget {
  final UserProfile userData;

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
    final Map<String, String> displayData = {
      '성명': widget.userData.fullName as String,
      '나이': widget.userData.age as String,
      '생년월일': widget.userData.dateOfBirth as String,
      '성별': widget.userData.gender as String,
      '기기명': widget.userData.encodedId as String,
      '핏빗 이용 시작일': widget.userData.memberSince as String,
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    //TODO:이미지를 캐싱할 수 있지 않을까?
                    image: NetworkImage(widget.userData.avatar ??
                        'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=792&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: displayData.entries.map(
                  (entry) {
                    return Text('${entry.key}: ${entry.value}');
                  },
                ).toList(),
              ),
            ],
          ),
        ),
        const Expanded(
          flex: 8,
          child: MyDataWidget(),
        ),
      ],
    );
  }
}

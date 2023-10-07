import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/main.dart';
import 'package:heart365_for_fitbit/models/ecg_reading.dart';
import 'package:heart365_for_fitbit/utils/formatted_date.dart';
import 'package:rxdart/rxdart.dart';

import '../provider/data_provider.dart';
import '../services/ecg_painter.dart';
import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';
import '../utils/get_korean_classification.dart';
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

  //페이지네이션을 위한 현재 페이지 인덱스
  int pageIndex = 0;

  @override
  void dispose() {
    super.dispose();
    ecgDataController.close();
  }

  //StreamController for ECG 초기화.
  final ecgDataController = BehaviorSubject<EcgReading>.seeded(EcgReading(
    waveformSamples: [],
    startTime: '',
    averageHeartRate: 0,
    resultClassification: '',
  ));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        if (ecgDataFromFile != null)
          // Text(ecgDataFromFile!),
          //ECG 데이터 페이지네이션
          StreamBuilder<EcgReading>(
            stream: ecgDataController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text('데이터 기록 시간: ${formattedDate(snapshot.data!.startTime)}'),
                    Text('ECG 측정 시 평균 심박수: ${snapshot.data!.averageHeartRate}'),
                    Text('ECG 결과: ${getKoreanClassification(snapshot.data!.resultClassification)}'),
                    const SizedBox(height: 40.0),
                    CustomPaint(
                      painter: EcgPainter(data: snapshot.data!.waveformSamples),
                      size: Size(screenWidth!, screenHeight! / 5), //차트 크기 설정
                    ),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        (ecgDataFromFile != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: pageIndex > 0
                        ? _decrementPageIndex
                        : null, // 첫 페이지면 비활성화
                  ),
                  Text("${pageIndex + 1}"), // 사용자에게는 1부터 시작하는 번호로 보여줍니다.
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: pageIndex < 2
                        ? _incrementPageIndex
                        : null, // 마지막 페이지면 비활성화
                  ),
                ],
              )
            : Container(),
        TextButton(
          //index는 0부터 시작한다.
          //나는 핏빗에 ECG 데이터를 3개만 저장했다.
          //그래서 index는 0~2만 가능하다.
          //offset은 0, limit은 3이다.
          onPressed: () {
            _loadData(0);
          },
          child: const Text('최신 심전도 데이터 불러 오기'),
        ),
        TextButton(
          onPressed: () async {
            storage.deleteAll();
            //로그아웃하고 모든 데이터 삭제.
            ref.read(loginStatusProvider.notifier).state = false;
            ref.read(hasDataStateProvider.notifier).state = false;
          },
          child: const Text('로그아웃'),
        ),
      ],
    );
  }

  void _incrementPageIndex() {
    setState(() {
      pageIndex++;
      _loadData(pageIndex);
    });
  }

  void _decrementPageIndex() {
    setState(() {
      pageIndex--;
      _loadData(pageIndex);
    });
  }

  Future<void> _loadData(int pageIndex) async {
    String? userId = await storage.read(key: "userId");

    // var profile = await service.getUserProfile(userId!);
    var ecg = await service.getEcgLogList(userId!);

    String jsonString = jsonEncode(ecg.toJson());
    await writeToFile(jsonString, 'ecgData');

    //파일에서 데이터를 받아 옴.
    var newEcgDataFromFile = await readFromFile('ecgData');
    // String 타입의 JSON을 Dart 객체로 변환함.
    var ecgDataDecodedFromJson = jsonDecode(newEcgDataFromFile);

    //여기부터 RxDart+ECG 처리.
    //버튼을 클릭하면 최신 ECG 데이터가 스트림에 전달되어 차트가 업데이트 된다.
    //pageIndex를 기반으로 데이터 가져 오기.
    final waveformSamples = List<int>.from(
        ecgDataDecodedFromJson['readings'][pageIndex]['waveformSamples']);
    final startTime =
        ecgDataDecodedFromJson['readings'][pageIndex]['startTime'];
    final averageHeartRate =
        ecgDataDecodedFromJson['readings'][pageIndex]['averageHeartRate'];
    final resultClassification =
        ecgDataDecodedFromJson['readings'][pageIndex]['resultClassification'];

    final ecgReading = EcgReading(
      waveformSamples: waveformSamples,
      startTime: startTime,
      averageHeartRate: averageHeartRate,
      resultClassification: resultClassification,
    );

    setState(
      () {
        ecgDataFromFile = newEcgDataFromFile;
        // ecgDataController.add(waveformSamples);
        // ecgDataController.add(startTime);
        // ecgDataController.add(averageHeartRate);
        // ecgDataController.add(resultClassification);
        ecgDataController.add(ecgReading);
      },
    );

    // safePrint(profile.toString());
  }
}

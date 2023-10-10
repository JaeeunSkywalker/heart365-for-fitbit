import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart365_for_fitbit/main.dart';
import 'package:heart365_for_fitbit/models/ecg_reading.dart';
import 'package:heart365_for_fitbit/utils/format_date_util.dart';
import 'package:heart365_for_fitbit/services/grid_painter_service.dart';
import 'package:heart365_for_fitbit/viewmodels/ecg_data_controller.dart';
import 'package:heart365_for_fitbit/viewmodels/page_data_controller.dart';
import 'package:heart365_for_fitbit/viewmodels/user_data_controller.dart';
import 'package:dio/dio.dart';

import '../provider/data_provider.dart';
import '../services/ecg_painter_service.dart';
import '../services/fitbit_api_service.dart';
import '../services/storage_service.dart';
import '../utils/get_korean_classification_util.dart';
import '../utils/read_and_write_to_file_util.dart';

class MyDataWidget extends ConsumerStatefulWidget {
  const MyDataWidget({super.key});

  @override
  MyDataWidgetState createState() => MyDataWidgetState();
}

class MyDataWidgetState extends ConsumerState<MyDataWidget>
    with TickerProviderStateMixin {
  String? ecgDataFromFile;
  static const storage = StorageService.storage;
  var service = FitbitApiService();
  int numberOfEcgReadings = 0;

  // 페이지 컨트롤러 및 초기 스크롤 위치
  final PageController _pageController = PageController(initialPage: 0);

  // 기존 데이터 및 페이지 인덱스 설정
  int pageIndex = 0;

  //커스터마이징 하면 되는 변수들
  //1초의 ECG 데이터를 화면에 표시하려면 250개의 데이터 포인트가 필요하다.
  //5초나 10초의 데이터를 한 화면에 표시하는 것이 일반적이다.
  //여기서는 5초로 픽스함.
  static const int dataPointsPerPage = 1250;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      if (_pageController.hasClients &&
          _pageController.page!.toInt() != pageIndex) {
        setState(() {
          pageIndex = _pageController.page!.toInt();
        });
      }
    });
  }

  // 타이머를 클래스 레벨 변수로 이동
  Timer? chartUpdateTimer;

  @override
  void dispose() {
    _pageController.dispose();
    chartUpdateTimer?.cancel();
    ecgDataController.ecgReadingDataController.close();
    pageDataController.ecgPageDataController.close();
    super.dispose();
  }

  void _incrementPageIndex() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void _decrementPageIndex() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          StreamBuilder<List<EcgReading>>(
            stream: ecgDataController.ecgReadingDataController.stream,
            builder: (context, ecgDataSnapshot) {
              if (!ecgDataSnapshot.hasData || ecgDataSnapshot.data!.isEmpty) {
                //리소스 문제로 끔
                // return const Center(child: CircularProgressIndicator());
                return Container();
              }

              // pageIndex의 유효성 검사 추가.
              if (pageIndex >= ecgDataSnapshot.data!.length || pageIndex < 0) {
                return const Text("pageIndex가 유효하지 않습니다.");
              }

              return StreamBuilder<List<int>>(
                stream: pageDataController.ecgPageDataController.stream,
                builder: (context, ecgPageDataSnapshot) {
                  if (!ecgPageDataSnapshot.hasData ||
                      ecgPageDataSnapshot.data!.isEmpty) {
                    return Container();
                  }

                  return Column(
                    children: [
                      Text(
                          '데이터 기록 시간: ${formatDate(ecgDataSnapshot.data![pageIndex].startTime)}'),
                      Text(
                          'ECG 측정 시 평균 심박수: ${ecgDataSnapshot.data![pageIndex].averageHeartRate}'),
                      Text(
                          'ECG 결과: ${getKoreanClassification(ecgDataSnapshot.data![pageIndex].resultClassification)}'),
                      const SizedBox(height: 40.0),
                      SizedBox(
                        height: screenHeight! / 4,
                        width: screenWidth!,
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          itemCount: numberOfEcgReadings,
                          itemBuilder: (context, index) {
                            // 현재 페이지의 waveform 데이터를 가져옵니다.
                            List<int> currentPageWaveformData = ecgDataSnapshot
                                .data![pageIndex].waveformSamples;

                            return Material(
                              color: Colors.white,
                              child: CustomPaint(
                                size: Size(screenWidth!, screenHeight! / 4),
                                painter: GridPainter(),
                                foregroundPainter:
                                    EcgPainter(data: currentPageWaveformData),
                                child: Container(),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left),
                            onPressed:
                                pageIndex > 0 ? _decrementPageIndex : null,
                          ),
                          Text("${pageIndex + 1}"),
                          IconButton(
                            icon: const Icon(Icons.arrow_right),
                            onPressed: pageIndex < numberOfEcgReadings - 1
                                ? _incrementPageIndex
                                : null,
                          ),
                        ],
                      ),
                      Text('ECG 검사 횟수: $numberOfEcgReadings'),
                    ],
                  );
                },
              );
            },
          ),
          TextButton(
            onPressed: () => _loadData(0),
            child: const Text('최신 심전도 데이터 불러 오기'),
          ),
          TextButton(
            onPressed: () async {
              await storage.deleteAll();
              ref.read(loginStatusProvider.notifier).state = false;
              ref.read(hasDataStateProvider.notifier).state = false;

              final currentData = userDataController
                  .allOfUserDataController.value; //현재 데이터 가져오기.
              final updatedData = currentData.copyWith(displayName: '');

              userDataController.allOfUserDataController
                  .add(updatedData); //변경된 데이터 스트림에 추가.
            },
            child: const Text('로그아웃'),
          )
        ],
      ),
    );
  }

  //문제 없음!
  Future<void> _loadData(int pageIndex) async {
    Future<void> updateData(String newEcgDataFromFile) async {
      var ecgDataDecodedFromJson = jsonDecode(newEcgDataFromFile);

      if (ecgDataDecodedFromJson['readings'] != null) {
        numberOfEcgReadings = ecgDataDecodedFromJson['readings'].length;
        List<EcgReading> allReadings =
            ecgDataDecodedFromJson['readings'].map<EcgReading>((data) {
          return EcgReading(
            waveformSamples: List<int>.from(data['waveformSamples']),
            startTime: data['startTime'],
            averageHeartRate: data['averageHeartRate'],
            resultClassification: data['resultClassification'],
          );
        }).toList();

        setState(() {
          ecgDataFromFile = newEcgDataFromFile;
        });

        ecgDataController.ecgReadingDataController.add(allReadings);

        // allReadings에서 모든 waveformSamples을 추출하여 ecgPageDataController에 추가
        List<List<int>> allWaveformSamples =
            allReadings.map((reading) => reading.waveformSamples).toList();
        pageDataController.ecgPageDataController
            .add(allWaveformSamples[pageIndex]);

        //메모리 누수 같은 문제를 없애기 위해 값 확인만 하고 꺼야 됨.
        // ecgDataController.ecgReadingDataController.stream.listen((data) {
        //   print("새로운 데이터가 추가되었습니다: $data");
        // });

        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      } else {
        print("Error: 'readings' 키가 없거나 JSON 데이터에 null이 있습니다.");
      }
    }

    try {
      String? userId = await storage.read(key: "userId");
      var ecg = await service.getEcgLogList(userId!);
      String jsonString = jsonEncode(ecg.toJson());
      await writeToFile(jsonString, 'ecgData');

      //파일 이름이 'ecgData'임.
      var newEcgDataFromFile = await readFromFile('ecgData');
      await updateData(newEcgDataFromFile);
    } catch (error) {
      if (error is DioException) {
        //429에러 뜨면(API 호출 리밋 넘은 거) storage에서 데이터 끌어다 씀.
        if (error.response?.statusCode == 429) {
          var newEcgDataFromFile = await readFromFile('ecgData');
          await updateData(newEcgDataFromFile);
        } else {
          // 429 상태 코드가 아닌 다른 에러 처리
          print("Error fetching data: $error");
        }
      } else {
        print("Unexpected error: $error");
      }
    }
  }
}

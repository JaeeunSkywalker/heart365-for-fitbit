//수정할 거 없음. 검토 완료.

//핏빗 API에서 ECG Data request 했을 때 받는 정보 모델

class EcgReading {
  //ECG, EKG 모두 심전도입니다.
  //핏빗에서 데이터가 기록되기 시작한 시간.
  final String startTime;

  //ECG 레코딩 시 평균 심박수.
  final int averageHeartRate;

  //ECG 결과 분류.
  //Atrial Fibrillation(심방세동).
  //Normal Sinus Rhythm(정상 부비동).
  //Inconclusive(결론이 나지 않음, 불확정).
  //Inconclusive: High heart rate(불확정: 심박수 증가).
  //Inconclusive: Low heart rate(불확정: 심박수 감소).
  final String resultClassification;

  //ECG 파형.
  final List<int> waveformSamples;

  //250 고정, 핏빗은 250헤르츠의 주파수로 전압을 샘플링한다(ECG를 측정한다).
  final int samplingFrequencyHz;

  //10922 고정, mV = waveformSamples / scalingFactor.
  //라는 수식을 통해, 주어진 웨이브폼 샘플 값을.
  //ECG 전압(밀리볼트 단위)으로 변환할 때 사용하는 스케일링 요소.
  //차트는 waveformSamples로 그리면 된다.
  //scalingFactor는 waveformSamples를 나눈 값으로 차트 y축에 실제 전압 값을 표시하려고 할 때.
  //필요한 값이다.
  //요약.
  //ECG 웨이브폼의 형태만 그릴 경우: waveformSamples를 직접 사용.
  // 실제 전압 값을 y축에 표시하려는 경우: waveformSamples를 scalingFactor로 나눈 값을 사용.
  final int scalingFactor;

  //핏빗 서버에 기록된 ECG 데이터 수.
  final int numberOfWaveformSamples;

  //1 고정(단일 전극), 심전도 측정을 위해 사용된 리드 수.
  final int leadNumber;

  //ECG 측정에 사용된 핏빗 워치 상의 ECG 앱 버전, x.xx-x.xx-x.xx(x.xx는 앱, 서비스, 웹 버전을 각각 나타냄).
  //1. 실제 기기에서 실행되는 ECG 앱의 버전 정보.
  //2. 핏빗의 백엔드 서비스나 연관된 서비스의 버전 정보.
  //3. 해당 기능과 관련된 웹 인터페이스나 웹 관련 컴포넌트의 버전 정보.
  final String featureVersion;

  //ECG 측정에 사용된 핏빗 워치 네임.
  final String deviceName;

  //ECG 측정에 사용된 펌웨어 버전.
  final String firmwareVersion;

  EcgReading({
    required this.startTime,
    required this.averageHeartRate,
    required this.resultClassification,
    required this.waveformSamples,
    this.samplingFrequencyHz = 250,
    this.scalingFactor = 10922,
    this.numberOfWaveformSamples = 0,
    this.leadNumber = 1,
    this.featureVersion = '',
    this.deviceName = '',
    this.firmwareVersion = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'averageHeartRate': averageHeartRate,
      'resultClassification': resultClassification,
      'waveformSamples': waveformSamples,
      'samplingFrequencyHz': samplingFrequencyHz,
      'scalingFactor': scalingFactor,
      'numberOfWaveformSamples': numberOfWaveformSamples,
      'leadNumber': leadNumber,
      'featureVersion': featureVersion,
      'deviceName': deviceName,
      'firmwareVersion': firmwareVersion,
    };
  }

  factory EcgReading.fromJson(Map<String, dynamic> json) {
    return EcgReading(
      startTime: json['startTime'],
      averageHeartRate: json['averageHeartRate'],
      resultClassification: json['resultClassification'],
      waveformSamples: List<int>.from(json['waveformSamples']),
      samplingFrequencyHz: json['samplingFrequencyHz'],
      scalingFactor: json['scalingFactor'],
      numberOfWaveformSamples: json['numberOfWaveformSamples'],
      leadNumber: json['leadNumber'],
      featureVersion: json['featureVersion'],
      deviceName: json['deviceName'],
      firmwareVersion: json['firmwareVersion'],
    );
  }

  @override
  String toString() {
    return 'EcgReading(startTime: $startTime, averageHeartRate: $averageHeartRate, resultClassification: $resultClassification, waveformSamples: ${waveformSamples.toString()}, samplingFrequencyHz: $samplingFrequencyHz, scalingFactor: $scalingFactor, numberOfWaveformSamples: $numberOfWaveformSamples, leadNumber: $leadNumber, featureVersion: $featureVersion, deviceName: $deviceName, firmwareVersion: $firmwareVersion,)';
  }
}

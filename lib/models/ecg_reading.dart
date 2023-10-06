class EcgReading {
  final String startTime;
  final int averageHeartRate;
  final String resultClassification;
  final List<int> waveformSamples;
  final int samplingFrequencyHz;
  final int scalingFactor;
  final int numberOfWaveformSamples;
  final int leadNumber;
  final String featureVersion;
  final String deviceName;
  final String firmwareVersion;

  EcgReading({
    required this.startTime,
    required this.averageHeartRate,
    required this.resultClassification,
    required this.waveformSamples,
    required this.samplingFrequencyHz,
    required this.scalingFactor,
    required this.numberOfWaveformSamples,
    required this.leadNumber,
    required this.featureVersion,
    required this.deviceName,
    required this.firmwareVersion,
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
    return 'EcgReading(startTime: $startTime, averageHeartRate: $averageHeartRate, resultClassification: $resultClassification, waveformSamples: ${waveformSamples.toString()}, samplingFrequencyHz: $samplingFrequencyHz, scalingFactor: $scalingFactor, numberOfWaveformSamples: $numberOfWaveformSamples, leadNumber: $leadNumber, featureVersion: $featureVersion, deviceName: $deviceName, firmwareVersion: $firmwareVersion)';
  }
}

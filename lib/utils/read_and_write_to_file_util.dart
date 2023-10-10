import 'dart:io';

//수정할 거 없음. 검토 완료.

//로그가 너무 길어 짤릴 때 파일에 저장해서 별도로 확인한다.
//appDataDirectory 경로 별도로 찾아야 한다.
//path_provider 같은 패키지를 쓰지 않기 위해 가장 raw한 방법으로 시행하는 중.

String appDataDirectory = '/data/data/com.jaeeun.shin.heart365_for_fitbit/';

Future<File> writeToFile(String data, String fileName) async {
  final directory = Directory(
      appDataDirectory); // 여기서 'appDataDirectory'는 실제 앱 데이터 디렉토리 경로로 변경해야 합니다.
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  final file = File('${directory.path}/$fileName');
  return file.writeAsString(data);
}

Future<String> readFromFile(String fileName) async {
  final directory = Directory(
      appDataDirectory); // 여기서 'appDataDirectory'는 실제 앱 데이터 디렉토리 경로로 변경해야 합니다.
  final file = File('${directory.path}/$fileName');
  if (await file.exists()) {
    return file.readAsString();
  }
  return '';
}

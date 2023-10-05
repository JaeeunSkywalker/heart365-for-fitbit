//핏빗 로그인 시 필요한 암호화 코드들입니다.
//핏빗에서 제공하는 것이 아니고 제가(?) 만든 것이니
//100% 신뢰하진 마시고(?) 필요 시 커스터마이징 해서 사용해 보십시오.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String filterAndReplace(String value) {
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < value.length; i++) {
    var char = value[i];
    if ('a'.codeUnitAt(0) <= char.codeUnitAt(0) &&
        char.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
      buffer.write(char);
    } else if ('0'.codeUnitAt(0) <= char.codeUnitAt(0) &&
        char.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

String generateRandomString(int targetLength, int byteLength) {
  final random = Random();
  String result;
  do {
    final values = List<int>.generate(byteLength, (i) => random.nextInt(256));
    result = filterAndReplace(base64UrlEncode(values));
  } while (result.length < targetLength);
  return result.substring(0, targetLength);
}

//128자 여야 함
String generateCodeVerifier() {
  return generateRandomString(
      128, 180); // 180은 예상 최대 바이트 길이입니다. 조정이 필요할 수 있습니다.
}

//43자 여야 함
String createCodeChallenge(String codeVerifier) {
  List<int> codeVerifierBytes = utf8.encode(codeVerifier);
  List<int> sha256Bytes = sha256.convert(codeVerifierBytes).bytes;
  return base64UrlEncode(sha256Bytes).replaceAll('=', '');
}

//32자 여야 함
String generateState() {
  return generateRandomString(32, 45); // 45는 예상 최대 바이트 길이입니다. 조정이 필요할 수 있습니다.
}

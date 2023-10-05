import 'package:riverpod/riverpod.dart';

//flutter_secure_storage에 데이터가 있는지 확인하는 flag
final hasDataStateProvider = StateProvider<bool>((ref) => false);
//앱 전역에서 사용되는 user 이름
final userNameProvider = StateProvider<String>((ref) => '');


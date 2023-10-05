import 'package:riverpod/riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../services/storage_service.dart';

//flutter_secure_storage에 데이터가 있는지 확인하는 flag
final hasDataStateProvider = StateProvider<bool>((ref) => false);
//로그인 상태 관리는 flutter_secure_storage와 riverpod을 동시 활용
final loginStatusProvider = StateProvider<bool>((ref) => false);

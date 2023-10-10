import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/data_provider.dart';
import 'storage_service.dart';

//수정할 거 없음. 검토 완료.

//flutter_secure_storage에 저장된 데이터 불러 오는 함수.
Future<Map<String, String>> loadExistedData(WidgetRef ref) async {
  var storage = StorageService.storage;
  final data = await storage.readAll();

  if (data.isNotEmpty) {
    //기본값은 false이나 flutter_secure_storage에 잔여 데이터가 있으면 true가 된다.
    ref.read(hasDataStateProvider.notifier).state = true;
  }

  return data;
}

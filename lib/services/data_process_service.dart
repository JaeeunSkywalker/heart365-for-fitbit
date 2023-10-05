import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/data_provider.dart';
import 'storage_service.dart';

//핏빗 API에서 데이터 받아 오는 loadData 함수
Future<Map<String, dynamic>> loadData(WidgetRef ref) async {
  var storage = StorageService.storage;
  final data = await storage.readAll();

  if (data.isNotEmpty) {
    //기본값은 false이나 flutter_secure_storage에 잔여 데이터가 있으면 true가 된다.
    ref.read(hasDataStateProvider.notifier).state = true;
  }

  return data;
}

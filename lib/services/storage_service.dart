import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//싱글톤으로 구현.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();
}

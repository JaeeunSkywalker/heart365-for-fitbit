import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();
}

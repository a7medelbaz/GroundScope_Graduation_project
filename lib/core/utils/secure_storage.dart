import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  void saveString({required String key, required String value}) {
    _storage.write(key: key, value: value);
  }

  Future<String?> getString({required String key}) {
    return _storage.read(key: key);
  }

  Future<void> clear({required String key}) async {
    await _storage.delete(key: key);
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class FlutterSecureStorageWrapper implements SecureStorage {
  final FlutterSecureStorage _impl;

  const FlutterSecureStorageWrapper([this._impl = const FlutterSecureStorage()]);

  @override
  Future<void> write({required String key, required String value}) => _impl.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _impl.read(key: key);

  @override
  Future<void> delete({required String key}) => _impl.delete(key: key);
}

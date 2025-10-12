import 'dart:async';

import 'package:nova_mobile/repositories/auth_repository.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository(this._handler);

  final FutureOr<Map<String, dynamic>> Function(String email, String password) _handler;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = _handler(email, password);
    if (res is Future<Map<String, dynamic>>) return await res;
    return res;
  }
}

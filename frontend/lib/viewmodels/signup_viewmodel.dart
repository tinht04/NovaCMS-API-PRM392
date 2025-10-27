import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  SignupViewModel([AuthRepository? repo]) : _repo = repo ?? AuthRepository();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  /// Register a user. Returns the server response map on success.
  Future<Map<String, dynamic>?> register({required String fullName, required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _repo.register(fullName, email, password);
      return res;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

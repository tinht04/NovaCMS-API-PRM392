import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  bool loading = false;
  String? error;

  LoginViewModel(this._repo);

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _repo.login(email, password);
      loading = false;
      notifyListeners();
      return data.isNotEmpty;
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

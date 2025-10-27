import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';
import '../core/network/exceptions.dart';
import 'package:dio/dio.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  bool loading = false;
  String? error;

  // Allow creating the viewmodel without the screen needing to know about
  // AuthRepository (keeps MVVM separation). A repo can still be injected
  // for tests or higher-level DI.
  LoginViewModel([AuthRepository? repo]) : _repo = repo ?? AuthRepository();

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _repo.login(email, password);
      loading = false;
      notifyListeners();
      return data.isNotEmpty;
    } on ApiException catch (e) {
      loading = false;
      error = e.message;
      notifyListeners();
      return false;
    } on DioException catch (d) {
      // unwrap ApiException carried in DioException.error
      final err = d.error;
      if (err is ApiException) {
        loading = false;
        error = err.message;
        notifyListeners();
        return false;
      }
      loading = false;
      error = d.message ?? d.toString();
      notifyListeners();
      return false;
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

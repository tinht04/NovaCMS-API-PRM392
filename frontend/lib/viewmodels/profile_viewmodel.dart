import 'package:flutter/foundation.dart';
import '../repositories/profile_repository.dart';
import '../repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo;
  final AuthRepository _auth;

  ProfileViewModel([ProfileRepository? repo, AuthRepository? auth])
      : _repo = repo ?? ProfileRepository(),
        _auth = auth ?? AuthRepository();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _profile;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get profile => _profile;

  Future<void> loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repo.getProfile();
      _profile = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Logout - removes saved tokens. VM does not navigate; UI should react.
  Future<void> logout() async {
    await _auth.logout();
  }
}

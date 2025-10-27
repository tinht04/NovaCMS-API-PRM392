import 'package:flutter/foundation.dart';
import '../repositories/category_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final CategoryRepository _repo;

  List<Map<String, dynamic>> categories = [];
  bool loading = false;
  String? error;

  HomeViewModel([CategoryRepository? repo]) : _repo = repo ?? CategoryRepository();

  Future<void> loadCategories() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final c = await _repo.getAll();
      categories = List<Map<String, dynamic>>.from(c);
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}

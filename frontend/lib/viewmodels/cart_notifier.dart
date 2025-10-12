import 'package:flutter/foundation.dart';

class CartNotifier extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void addOne() {
    _count++;
    notifyListeners();
  }

  void removeOne() {
    if (_count > 0) _count--;
    notifyListeners();
  }

  void clear() {
    _count = 0;
    notifyListeners();
  }
}

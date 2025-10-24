
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final List<_AppNotification> _notifications = [];

  List<_AppNotification> get notifications => List.unmodifiable(_notifications);

  void add(String message, {VoidCallback? onTap}) {
    _notifications.insert(0, _AppNotification(message, onTap));
    notifyListeners();
  }
  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}

class _AppNotification {
  final String message;
  final VoidCallback? onTap;
  _AppNotification(this.message, this.onTap);
}

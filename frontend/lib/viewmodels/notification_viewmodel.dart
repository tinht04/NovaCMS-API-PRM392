import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService.instance;

  NotificationViewModel() {
    _service.addListener(_onService);
  }

  void _onService() => notifyListeners();

  List<dynamic> get notifications => _service.notifications;

  void add(String message, {VoidCallback? onTap}) => _service.add(message, onTap: onTap);

  void clear() => _service.clear();

  @override
  void dispose() {
    _service.removeListener(_onService);
    super.dispose();
  }
}

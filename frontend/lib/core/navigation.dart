import 'package:flutter/widgets.dart';

// Global navigator key so non-widget code (like ApiClient) can navigate
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> gotoLogin() async {
  try {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (r) => false);
  } catch (_) {}
}

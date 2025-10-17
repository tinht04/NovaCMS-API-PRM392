// Web implementation: listens to window.onMessage and localStorage changes.
import 'dart:html' as html;
import 'dart:convert';

typedef WebMessageCancel = void Function();

WebMessageCancel addWebMessageListener(void Function(dynamic data) handler) {
  // Listen to both postMessage and localStorage changes
  final messageListener = html.window.onMessage.listen((event) {
    handler(event.data);
  });
  
  final storageListener = html.window.onStorage.listen((event) {
    if (event.key == 'vnp_payment_result' && event.newValue != null) {
      try {
        final data = jsonDecode(event.newValue!);
        handler(data);
        // Clear the result after processing
        html.window.localStorage.remove('vnp_payment_result');
      } catch (e) {
        // Handle error silently
      }
    }
  });
  
  // Also check for existing payment result on startup
  final existingResult = html.window.localStorage['vnp_payment_result'];
  if (existingResult != null) {
    try {
      final data = jsonDecode(existingResult);
      handler(data);
      html.window.localStorage.remove('vnp_payment_result');
    } catch (e) {
      // Handle error silently
    }
  }
  
  return () {
    messageListener.cancel();
    storageListener.cancel();
  };
}

/// Opens a URL in a new browser tab (web only).
void openInNewTab(String url) {
  html.window.open(url, '_blank');
}

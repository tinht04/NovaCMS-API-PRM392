// Web implementation: listens to window.onMessage and forwards events to handler.
import 'dart:html' as html;

typedef WebMessageCancel = void Function();

WebMessageCancel addWebMessageListener(void Function(dynamic data) handler) {
  final sub = html.window.onMessage.listen((event) {
    handler(event.data);
  });
  return () {
    sub.cancel();
  };
}

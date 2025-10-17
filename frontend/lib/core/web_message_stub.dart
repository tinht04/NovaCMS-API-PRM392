// Stub implementation for non-web platforms.
// Provides addWebMessageListener which returns a cancel function.

typedef WebMessageCancel = void Function();

WebMessageCancel addWebMessageListener(void Function(dynamic data) handler) {
  // No-op on non-web platforms.
  return () {};
}

/// No-op for opening a new tab on non-web platforms.
void openInNewTab(String url) {
  // noop
}

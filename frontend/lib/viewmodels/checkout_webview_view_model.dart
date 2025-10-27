import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

// conditional import: web implementation uses dart:html, non-web uses stub
import '../core/web_message_stub.dart'
  if (dart.library.html) '../core/web_message_web.dart';

/// ViewModel for checkout webview screen.
///
/// Responsibilities:
/// - Listen for web postMessage callbacks on web or deep links on mobile
/// - Expose UI state (loading, externalLaunched)
/// - Emit a single result map via [resultStream] when a callback is received
class CheckoutWebViewViewModel extends ChangeNotifier {
  bool _loading = true;
  bool _externalLaunched = false;

  final _resultController = StreamController<Map<String, dynamic>?>.broadcast();
  Stream<Map<String, dynamic>?> get resultStream => _resultController.stream;

  StreamSubscription<Uri>? _linkSubscription;
  final _appLinks = AppLinks();

  WebMessageCancel? _webCancel;

  bool get loading => _loading;
  bool get externalLaunched => _externalLaunched;

  /// Start listening for callbacks. Call from the View's initState.
  void start(String paymentUrl) {
    // Web: use localStorage / postMessage listener
    if (kIsWeb) {
      _webCancel = addWebMessageListener((data) {
        try {
          if (data is Map && data['type'] == 'vnp_callback') {
            final ok = data['ok'] as bool? ?? false;
            final params = Map<String, dynamic>.from(data['params'] ?? {});
            _emitResult({'success': ok, 'params': params});
          }
        } catch (_) {
          // ignore
        }
      });

      // For web we usually open the URL in a new tab from the View.
      _externalLaunched = true;
      _loading = false;
      notifyListeners();
      return;
    }

    // Mobile: listen for deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri.toString());
    }, onError: (_) {});

    // Default: still show loading while webview loads
    _loading = true;
    _externalLaunched = false;
    notifyListeners();
  }

  void _emitResult(Map<String, dynamic> result) {
    if (!_resultController.isClosed) _resultController.add(result);
  }

  void _handleDeepLink(String link) {
    if (link.startsWith('novacms://payment/callback')) {
      try {
        final uri = Uri.parse(link);
        final params = Map<String, dynamic>.from(uri.queryParameters);
        final success = params['vnp_ResponseCode'] == '00';
        _emitResult({'success': success, 'params': params});
      } catch (_) {
        // ignore
      }
    }
  }

  /// Public entrypoint for links detected by the WebView navigation delegate.
  void handleIncomingLink(String link) => _handleDeepLink(link);

  /// Call when webview page started loading.
  void onPageStarted() {
    _loading = true;
    notifyListeners();
  }

  /// Call when webview page finished loading.
  void onPageFinished() {
    _loading = false;
    notifyListeners();
  }

  /// If the app falls back to opening an external browser, call this to update state.
  void markExternalLaunched() {
    _externalLaunched = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _webCancel?.call();
    _linkSubscription?.cancel();
    _resultController.close();
    super.dispose();
  }
}

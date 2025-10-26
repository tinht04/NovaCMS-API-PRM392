import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_links/app_links.dart';
import 'dart:async';

// conditional import: web implementation uses dart:html, non-web uses stub
import '../../core/web_message_stub.dart'
  if (dart.library.html) '../../core/web_message_web.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  const CheckoutWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  WebViewController? _controller;
  bool _loading = true;
  bool _externalLaunched = false;
  StreamSubscription<Uri>? _linkSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    
    if (kIsWeb) {
      // Web: use localStorage message listener
      _webCancel = addWebMessageListener((data) {
        try {
          if (data is Map && data['type'] == 'vnp_callback') {
            final ok = data['ok'] as bool? ?? false;
            final params = Map<String, dynamic>.from(data['params'] ?? {});
            if (mounted) {
              Navigator.of(context).pop({'success': ok, 'params': params});
            }
          }
        } catch (e) {
          // Handle error silently
        }
      });
    } else {
      // Mobile: listen for deep links
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        _handleDeepLink(uri.toString());
      }, onError: (err) {
        // Handle error silently
      });
    }
    // On Android/iOS use an embedded webview; on web/desktop fall back to launching external browser
    try {
      _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller!.setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() => _loading = true);
          if (url.contains('/payment/true') || url.contains('/payment/false')) {
            final success = url.contains('/payment/true');
            Navigator.of(context).pop(success);
          }
        },
        onPageFinished: (url) => setState(() => _loading = false),
        onNavigationRequest: (r) {
          // Chặn các URL có scheme không phải http/https (deep link)
          final uri = Uri.tryParse(r.url);
          if (uri != null && uri.scheme != 'http' && uri.scheme != 'https') {
            // Nếu là deep link callback, pop về app
            _handleDeepLink(r.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));
      _controller!.loadRequest(
        Uri.parse(widget.paymentUrl),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      // If running on web we prefer opening the payment URL in a new tab so the vnp callback can postMessage back
      if (kIsWeb) {
        openInNewTab(widget.paymentUrl);
        if (mounted) setState(() => _externalLaunched = true);
      }
    } catch (_) {
      // fallback: open external browser
      _openExternal();
    }
  }

  WebMessageCancel? _webCancel;

  void _handleDeepLink(String link) {
    // Parse deep link: novacms://payment/callback?vnp_ResponseCode=00&...
    if (link.startsWith('novacms://payment/callback')) {
      try {
        final uri = Uri.parse(link);
        final params = Map<String, dynamic>.from(uri.queryParameters);
        final success = params['vnp_ResponseCode'] == '00';
        
        if (mounted) {
          Navigator.of(context).pop({
            'success': success,
            'params': params,
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  void dispose() {
    _webCancel?.call();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // Cannot detect callback in external browser - keep this screen open and let user confirm
    if (mounted) setState(() => _externalLaunched = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(children: [
        if (!_externalLaunched && _controller != null) WebViewWidget(controller: _controller!),
        if (_externalLaunched)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Payment opened in a new browser tab.'),
                const SizedBox(height: 8),
                const Text('Complete your payment in the browser; the app will detect the result automatically when the payment finishes.'),
                const SizedBox(height: 16),
                if (!kIsWeb)
                  ElevatedButton(
                      onPressed: () {
                        // We can't reliably detect success here; return to caller to verify if needed
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Done'))
              ]),
            ),
          ),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ]),
    );
  }
}

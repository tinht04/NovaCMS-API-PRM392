import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  late final WebViewController _controller;
  bool _loading = true;
  bool _externalLaunched = false;

  @override
  void initState() {
    super.initState();
    // Register web message listener only on web
    if (kIsWeb) {
      _webCancel = addWebMessageListener((data) {
        try {
          if (data is Map && data['type'] == 'vnp_callback') {
            final ok = data['ok'] as bool? ?? false;
            final params = Map<String, dynamic>.from(data['params'] ?? {});
            // Pop back to caller with a map result: { 'success': ok, 'params': params }
            if (mounted) Navigator.of(context).pop({'success': ok, 'params': params});
          }
        } catch (_) {}
      });
    }
    // On Android/iOS use an embedded webview; on web/desktop fall back to launching external browser
    try {
      _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
        setState(() => _loading = true);
        if (url.contains('/payment/true') || url.contains('/payment/false')) {
          final success = url.contains('/payment/true');
          Navigator.of(context).pop(success);
        }
      }, onPageFinished: (url) => setState(() => _loading = false), onNavigationRequest: (r) {
        return NavigationDecision.navigate;
      }));
      _controller.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (_) {
      // fallback: open external browser
      _openExternal();
    }
  }

  WebMessageCancel? _webCancel;

  @override
  void dispose() {
    _webCancel?.call();
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
        if (!_externalLaunched) WebViewWidget(controller: _controller),
        if (_externalLaunched)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Payment opened in a new browser tab.'),
                const SizedBox(height: 8),
                const Text('Complete your payment in the browser, then come back and tap Done.'),
                const SizedBox(height: 16),
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

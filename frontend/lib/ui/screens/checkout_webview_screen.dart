import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:nova_mobile/viewmodels/checkout_webview_viewmodel.dart';
// conditional import for opening a new tab on web platforms
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
  final _vm = CheckoutWebViewViewModel();
  StreamSubscription<Map<String, dynamic>?>? _resultSub;

  @override
  void initState() {
    super.initState();
    // Start ViewModel which listens for callbacks (web postMessage or deep links)
    _vm.start(widget.paymentUrl);
    _resultSub = _vm.resultStream.listen((result) {
      if (result != null && mounted) Navigator.of(context).pop(result);
    });
    // On Android/iOS use an embedded webview; on web/desktop fall back to launching external browser
    try {
      _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller!.setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          _vm.onPageStarted();
          if (url.contains('/payment/true') || url.contains('/payment/false')) {
            final success = url.contains('/payment/true');
            Navigator.of(context).pop(success);
          }
        },
        onPageFinished: (url) => _vm.onPageFinished(),
        onNavigationRequest: (r) {
          // Block non-http/https schemes (deep link) and forward to VM
          final uri = Uri.tryParse(r.url);
          if (uri != null && uri.scheme != 'http' && uri.scheme != 'https') {
            _vm.handleIncomingLink(r.url);
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
      }
    } catch (_) {
      // fallback: open external browser
      _openExternal();
    }
  }

  

  @override
  void dispose() {
    _resultSub?.cancel();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // Cannot detect callback in external browser - keep this screen open and let user confirm
    _vm.markExternalLaunched();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Payment')),
          body: Stack(children: [
            if (!_vm.externalLaunched && _controller != null) WebViewWidget(controller: _controller!),
            if (_vm.externalLaunched)
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
            if (_vm.loading) const Center(child: CircularProgressIndicator()),
          ]),
        );
      },
    );
  }
}

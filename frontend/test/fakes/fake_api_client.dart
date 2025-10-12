import 'dart:async';

/// Simple fake api client used only in tests; not intended to implement the real ApiClient signature.
class FakeApiClient {
  FakeApiClient({this.responses = const {}});

  final Map<String, dynamic> responses;
  Duration? delay;
  dynamic throwOnCall;

  Future<dynamic> getData(String path) async {
    if (throwOnCall != null) throw throwOnCall;
    if (delay != null) await Future.delayed(delay!);
    return responses[path];
  }

  Future<dynamic> postData(String path, {dynamic data}) async {
    if (throwOnCall != null) throw throwOnCall;
    if (delay != null) await Future.delayed(delay!);
    return responses[path];
  }
}

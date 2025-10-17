import 'package:nova_mobile/core/network/api_client.dart';
import 'package:nova_mobile/core/endpoints.dart';

class PaymentRepository {
  final ApiClient _api = ApiClient();

  /// Calls backend to create a VnPay payment URL for given payload.
  /// Payload should contain: orderType, amount, orderDescription, name
  Future<String> createPaymentUrl(Map<String, dynamic> payload) async {
    final data = await _api.postData(Endpoints.payment, data: payload);
    // backend commonly returns { paymentUrl: 'https://...' }
    if (data is Map) {
      if (data.containsKey('paymentUrl') && data['paymentUrl'] is String) return data['paymentUrl'] as String;
      // Some wrappers return { data: { paymentUrl: '...' } }
      if (data.containsKey('data') && data['data'] is Map && (data['data'] as Map).containsKey('paymentUrl')) {
        return (data['data'] as Map)['paymentUrl'] as String;
      }
    }
    // Fallback: if API unwrapped returned a string
    if (data is String && data.startsWith('http')) return data;

    // Last attempt: if resp is a Uri-like object
    if (data is Uri) return data.toString();

    // Nothing matched - include the raw response in the error to help debugging
    throw Exception('Invalid payment url response: ${data.runtimeType} -> ${data?.toString() ?? '<null>'}');
  }
}

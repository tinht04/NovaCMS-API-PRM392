import '../core/network/api_client.dart';
import '../core/endpoints.dart';

class ReservationRepository {
  final ApiClient _api = ApiClient();

  /// Creates reservation. Payload shape:
  /// { items: [ { equipmentId, quantity, rentalStartDate, rentalEndDate } ] }
  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> payload) async {
    final data = await _api.postData(Endpoints.reservation, data: payload);
    // Expect wrapper { data: { reservationId: '...', expiresAt: '...', ... } }
    if (data is Map && data.containsKey('reservationId')) return Map<String, dynamic>.from(data);
    if (data is Map && data.containsKey('data') && data['data'] is Map) return Map<String, dynamic>.from(data['data']);
    return {};
  }
}

import 'package:flutter/foundation.dart';
import '../services/cart_service.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/payment_repository.dart';

/// ViewModel wrapper around the singleton [CartService].
/// Keeps a small adapter layer so UI can depend on a ChangeNotifier VM instead
/// of directly referencing the service throughout the app.
class CartViewModel extends ChangeNotifier {
  final CartService _service = CartService.instance;

  CartViewModel() {
    _service.addListener(_onServiceChanged);
  }

  void _onServiceChanged() => notifyListeners();

  List<Map<String, dynamic>> get items => _service.items;

  double get total => _service.total;

  void addItem(Map<String, dynamic> item) => _service.addItem(item);

  void removeAt(int index) => _service.removeAt(index);

  void clear() => _service.clear();

  /// Create reservation for the selected item indexes and return a payment URL
  /// produced by the backend. Throws on failure.
  Future<String> createPaymentUrlForSelectedIndexes(Set<int> selectedIndexes) async {
    if (selectedIndexes.isEmpty) {
      throw Exception('No items selected');
    }

    // Build selected items payload from service items
    final selectedItems = [for (final i in selectedIndexes) _service.items[i]];

    // Validate rental dates
    for (final it in selectedItems) {
      if (it['rentalStartDate'] == null || it['rentalEndDate'] == null) {
        throw Exception('Each selected item must include rental start/end dates.');
      }
    }

    final itemsPayload = selectedItems.map((it) => {
      'equipmentId': it['equipmentId'] ?? it['id'],
      'quantity': it['quantity'] ?? 1,
      'rentalStartDate': it['rentalStartDate'],
      'rentalEndDate': it['rentalEndDate'],
    }).toList();

    final reservationRepo = ReservationRepository();
    final paymentRepo = PaymentRepository();

    final resPayload = {'items': itemsPayload};
    final reservationResp = await reservationRepo.createReservation(resPayload);
    if (reservationResp.isEmpty || reservationResp['reservationId'] == null) {
      throw Exception('Reservation failed');
    }

    final reservationId = reservationResp['reservationId'];
    final backendAmount = reservationResp['amount'] ?? reservationResp['totalAmount'] ?? reservationResp['total'];

    // Build payment payload and request URL
    final paymentPayload = {
      'reservationId': reservationId,
      'amount': backendAmount,
    };
    final url = await paymentRepo.createPaymentUrl(paymentPayload);
    return url;
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}

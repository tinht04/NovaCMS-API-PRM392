import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/profile_repository.dart';
import 'checkout_webview_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService.instance;
  // rental dates are provided per-item when adding to cart

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
    // load cart from server to populate items with server state (including rental dates)
    _cart.loadFromServer();
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  Future<void> _checkout() async {
    if (_cart.items.isEmpty) return;
    // Ensure each cart item contains rentalStartDate and rentalEndDate (added at Add-to-Cart time)
    for (final it in _cart.items) {
      if (it['rentalStartDate'] == null || it['rentalEndDate'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Each cart item must include rental start/end dates. Please set them when adding items.')));
        return;
      }
    }

    // Build reservation payload from cart using per-item rental dates
    final itemsPayload = _cart.items.map((it) => {
          'equipmentId': it['equipmentId'] ?? it['id'],
          'quantity': it['quantity'] ?? 1,
          'rentalStartDate': it['rentalStartDate'],
          'rentalEndDate': it['rentalEndDate'],
        }).toList();

    final reservationRepo = ReservationRepository();
    final paymentRepo = PaymentRepository();
    final amount = _cart.total;

    try {
      // Create reservation first
      final resPayload = {'items': itemsPayload};
      final reservationResp = await reservationRepo.createReservation(resPayload);
      if (reservationResp.isEmpty || reservationResp['reservationId'] == null) {
        throw Exception('Reservation failed');
      }
      final reservationId = reservationResp['reservationId'];

      // Try to get logged-in user's name
      String payerName = 'Guest';
      try {
        final profile = await ProfileRepository().getProfile();
        if (profile.isNotEmpty) {
          payerName = profile['fullName'] ?? profile['full_name'] ?? profile['name'] ?? payerName;
        }
      } catch (_) {}

      // Call payment API with reservationId
      final paymentPayload = {'reservationId': reservationId, 'amount': amount, 'Name': payerName};
      final url = await paymentRepo.createPaymentUrl(paymentPayload);
      if (!mounted) return;
      // open WebView for payment and wait result
      final res = await Navigator.push<dynamic>(context, MaterialPageRoute(builder: (_) => CheckoutWebViewScreen(paymentUrl: url)));
      // Support multiple result shapes:
      // - previously we returned bool (true on success)
      // - for web listener we return a Map { 'success': bool, 'params': {...} }
      var success = false;
      Map<String, dynamic>? callbackParams;
      if (res is bool) {
        success = res;
      } else if (res is Map) {
        try {
          success = res['success'] == true;
          callbackParams = Map<String, dynamic>.from(res['params'] ?? {});
        } catch (_) {}
      }

      if (success) {
        // assume success: clear cart
        _cart.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment completed')));
        // Optionally show callback details in a dialog if available
        if (callbackParams != null && callbackParams.isNotEmpty) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Payment details'),
              content: SingleChildScrollView(child: Text(callbackParams.toString())),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Your cart is empty')]))
          : ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text('Total: ₫${_cart.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _checkout, child: const Text('Checkout')),
                    ]),
                  );
                }
                final it = items[index];
                final title = it['name'] ?? it['title'] ?? 'Item';
                final price = it['pricePerDay'] ?? it['price'] ?? 0;
                final qty = it['quantity'] ?? 1;
                return ListTile(title: Text(title), subtitle: Text('₫${price.toString()} x $qty'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => _cart.removeAt(index))));
              },
            ),
    );
  }
}

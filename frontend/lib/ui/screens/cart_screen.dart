import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/profile_repository.dart';
import 'checkout_webview_screen.dart';
import 'payment_result_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService.instance;
  // rental dates are provided per-item when adding to cart
  // Lưu trạng thái chọn của từng item (theo index)
  Set<int> _selectedIndexes = <int>{};

  @override
  void initState() {
  super.initState();
  _cart.addListener(_onCartChanged);
  // Không gọi loadFromServer ở đây để tránh clear data khi chuyển màn hình
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  Future<void> _checkout() async {
    if (_selectedIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one item to checkout.')));
      return;
    }
    // Lấy các item được chọn
    final selectedItems = [for (final i in _selectedIndexes) _cart.items[i]];
    // Ensure each selected item contains rentalStartDate and rentalEndDate
    for (final it in selectedItems) {
      if (it['rentalStartDate'] == null || it['rentalEndDate'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Each selected item must include rental start/end dates. Please set them when adding items.')));
        return;
      }
    }

    // Build reservation payload from selected items
    final itemsPayload = selectedItems.map((it) => {
      'equipmentId': it['equipmentId'] ?? it['id'],
      'quantity': it['quantity'] ?? 1,
      'rentalStartDate': it['rentalStartDate'],
      'rentalEndDate': it['rentalEndDate'],
    }).toList();

    final reservationRepo = ReservationRepository();
    final paymentRepo = PaymentRepository();
  // Tính tổng tiền các item được chọn
  final amount = selectedItems.fold<double>(0, (sum, it) => sum + ((it['pricePerDay'] ?? it['price'] ?? 0) * (it['quantity'] ?? 1)));

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
      final paymentPayload = {'reservationId': reservationId, 'amount': amount};
      final url = await paymentRepo.createPaymentUrl(paymentPayload);
      if (!mounted) return;
      // open WebView for payment and wait result
      final res = await Navigator.push<dynamic>(context, MaterialPageRoute(builder: (_) => CheckoutWebViewScreen(paymentUrl: url)));
      // Support multiple result shapes:
      // - previously we returned bool (true on success)
      // - for web listener we return a Map { 'success': bool, 'params': {...} }
      var success = false;
      if (res is bool) {
        success = res;
      } else if (res is Map) {
        try {
          success = res['success'] == true;
        } catch (_) {}
      }

      if (success) {
        // Clear cart on successful payment
        _cart.clear();
        // Navigate to payment result screen
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PaymentResultScreen(success: true)
        ));
      } else {
        // Show failure result
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PaymentResultScreen(success: false)
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
  final items = _cart.items;
  // _selectedIndexes luôn được khởi tạo, không cần kiểm tra null
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Your cart is empty')]))
          : ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == items.length) {
                  // Tính tổng tiền các item được chọn
                  final selectedItems = [for (final i in _selectedIndexes) if (i < items.length) items[i]];
                  final selectedTotal = selectedItems.fold<double>(0, (sum, it) => sum + ((it['pricePerDay'] ?? it['price'] ?? 0) * (it['quantity'] ?? 1)));
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text('Selected total: ₫${selectedTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _checkout, child: const Text('Checkout')),
                    ]),
                  );
                }
                final it = items[index];
                final title = it['name'] ?? it['title'] ?? 'Item';
                final price = it['pricePerDay'] ?? it['price'] ?? 0;
                final qty = it['quantity'] ?? 1;
                final selected = _selectedIndexes.contains(index);
                return ListTile(
                  leading: Checkbox(
                    value: selected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedIndexes.add(index);
                        } else {
                          _selectedIndexes.remove(index);
                        }
                      });
                    },
                  ),
                  title: Text(title),
                  subtitle: Text('₫${price.toString()} x $qty'),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
                    setState(() {
                      _cart.removeAt(index);
                      _selectedIndexes.remove(index);
                    });
                  }),
                );
              },
            ),
    );
  }
}

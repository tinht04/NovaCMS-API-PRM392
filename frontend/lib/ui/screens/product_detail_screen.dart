import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../../core/network/api_client.dart';
import '../../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _repo = ProductRepository(apiClient: ApiClient());
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _item;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id'] ?? 0;
    _load(id as int);
  }

  Future<void> _load(int id) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getById(id);
      if (mounted) setState(() => _item = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(appBar: AppBar(title: const Text('Product')), body: Center(child: Text('Error: $_error')));
    if (_item == null) return Scaffold(appBar: AppBar(title: const Text('Product')), body: const Center(child: Text('Not found')));

    final title = _item?['name'] ?? 'Product';
    final brand = _item?['brand'] ?? '';
    final desc = _item?['description'] ?? '';
    final price = _item?['pricePerDay'] ?? _item?['price'] ?? 0;
    final deposit = _item?['depositFee'] ?? 0;
    final stock = _item?['stock'] ?? 0;
    final category = _item?['categoryName'] ?? '';
    final available = _item?['isAvailable'] ?? false;
    List images = [];
    if (_item?['imageResponses'] is List) images = _item?['imageResponses'] as List;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    final img = images[i] as Map<String, dynamic>;
                    final url = img['imageUrl'];
                    return url == null ? Container(color: Colors.grey.shade200) : Image.network(url, fit: BoxFit.cover);
                  },
                ),
              )
            else
              SizedBox(height: 220, child: Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.camera_alt, size: 64)))),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('$brand • $category', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(desc),
            const SizedBox(height: 12),
            Row(children: [Text('Price/day: ₫${price.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12), Text('Deposit: ₫${deposit.toString()}')]),
            const SizedBox(height: 8),
            Text('Stock: $stock • ${available ? 'Available' : 'Not available'}'),
            const SizedBox(height: 12),
            if (stock == 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red.shade200)),
                child: const Text('Hết máy cho thuê — vui lòng quay lại lúc khác', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: stock == 0 ? null : () async {
              // Show a clear dialog with labeled Start and End fields so user knows which is which
              final result = await showDialog<Map<String, DateTime>?>(
                context: context,
                builder: (ctx) {
                  DateTime? localStart = DateTime.now();
                  DateTime? localEnd = DateTime.now().add(const Duration(days: 1));
                  return StatefulBuilder(builder: (ctx, setState) {
                    String fmt(DateTime? d) => d == null ? 'Not selected' : d.toLocal().toString().split('.').first;
                    return AlertDialog(
                      title: const Text('Select rental period'),
                      content: Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          title: const Text('Start'),
                          subtitle: Text(fmt(localStart)),
                          trailing: TextButton(
                            onPressed: () async {
                              final d = await showDatePicker(context: ctx, initialDate: localStart ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
                              if (d == null) return;
                              final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(localStart ?? DateTime.now()));
                              final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
                              setState(() => localStart = dt);
                            },
                            child: const Text('Select'),
                          ),
                        ),
                        ListTile(
                          title: const Text('End'),
                          subtitle: Text(fmt(localEnd)),
                          trailing: TextButton(
                            onPressed: () async {
                              final initial = localEnd ?? (localStart?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)));
                              final d = await showDatePicker(context: ctx, initialDate: initial, firstDate: localStart ?? DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                              if (d == null) return;
                              final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(localEnd ?? DateTime.now()));
                              final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
                              setState(() => localEnd = dt);
                            },
                            child: const Text('Select'),
                          ),
                        ),
                      ]),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                        ElevatedButton(onPressed: () {
                          if (localStart == null || localEnd == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please select both start and end')));
                            return;
                          }
                          if (!localEnd!.isAfter(localStart!)) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('End must be after start')));
                            return;
                          }
                          Navigator.of(ctx).pop({'start': localStart!, 'end': localEnd!});
                        }, child: const Text('Add to cart')),
                      ],
                    );
                  });
                }
              );

              if (result == null) return; // user cancelled
              final start = result['start']!;
              final end = result['end']!;
              final cartItem = Map<String, dynamic>.from(_item!);
              cartItem['rentalStartDate'] = start.toUtc().toIso8601String();
              cartItem['rentalEndDate'] = end.toUtc().toIso8601String();
              CartService.instance.addItem(cartItem);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
            }, child: const Text('Add to cart')),
          ]),
        ),
      ),
    );
  }
}

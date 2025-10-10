import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../../core/network/api_client.dart';

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getById(id);
      setState(() => _item = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
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
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/cart'), child: const Text('Add to cart')),
          ]),
        ),
      ),
    );
  }
}

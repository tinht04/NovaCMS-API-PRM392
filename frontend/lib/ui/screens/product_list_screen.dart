import 'package:flutter/material.dart';
import '../../viewmodels/product_list_viewmodel.dart';
import '../../repositories/product_repository.dart';
import '../../core/network/api_client.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.viewModel});

  final ProductListViewModel? viewModel;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // ProductRepository requires an ApiClient; by default instantiate with default ApiClient
  late final ProductListViewModel _vm;
  late final VoidCallback _vmListener;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? ProductListViewModel(ProductRepository(apiClient: ApiClient()));
    _vmListener = () => setState(() {});
    _vm.addListener(_vmListener);
    // Ensure the view model loads items whether injected (tests) or created here (production).
    _vm.load();
  }

  @override
  void dispose() {
    _vm.removeListener(_vmListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Builder(builder: (context) {
        if (_vm.loading) return const Center(child: CircularProgressIndicator());
        if (_vm.error != null) return Center(child: Text('Error: ${_vm.error}'));
        if (_vm.items.isEmpty) return const Center(child: Text('No products'));
        return ListView.builder(
          itemCount: _vm.items.length,
          itemBuilder: (context, index) {
            final item = _vm.items[index];
            final id = item is Map ? (item['equipmentId'] ?? item['id'] ?? index) : index;
            final title = item is Map ? (item['equipmentName'] ?? item['name'] ?? 'Product #$index') : 'Product #$index';
            final image = item is Map ? (item['imageUrl'] ?? item['image']) : null;
            return ListTile(
              leading: image == null ? const CircleAvatar(child: Icon(Icons.camera_alt)) : CircleAvatar(backgroundImage: NetworkImage(image)),
              title: Text('$title'),
              subtitle: Text('ID: $id'),
              onTap: () => Navigator.pushNamed(context, '/product', arguments: {'id': id}),
            );
          },
        );
      }),
    );
  }
}

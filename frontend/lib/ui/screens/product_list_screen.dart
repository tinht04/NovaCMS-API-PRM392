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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          // Search and filters
          Row(children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products...'),
                onSubmitted: (v) => _vm.load(filters: {..._vm.filters, 'SearchTerm': v}),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: () {
                  // open simple filter dialog
                  showDialog(context: context, builder: (c) => _FilterDialog(filters: _vm.filters, onApply: (f) => _vm.load(filters: f)));
                },
                child: const Icon(Icons.filter_list))
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: Builder(builder: (context) {
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
          )
        ]),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final Map<String, dynamic> filters;
  final void Function(Map<String, dynamic>) onApply;
  const _FilterDialog({required this.filters, required this.onApply});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late TextEditingController _categoryCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _minPrice;
  late TextEditingController _maxPrice;
  late bool _isAvailable;
  late TextEditingController _minRating;
  late String _sortBy;
  late TextEditingController _pageNumber;
  late TextEditingController _pageSize;

  @override
  void initState() {
    super.initState();
    _categoryCtrl = TextEditingController(text: widget.filters['CategoryId']?.toString() ?? '');
    _brandCtrl = TextEditingController(text: widget.filters['Brand'] ?? '');
    _minPrice = TextEditingController(text: widget.filters['MinPrice']?.toString() ?? '');
    _maxPrice = TextEditingController(text: widget.filters['MaxPrice']?.toString() ?? '');
    _isAvailable = widget.filters['IsAvailable'] == 'true' || widget.filters['IsAvailable'] == true;
    _minRating = TextEditingController(text: widget.filters['MinRating']?.toString() ?? '');
  // default: newest (EquipmentId descending)
  _sortBy = widget.filters['SortBy'] ?? 'newest';
    _pageNumber = TextEditingController(text: widget.filters['PageNumber']?.toString() ?? '1');
    _pageSize = TextEditingController(text: widget.filters['PageSize']?.toString() ?? '10');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filters'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: 'CategoryId')),
          TextField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'Brand')),
          Row(children: [Expanded(child: TextField(controller: _minPrice, decoration: const InputDecoration(labelText: 'MinPrice'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _maxPrice, decoration: const InputDecoration(labelText: 'MaxPrice')))]),
          SwitchListTile(title: const Text('Is Available'), value: _isAvailable, onChanged: (v) => setState(() => _isAvailable = v)),
          TextField(controller: _minRating, decoration: const InputDecoration(labelText: 'MinRating')),
          DropdownButtonFormField<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'price_asc', child: Text('Price: low → high')),
              DropdownMenuItem(value: 'price_desc', child: Text('Price: high → low')),
              DropdownMenuItem(value: 'name_asc', child: Text('Name: A → Z')),
              DropdownMenuItem(value: 'name_desc', child: Text('Name: Z → A')),
              DropdownMenuItem(value: 'newest', child: Text('Newest')),
            ],
            onChanged: (v) => setState(() => _sortBy = v ?? 'newest'),
          ),
          Row(children: [Expanded(child: TextField(controller: _pageNumber, decoration: const InputDecoration(labelText: 'PageNumber'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _pageSize, decoration: const InputDecoration(labelText: 'PageSize')))]),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () {
        final Map<String, dynamic> q = {};
        if (_categoryCtrl.text.isNotEmpty) q['CategoryId'] = int.tryParse(_categoryCtrl.text) ?? _categoryCtrl.text;
        if (_brandCtrl.text.isNotEmpty) q['Brand'] = _brandCtrl.text;
        if (_minPrice.text.isNotEmpty) q['MinPrice'] = int.tryParse(_minPrice.text) ?? _minPrice.text;
        if (_maxPrice.text.isNotEmpty) q['MaxPrice'] = int.tryParse(_maxPrice.text) ?? _maxPrice.text;
        q['IsAvailable'] = _isAvailable;
        if (_minRating.text.isNotEmpty) q['MinRating'] = int.tryParse(_minRating.text) ?? _minRating.text;
        q['SortBy'] = _sortBy;
        if (_pageNumber.text.isNotEmpty) q['PageNumber'] = int.tryParse(_pageNumber.text) ?? _pageNumber.text;
        if (_pageSize.text.isNotEmpty) q['PageSize'] = int.tryParse(_pageSize.text) ?? _pageSize.text;
        widget.onApply(q);
        Navigator.pop(context);
      }, child: const Text('Apply'))],
    );
  }
}

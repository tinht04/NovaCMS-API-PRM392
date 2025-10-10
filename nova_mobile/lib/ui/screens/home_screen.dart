import 'package:flutter/material.dart';

import '../../viewmodels/product_list_viewmodel.dart';
import '../../repositories/product_repository.dart';
import '../../core/network/api_client.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_card.dart';

/// Improved home screen: greeting, quick stats, featured products and map preview.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProductListViewModel _vm;
  late final VoidCallback _vmListener;
  

  @override
  void initState() {
    super.initState();
    _vm = ProductListViewModel(ProductRepository(apiClient: ApiClient()));
    _vmListener = () => setState(() {});
    _vm.addListener(_vmListener);
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
      appBar: AppBar(
        title: Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/products'),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(children: const [Icon(Icons.search, color: Colors.black45), SizedBox(width: 8), Text('Search for equipment', style: TextStyle(color: Colors.black45))]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ]),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _vm.load(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  BannerCarousel(images: [
                    'https://picsum.photos/900/300?random=1',
                    'https://picsum.photos/900/300?random=2',
                    'https://picsum.photos/900/300?random=3',
                  ]),
                  const SizedBox(height: 12),
                  // Categories grid
                  SizedBox(
                    height: 92,
                    child: GridView.count(
                      crossAxisCount: 5,
                      childAspectRatio: 0.8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(10, (i) => Column(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(backgroundColor: Colors.blue.shade100, child: Icon(Icons.category, color: Colors.blue)), const SizedBox(height: 6), Text('Cat ${i + 1}', style: const TextStyle(fontSize: 12))])),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),

            // Product grid
            Builder(builder: (context) {
              if (_vm.loading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              if (_vm.error != null) return SliverFillRemaining(child: Center(child: Text('Error: ${_vm.error}')));
              if (_vm.items.isEmpty) return const SliverFillRemaining(child: Center(child: Text('No products')));
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _vm.items[index] as Map<String, dynamic>;
                    return ProductCard(item: item, onTap: () => Navigator.pushNamed(context, '/product', arguments: {'id': item['equipmentId']}));
                  }, childCount: _vm.items.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.7),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}

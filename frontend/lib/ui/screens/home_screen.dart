import 'package:flutter/material.dart';

import '../../viewmodels/product_list_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
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
  late final HomeViewModel _homeVm;
  late final VoidCallback _vmListener;
  late final VoidCallback _homeListener;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  // Don't construct repositories/api clients in the UI. Create viewmodels
  // which own data-layer interactions. Tests can inject fakes by passing
  // viewmodels into the widget if needed.
  _vm = ProductListViewModel();
  _homeVm = HomeViewModel();
  _vmListener = () => setState(() {});
  _homeListener = () => setState(() {});
  _vm.addListener(_vmListener);
  _homeVm.addListener(_homeListener);
  _vm.load();
  // Load categories via HomeViewModel
  _homeVm.loadCategories();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        _vm.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _vm.removeListener(_vmListener);
    _homeVm.removeListener(_homeListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.camera_alt_rounded, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Nova Camera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _vm.load(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/products'),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Text(
                          'Search for camera equipment...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Carousel
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BannerCarousel(
                        images: [
                          'https://picsum.photos/900/300?random=1',
                          'https://picsum.photos/900/300?random=2',
                          'https://picsum.photos/900/300?random=3',
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Categories Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/products'),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Categories Horizontal List
                    SizedBox(
                      height: 100,
                      child:
              _homeVm.categories.isEmpty
                ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder:
                                    (context, i) => Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.category,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Loading...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              )
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _homeVm.categories.length,
                                itemBuilder: (context, i) {
                                  final c = _homeVm.categories[i];
                                  final name =
                                      c['categoryName'] ??
                                      c['category_name'] ??
                                      'Category';
                                  final id = c['categoryId'] ?? c['id'];
                                  return GestureDetector(
                                    onTap:
                                        () => Navigator.pushNamed(
                                          context,
                                          '/products',
                                          arguments: {'CategoryId': id},
                                        ),
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.primaryColor
                                                      .withOpacity(0.2),
                                                  theme.primaryColor
                                                      .withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: theme.primaryColor,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 24),

                    // Featured Products Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Products',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/products'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Product Grid
            Builder(
              builder: (context) {
                if (_vm.loading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (_vm.error != null) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${_vm.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _vm.load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (_vm.items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text('No products available'),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = _vm.items[index] as Map<String, dynamic>;
                      return ProductCard(
                        item: item,
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/product',
                              arguments: {'id': item['equipmentId']},
                            ),
                      );
                    }, childCount: _vm.items.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget xây dựng nội dung cho AppBar ---
  Widget _buildAppBarContent(BuildContext context, Color primaryBlue, Color darkBlue) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Image.asset('assets/icons/camera3.png', height: 28, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Nova Camera',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 28, color: Colors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildSearchBar(context, isTitle: false),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget xây dựng thanh tìm kiếm có thể tái sử dụng ---
  Widget _buildSearchBar(BuildContext context, {required bool isTitle}) {

    final container = Container(
      height: 50,
      decoration: BoxDecoration(
        color: isTitle ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isTitle ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isTitle ? null : Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12),
            child: Icon(Icons.search, color: Colors.grey.shade600),
          ),
          Expanded(
            child: Text(
              'Search for camera equipment...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/products'),

      child: isTitle ? AbsorbPointer(child: container) : container,
    );
  }

  // Widget skeleton cho category khi đang loading
  Widget _buildCategorySkeleton() {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            width: 50,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4)
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            width: 35,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4)
            ),
          ),
        ],
      ),
    );
  }
}

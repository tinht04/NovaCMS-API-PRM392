import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../repositories/product_repository.dart';
import '../../core/network/api_client.dart';
import '../../services/cart_service.dart';
import '../../services/notification_service.dart';

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
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final title = _item?['name'] ?? _item?['equipmentName'] ?? 'Product';
    final brand = _item?['brand'] ?? '';
    final desc = _item?['description'] ?? 'No description available';
    final price = _item?['pricePerDay'] ?? _item?['price'] ?? 0;
    final deposit = _item?['depositFee'] ?? 0;
    final stock = _item?['stock'] ?? 0;
    final category = _item?['categoryName'] ?? '';
    final available = _item?['isAvailable'] ?? false;
    List images = [];
    if (_item?['imageResponses'] is List)
      images = _item?['imageResponses'] as List;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.primaryColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isFavorite
                                  ? 'Added to favorites'
                                  : 'Removed from favorites',
                            ),
                          ],
                        ),
                        backgroundColor: _isFavorite ? Colors.red : Colors.grey,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  images.isNotEmpty
                      ? PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, i) {
                          final img = images[i] as Map<String, dynamic>;
                          final url = img['imageUrl'];
                          return url == null
                              ? Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                              )
                              : Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              );
                        },
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                  // Image indicator dots
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating and Reviews Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.8',
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(127 reviews)',
                                style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2.3k views',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title and Category
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (brand.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.business_outlined,
                                  size: 14,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  brand,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (category.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 14,
                                  color: Colors.purple.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Availability Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            available && stock > 0
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              available && stock > 0
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            available && stock > 0
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color:
                                available && stock > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            available && stock > 0
                                ? 'Available ($stock in stock)'
                                : 'Out of Stock',
                            style: TextStyle(
                              color:
                                  available && stock > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Price Cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price per day',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₫${price.toString()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deposit',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₫${deposit.toString()}',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description Section
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        desc,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Features Section
                    Row(
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Key Features',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.verified_outlined,
                      'Professional Grade',
                      'High-quality equipment for professionals',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.security_outlined,
                      'Insured Equipment',
                      'All items covered by comprehensive insurance',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.support_agent_outlined,
                      '24/7 Support',
                      'Round-the-clock customer assistance',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.local_shipping_outlined,
                      'Fast Delivery',
                      'Quick and secure delivery to your location',
                      theme,
                    ),

                    const SizedBox(height: 100), // Space for fixed button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Fixed Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed:
                  stock == 0
                      ? null
                      : () async {
                        // Show rental period dialog
                        final result = await showDialog<Map<String, DateTime>?>(
                          context: context,
                          builder: (ctx) {
                            DateTime? localStart = DateTime.now();
                            DateTime? localEnd = DateTime.now().add(
                              const Duration(days: 1),
                            );
                            return StatefulBuilder(
                              builder: (ctx, setState) {
                                String fmt(DateTime? d) =>
                                    d == null
                                        ? 'Not selected'
                                        : d
                                            .toLocal()
                                            .toString()
                                            .split('.')
                                            .first;
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Select Rental Period'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: const Text('Start Date'),
                                        subtitle: Text(fmt(localStart)),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          onPressed: () async {
                                            final d = await showDatePicker(
                                              context: ctx,
                                              initialDate:
                                                  localStart ?? DateTime.now(),
                                              firstDate: DateTime.now()
                                                  .subtract(
                                                    const Duration(days: 1),
                                                  ),
                                              lastDate: DateTime.now().add(
                                                const Duration(days: 365),
                                              ),
                                            );
                                            if (d == null) return;
                                            final t = await showTimePicker(
                                              context: ctx,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                    localStart ??
                                                        DateTime.now(),
                                                  ),
                                            );
                                            final dt = DateTime(
                                              d.year,
                                              d.month,
                                              d.day,
                                              t?.hour ?? 0,
                                              t?.minute ?? 0,
                                            );
                                            setState(() => localStart = dt);
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('End Date'),
                                        subtitle: Text(fmt(localEnd)),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          onPressed: () async {
                                            final initial =
                                                localEnd ??
                                                (localStart?.add(
                                                      const Duration(days: 1),
                                                    ) ??
                                                    DateTime.now().add(
                                                      const Duration(days: 1),
                                                    ));
                                            final d = await showDatePicker(
                                              context: ctx,
                                              initialDate: initial,
                                              firstDate:
                                                  localStart ?? DateTime.now(),
                                              lastDate: DateTime.now().add(
                                                const Duration(days: 365),
                                              ),
                                            );
                                            if (d == null) return;
                                            final t = await showTimePicker(
                                              context: ctx,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                    localEnd ?? DateTime.now(),
                                                  ),
                                            );
                                            final dt = DateTime(
                                              d.year,
                                              d.month,
                                              d.day,
                                              t?.hour ?? 0,
                                              t?.minute ?? 0,
                                            );
                                            setState(() => localEnd = dt);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(ctx).pop(null),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (localStart == null ||
                                            localEnd == null) {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select both start and end dates',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (!localEnd!.isAfter(localStart!)) {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'End date must be after start date',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.of(ctx).pop({
                                          'start': localStart!,
                                          'end': localEnd!,
                                        });
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );

                        if (result == null) return;
                        final start = result['start']!;
                        final end = result['end']!;
                        final cartItem = Map<String, dynamic>.from(_item!);
                        cartItem['rentalStartDate'] =
                            start.toUtc().toIso8601String();
                        cartItem['rentalEndDate'] =
                            end.toUtc().toIso8601String();


                        CartService.instance.addItem(cartItem);
                        final productName = _item?['name'] ?? _item?['equipmentName'] ?? 'Sản phẩm';
                        NotificationService.instance.add(
                          'Đã thêm "$productName" vào giỏ hàng!',
                          onTap: () {
                            if (context.mounted) {
                              Navigator.of(context).pushNamed('/cart');
                            }
                          },
                        );

                        if (!context.mounted) return;
                        showSimpleNotification(
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/cart');
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Added to cart successfully! Tap to view cart.'),
                              ],
                            ),
                          ),
                          background: Colors.green,
                          autoDismiss: true,
                          slideDismiss: true,
                          position: NotificationPosition.top,
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  const SizedBox(width: 8),
                  Text(
                    stock == 0 ? 'Out of Stock' : 'Add to Cart',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

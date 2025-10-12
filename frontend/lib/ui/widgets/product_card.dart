import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = item['equipmentName'] ?? item['name'] ?? 'Product';
    String? image;
    // Try several places for image
    if (item['imageUrl'] != null) image = item['imageUrl'] as String?;
    if (image == null && item['imageResponses'] is List && (item['imageResponses'] as List).isNotEmpty) {
      final first = (item['imageResponses'] as List).first as Map<String, dynamic>;
      image = first['imageUrl'] as String?;
    }
    final priceVal = item['price'] ?? item['pricePerDay'] ?? item['pricePerDay'];
    final price = priceVal != null ? (priceVal is num ? priceVal.toStringAsFixed(0) : priceVal.toString()) : '';
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: image == null
                  ? Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.camera_alt)))
                  : Image.network(image, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(price.isNotEmpty ? '\u20AB$price' : '', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

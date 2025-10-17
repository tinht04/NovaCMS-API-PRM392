import 'dart:async';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> images;
  const BannerCarousel({super.key, required this.images});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const SizedBox(height: 140, child: Center(child: Text('No banners')));
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        onPageChanged: (p) => _current = p,
        itemBuilder: (context, index) {
          final e = images[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(e, fit: BoxFit.cover, width: double.infinity)),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Autoplay every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final images = widget.images;
      if (images.isEmpty) return;
      _current = (_current + 1) % images.length;
      if (mounted) {
        _controller.animateToPage(_current, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

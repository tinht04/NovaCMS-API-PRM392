import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreMapScreen extends StatelessWidget {
  static const LatLng storeLatLng = LatLng(10.841020, 106.810910);
  static const String storeAddress = 'Lô E2a-7, Đường D1, Khu Công nghệ cao, Phường Tăng Nhơn Phú, Ho Chi Minh City, Vietnam';

  const StoreMapScreen({super.key});

  void _openGoogleMapsDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${storeLatLng.latitude},${storeLatLng.longitude}'
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Location')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: storeLatLng,
                zoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: storeLatLng,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeAddress,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openGoogleMapsDirections,
                    icon: const Icon(Icons.directions),
                    label: const Text('Chỉ đường bằng Google Maps'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

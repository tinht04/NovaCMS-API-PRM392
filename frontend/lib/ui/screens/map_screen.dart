import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  static const _initialCamera = CameraPosition(target: LatLng(10.776889, 106.700806), zoom: 12); // Ho Chi Minh City approx

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        onMapCreated: (c) => _controller = c,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../viewmodels/store_map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _vm = StoreMapViewModel();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Map')),
          body: GoogleMap(
            initialCameraPosition: _vm.camera,
            onMapCreated: (c) => _vm.setController(c),
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            markers: _vm.markers,
          ),
        );
      },
    );
  }
}

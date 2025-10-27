import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreMapViewModel extends ChangeNotifier {
  /// Default camera (Ho Chi Minh City)
  static const CameraPosition defaultCamera = CameraPosition(target: LatLng(10.776889, 106.700806), zoom: 12);

  CameraPosition _camera = defaultCamera;
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  CameraPosition get camera => _camera;
  GoogleMapController? get controller => _controller;
  Set<Marker> get markers => Set.unmodifiable(_markers);

  void setController(GoogleMapController controller) {
    _controller = controller;
    notifyListeners();
  }

  void addMarker(Marker m) {
    _markers.add(m);
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  Future<void> moveTo(LatLng pos, {double zoom = 14}) async {
    _camera = CameraPosition(target: pos, zoom: zoom);
    notifyListeners();
    try {
      await _controller?.animateCamera(CameraUpdate.newCameraPosition(_camera));
    } catch (_) {}
  }
}

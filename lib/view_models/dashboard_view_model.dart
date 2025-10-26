import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class DashboardViewModel extends ChangeNotifier {
  int _airQualityLevel = 0; // 0 good, 1 moderate, 2 poor
  int get airQualityLevel => _airQualityLevel;

  double? lastLatitude;
  double? lastLongitude;
  String? cityName;

  void setAirQualityLevel(int level) {
    final clamped = level.clamp(0, 2);
    if (clamped == _airQualityLevel) return;
    _airQualityLevel = clamped;
    notifyListeners();
  }

  Future<void> refreshWithCurrentLocation(LocationService svc) async {
    final hasPerm = await svc.requestPermission();
    if (!hasPerm) return;
    final loc = await svc.getLastLocation();
    if (loc != null) {
      lastLatitude = loc.latitude;
      lastLongitude = loc.longitude;
      cityName = await svc.getCityName(loc.latitude!, loc.longitude!);
      notifyListeners();
      // TODO: fetch AQI with lat/lon and call setAirQualityLevel(...)
    }
  }

  // Call this on app start (e.g., in Dashboard initState) to perform the "first open" flow
  Future<void> initialize(LocationService svc) async {
    await refreshWithCurrentLocation(svc);
  }
}

import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class DashboardViewModel extends ChangeNotifier {
  int _airQualityLevel = 0; // 0 good, 1 moderate, 2 poor
  int get airQualityLevel => _airQualityLevel;

  double? lastLatitude;
  double? lastLongitude;
  String? cityName;
  String locationSource = 'Unknown'; // Track the source

  void setAirQualityLevel(int level) {
    final clamped = level.clamp(0, 2);
    if (clamped == _airQualityLevel) return;
    _airQualityLevel = clamped;
    notifyListeners();
  }

  Future<void> refreshWithCurrentLocation(LocationService svc) async {
    print('🚀 Starting refreshWithCurrentLocation...');
    
    final hasPerm = await svc.requestPermission();
    print('🔐 Permission result: $hasPerm');
    
    if (!hasPerm) {
      print('❌ No location permission, cannot proceed');
      notifyListeners();
      return;
    }
    
    print('🔄 Getting location...');
    final loc = await svc.getLastLocation();
    
    if (loc != null) {
      final lat = loc['latitude']!;
      final lon = loc['longitude']!;
      print('✅ Got location: $lat, $lon');
      
      lastLatitude = lat;
      lastLongitude = lon;
      locationSource = svc.lastLocationSource; // Capture the source
      
      print('🌍 Getting city name...');
      cityName = await svc.getCityName(lat, lon);
      print('🏙️ City name: $cityName');
      
      notifyListeners();
      // TODO: fetch AQI with lat/lon and call setAirQualityLevel(...)
    } else {
      print('❌ Failed to get location');
      notifyListeners();
    }
  }

  // Call this on app start (e.g., in Dashboard initState) to perform the "first open" flow
  Future<void> initialize(LocationService svc) async {
    await refreshWithCurrentLocation(svc);
  }
}

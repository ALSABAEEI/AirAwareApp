import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardViewModel extends ChangeNotifier {
  int _airQualityLevel = 0; // 0 good, 1 moderate, 2 poor
  int get airQualityLevel => _airQualityLevel;

  double? lastLatitude;
  double? lastLongitude;
  String? cityName;
  String locationSource = 'Unknown'; // Track the source
  
  // Track location status
  bool _isLocationServiceEnabled = false;
  bool _isLocationPermissionGranted = false;
  bool _needsLocationPrompt = false;
  
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get needsLocationPrompt => _needsLocationPrompt;

  void setAirQualityLevel(int level) {
    final clamped = level.clamp(0, 2);
    if (clamped == _airQualityLevel) return;
    _airQualityLevel = clamped;
    notifyListeners();
  }

  /// Check location status and set flags for UI to show prompts
  Future<void> checkLocationStatus() async {
    print('🔍 Checking location status...');
    
    // Check if location services are enabled
    _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍 Location service enabled: $_isLocationServiceEnabled');
    
    // Check if permission is granted
    final permissionStatus = await Permission.location.status;
    _isLocationPermissionGranted = permissionStatus.isGranted;
    print('🔐 Location permission granted: $_isLocationPermissionGranted');
    
    // Set flag if we need to prompt user
    _needsLocationPrompt = !_isLocationServiceEnabled || !_isLocationPermissionGranted;
    print('⚠️ Needs location prompt: $_needsLocationPrompt');
    
    notifyListeners();
  }
  
  /// Clear the location prompt flag (called after user dismisses dialog)
  void clearLocationPrompt() {
    _needsLocationPrompt = false;
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
    // First check location status to determine if we need to prompt
    await checkLocationStatus();
    
    // If location is available, try to get it
    if (_isLocationServiceEnabled && _isLocationPermissionGranted) {
      await refreshWithCurrentLocation(svc);
    } else {
      print('⚠️ Location not available - user will be prompted');
      // The UI will show the prompt based on needsLocationPrompt flag
    }
  }
}

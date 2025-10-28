import 'package:huawei_location/huawei_location.dart' as hms;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'dart:async';

class LocationService {
  final _client = hms.FusedLocationProviderClient();
  bool _isInitialized = false;
  bool _hmsAvailable = false;
  String lastLocationSource = 'Unknown'; // Track the source

  /// Initialize HMS Location Service
  Future<bool> _initializeHMS() async {
    if (_isInitialized) return _hmsAvailable;
    
    try {
      print('🔧 Initializing HMS Location Service...');
      
      // Check if HMS is available first by trying to get location availability
      try {
        final availability = await _client.checkLocationSettings(
          hms.LocationSettingsRequest(
            requests: [
              hms.LocationRequest()
                ..priority = hms.LocationRequest.PRIORITY_HIGH_ACCURACY
            ],
            alwaysShow: false,
          ),
        );
        print('📍 HMS Location availability check passed');
      } catch (e) {
        print('⚠️ HMS Location availability check failed: $e');
        // Continue anyway - might still work
      }
      
      // Set mock mode to false
      await _client.setMockMode(false);
      
      _isInitialized = true;
      _hmsAvailable = true;
      print('✅ HMS Location Service initialized successfully');
      return true;
    } catch (e) {
      print('⚠️ HMS not available: $e');
      print('📱 Will use native Android location instead');
      _isInitialized = true;
      _hmsAvailable = false;
      return false;
    }
  }

  Future<bool> requestPermission() async {
    print('🔐 Checking location permission...');
    
    // Check current status first
    final currentStatus = await Permission.location.status;
    print('📋 Current permission status: $currentStatus');
    
    if (currentStatus.isGranted) {
      print('✅ Location permission already granted');
      return true;
    }
    
    // Request permission - this will show Android's native dialog with options:
    // - Allow only this time (one-time)
    // - Allow while using the app (foreground)
    // - Allow all the time (background) - shown if you request background permission
    // - Don't allow
    print('📱 Requesting location permission from user...');
    print('💡 User will see options: Only this time, While using app, Always, or Deny');
    
    // Request foreground location permission first
    final status = await Permission.location.request();
    print('📋 Location permission result: $status');
    
    if (status.isGranted) {
      print('✅ Location permission granted!');
      
      // Optionally request background location for better experience
      print('📱 Requesting background location permission for continuous tracking...');
      final backgroundStatus = await Permission.locationAlways.request();
      print('📋 Background location result: $backgroundStatus');
      
      if (backgroundStatus.isGranted) {
        print('✅ Background location permission granted!');
      } else {
        print('ℹ️ Background location denied - will work in foreground only');
      }
      
      return true;
    }
    
    if (status.isPermanentlyDenied) {
      print('⚠️ Location permission permanently denied. Please enable in settings.');
    } else if (status.isDenied) {
      print('❌ Location permission denied by user');
    }
    
    return false;
  }

  Future<Map<String, double>?> getLastLocation() async {
    // Try HMS first (for hackathon demo)
    await _initializeHMS();
    
    if (_hmsAvailable) {
      print('🔄 Attempting to get location from HMS...');
      try {
        // Try to get last location first
        hms.Location? hmsLocation = await _client.getLastLocation();
        
        // If no last location, request location updates
        if (hmsLocation == null || hmsLocation.latitude == null) {
          print('🔄 No cached location, requesting fresh location from HMS...');
          
          final locationRequest = hms.LocationRequest()
            ..interval = 1000
            ..numUpdates = 1
            ..priority = hms.LocationRequest.PRIORITY_HIGH_ACCURACY;
          
          // Request location updates and wait for the first result
          try {
            final requestCode = await _client.requestLocationUpdates(locationRequest);
            print('📍 HMS location request sent, code: $requestCode');
            
            // Wait a bit for the location update
            await Future.delayed(const Duration(seconds: 3));
            
            // Try to get the location again
            hmsLocation = await _client.getLastLocation();
            
            // Remove location updates
            if (requestCode != null) {
              await _client.removeLocationUpdates(requestCode);
            }
          } catch (e) {
            print('❌ HMS location update request error: $e');
          }
        }
        
        if (hmsLocation != null && hmsLocation.latitude != null) {
          print('✅ Got location from HMS: ${hmsLocation.latitude}, ${hmsLocation.longitude}');
          lastLocationSource = 'HMS Location Kit';
          return {
            'latitude': hmsLocation.latitude!,
            'longitude': hmsLocation.longitude!,
          };
        } else {
          print('⚠️ HMS returned null location');
        }
      } catch (e) {
        print('⚠️ HMS location failed: $e');
      }
    }
    
    // Fallback to native Android location
    print('📱 Getting location from native Android GPS...');
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled on the device');
        print('🔔 Prompting user to enable location services...');
        
        // Try to open location settings
        bool opened = await Geolocator.openLocationSettings();
        if (opened) {
          print('✅ Location settings opened');
          // Wait a bit for user to enable location
          await Future.delayed(const Duration(seconds: 2));
          
          // Check again
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            print('❌ Location services still disabled');
            lastLocationSource = 'Failed - Service Disabled';
            return null;
          }
        } else {
          print('⚠️ Could not open location settings');
          lastLocationSource = 'Failed - Service Disabled';
          return null;
        }
      }
      
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
      print('✅ Got location from Android GPS: ${position.latitude}, ${position.longitude}');
      lastLocationSource = 'Android Native GPS';
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('❌ Failed to get location: $e');
      lastLocationSource = 'Failed';
      return null;
    }
  }

  Future<Map<String, double>?> getUserLocation() async {
    final ok = await requestPermission();
    if (!ok) {
      print('❌ Location permission denied');
      return null;
    }
    
    return await getLastLocation();
  }

  Future<String?> getCityName(double lat, double lon) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      if (p.locality != null && p.locality!.isNotEmpty) return p.locality;
      return p.administrativeArea;
    } catch (e) {
      print('❌ Error getting city name: $e');
      return null;
    }
  }
}

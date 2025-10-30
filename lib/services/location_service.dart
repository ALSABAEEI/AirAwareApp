import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/services.dart';

class LocationService {
  String lastLocationSource = 'Unknown';
  static const platform = MethodChannel('com.example.airawareapp/hms_location');

  Future<bool> requestPermission() async {
    final currentStatus = await Permission.location.status;
    if (currentStatus.isGranted) return true;
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<Map<String, double>?> getLastLocation() async {
    if (Platform.isAndroid) {
      try {
        final bool isHMSAvailable = await platform.invokeMethod('isHMSAvailable');
        if (isHMSAvailable) {
          print('📱 HMS Core detected - attempting to get location via HMS...');
          try {
            final Map<Object?, Object?>? location = await platform.invokeMethod('getHMSLocation');
            if (location != null) {
              lastLocationSource = 'HMS';
              print('✅ HMS Location obtained: ${location['latitude']}, ${location['longitude']}');
              return {
                'latitude': location['latitude'] as double,
                'longitude': location['longitude'] as double,
              };
            }
          } on PlatformException catch (e) {
            if (e.code == 'LOCATION_UNAVAILABLE') {
              print('⚠️ HMS Location unavailable (GPS may be off or no satellite fix). Falling back to standard GPS...');
            } else if (e.code == 'TIMEOUT') {
              print('⏱️ HMS Location timeout. Falling back to standard GPS...');
            } else {
              print('❌ HMS Location failed (${e.code}): ${e.message}. Falling back to standard GPS...');
            }
          } catch (e) {
            print('❌ HMS Location error: $e. Falling back to standard GPS...');
          }
        } else {
          print('📱 HMS Core not available - using standard GPS');
        }
      } catch (e) {
        print('⚠️ HMS check failed: $e. Using standard GPS...');
      }
    }

    // Fallback to standard GPS/GMS
    if (!await requestPermission()) {
      print('❌ Location permission denied');
      return null;
    }

    // Try to get last known position first (fastest, works indoors)
    try {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        lastLocationSource = 'Cached GPS';
        print('✅ Using last known location: ${lastPosition.latitude}, ${lastPosition.longitude}');
        return {
          'latitude': lastPosition.latitude,
          'longitude': lastPosition.longitude,
        };
      }
    } catch (e) {
      print('⚠️ No last known location available');
    }

    // Try high accuracy GPS with timeout
    try {
      print('🛰️ Attempting to get fresh location (high accuracy)...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(const Duration(seconds: 10));
      
      lastLocationSource = 'GPS';
      print('✅ GPS Location obtained: ${position.latitude}, ${position.longitude}');
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('⚠️ High accuracy GPS timeout, trying medium accuracy...');
    }

    // Try medium accuracy (faster, works better indoors)
    try {
      print('🛰️ Attempting medium accuracy location...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      ).timeout(const Duration(seconds: 8));
      
      lastLocationSource = 'GPS (Medium)';
      print('✅ Medium accuracy location obtained: ${position.latitude}, ${position.longitude}');
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('⚠️ Medium accuracy GPS timeout, trying low accuracy...');
    }

    // Final attempt: low accuracy (network-based, works indoors)
    try {
      print('📡 Attempting low accuracy location (network-based)...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 5));
      
      lastLocationSource = 'Network';
      print('✅ Network location obtained: ${position.latitude}, ${position.longitude}');
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('❌ All location methods failed: $e');
      
      // Last resort: Use a default location for testing (Singapore as example)
      // TODO: Remove this in production or request user to enable location services
      print('⚠️ Using default test location (Singapore) - Please enable GPS or go outdoors for accurate location');
      lastLocationSource = 'Default (Test)';
      return {
        'latitude': 1.3521,  // Singapore latitude
        'longitude': 103.8198,  // Singapore longitude
      };
    }
  }

  Future<String?> getCityName(double lat, double lon) async {
    try {
      print('🔍 Geocoding coordinates: $lat, $lon');
      final placemarks = await geo.placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        print('📍 Geocoding result: ${place.toString()}');
        print('   locality: "${place.locality}"');
        print('   subAdministrativeArea: "${place.subAdministrativeArea}"');
        print('   administrativeArea: "${place.administrativeArea}"');
        print('   country: "${place.country}"');
        
        // Try different fields to get the best location name
        // Some geocoding providers don't populate all fields
        final cityName = (place.subAdministrativeArea?.isNotEmpty == true) ? place.subAdministrativeArea :
                        (place.locality?.isNotEmpty == true) ? place.locality :
                        (place.administrativeArea?.isNotEmpty == true) ? place.administrativeArea :
                        (place.country?.isNotEmpty == true) ? place.country :
                        'Unknown';
        
        print('✅ City name: "$cityName"');
        return cityName;
      } else {
        print('⚠️ No placemarks found for coordinates');
      }
    } catch (e) {
      print('❌ Geocoding error: $e');
      print('📍 Using coordinates as fallback: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}');
      // Return coordinates as fallback
      return '${lat.toStringAsFixed(4)}°N, ${lon.toStringAsFixed(4)}°E';
    }
    return 'Unknown Location';
  }
}

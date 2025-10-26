import 'package:huawei_location/huawei_location.dart' as hms;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  final _client = hms.FusedLocationProviderClient();

  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    }
    // For background if needed
    if (await Permission.locationAlways.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<hms.Location?> getLastLocation() async {
    return _client.getLastLocation();
  }

  Future<hms.Location?> getUserLocation() async {
    final ok = await requestPermission();
    if (!ok) return null;
    try {
      final last = await _client.getLastLocation();
      return last;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getCityName(double lat, double lon) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      if (p.locality != null && p.locality!.isNotEmpty) return p.locality;
      return p.administrativeArea;
    } catch (_) {
      return null;
    }
  }
}

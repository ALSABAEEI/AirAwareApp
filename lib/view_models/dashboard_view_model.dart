import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  int _airQualityLevel = 0; // 0 good, 1 moderate, 2 poor
  int get airQualityLevel => _airQualityLevel;

  void setAirQualityLevel(int level) {
    final clamped = level.clamp(0, 2);
    if (clamped == _airQualityLevel) return;
    _airQualityLevel = clamped;
    notifyListeners();
  }
}

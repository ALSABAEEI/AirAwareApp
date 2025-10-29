import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/feature_builder.dart';
import '../services/prediction_service.dart';

class HourSuitability {
  final DateTime time;
  final Map<String, double> percents; // activity -> 0..100
  HourSuitability(this.time, this.percents);
}

class ActivityHourlyViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();
  final _predictor = PredictionService.instance;

  // Today and tomorrow lists
  List<HourSuitability> today = [];
  List<HourSuitability> tomorrow = [];
  String? cityName;
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final weather = await _api.fetchWeatherForCurrentLocation();
      if (weather == null) {
        throw Exception('Could not fetch weather for current location');
      }
      cityName = weather['city_name'];
      final hourly = (weather['hourly'] as List).cast<Map<String, dynamic>>();

      // Build two buckets: today (same day) and tomorrow (next day)
      final now = DateTime.now();
      final endToday = DateTime(now.year, now.month, now.day, 23, 59);

      final t1 = <HourSuitability>[];
      final t2 = <HourSuitability>[];

      for (final h in hourly) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          ((h['dt'] ?? 0) as int) * 1000,
          isUtc: true,
        ).toLocal();
        final feats = FeatureBuilder.fromApiHour({
          'temperature': (h['temp'] as num?)?.toDouble() ?? 0.0,
          'uv_index': (h['uvi'] as num?)?.toDouble() ?? 0.0,
          'humidity': h['humidity'] ?? 0,
          'wind_speed': (h['wind_speed'] as num?)?.toDouble() ?? 0.0,
          'rain_chance': ((h['pop'] as num?)?.toDouble() ?? 0.0) * 100.0,
        });

        final out = await _predictor.predict(feats);
        if (out.length < 6) continue;
        // Build activity map using declared output order
        final labels = _predictor.outputOrder;
        final map = <String, double>{};
        for (int i = 0; i < 6 && i < out.length && i < labels.length; i++) {
          map[labels[i]] = out[i].clamp(0, 100);
        }
        final item = HourSuitability(dt, map);
        if (dt.isBefore(endToday)) {
          t1.add(item);
        } else {
          t2.add(item);
        }
      }

      today = t1;
      tomorrow = t2;
      loading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }
}

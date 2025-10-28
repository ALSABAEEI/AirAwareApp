class FeatureBuilder {
  // Expected order from the model spec
  static List<double> fromApiHour(Map<String, dynamic> hour) {
    final temperature =
        (hour['temperature'] as num?)?.toDouble() ??
        (hour['temp'] as num?)?.toDouble() ??
        0.0;
    final uv =
        (hour['uv_index'] as num?)?.toDouble() ??
        (hour['uvi'] as num?)?.toDouble() ??
        0.0;
    final humidity = (hour['humidity'] as num?)?.toDouble() ?? 0.0;
    final wind = (hour['wind_speed'] as num?)?.toDouble() ?? 0.0;
    // rain_chance could be provided directly or via OpenWeather 'pop' (0..1)
    double rainChance = 0.0;
    if (hour.containsKey('rain_chance')) {
      rainChance = (hour['rain_chance'] as num).toDouble();
    } else if (hour['pop'] != null) {
      rainChance = (hour['pop'] as num).toDouble() * 100.0;
    }
    return [temperature, uv, humidity, wind, rainChance];
  }
}

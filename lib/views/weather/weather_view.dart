import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? weatherData;
  bool loading = true;
  String? error;
  int selectedHours = 0; // 0 means current weather

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await apiService.fetchWeatherForHour(selectedHours);
      if (data != null) {
        setState(() {
          weatherData = data;
          loading = false;
        });
      } else {
        setState(() {
          error = 'Could not get weather for current location';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _onHourChanged(int newHour) {
    setState(() {
      selectedHours = newHour;
    });
    _getWeather();
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final forecastTime = currentTime.add(Duration(hours: selectedHours));

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
                ? Text('Error: $error', style: const TextStyle(color: Colors.red))
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⏰ Forecast Time',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                selectedHours == 0
                                    ? 'Current Weather'
                                    : 'In $selectedHours ${selectedHours == 1 ? 'hour' : 'hours'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '📅 ${_formatDateTime(forecastTime)}',
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '⚡ OpenWeather provides 48 hours of accurate forecast',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: selectedHours.toDouble(),
                                      min: 0,
                                      max: 48,
                                      divisions: 48,
                                      label: selectedHours == 0 ? 'Now' : '+$selectedHours hrs',
                                      onChanged: (value) {
                                        _onHourChanged(value.toInt());
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      selectedHours == 0 ? 'Now' : '+$selectedHours hrs',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [0, 1, 3, 6, 12, 24, 48].map((hours) {
                                  return ChoiceChip(
                                    label: Text(hours == 0 ? 'Now' : '+$hours hrs'),
                                    selected: selectedHours == hours,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _onHourChanged(hours);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      if (weatherData!['city_name'] != null)
                        _info('📍 Location', weatherData!['city_name']),
                      // Coordinates and source intentionally hidden from UI per request
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '🌤️ Weather Conditions',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (weatherData!['weather_main'] != null)
                        _infoCard(
                          '🌈 Condition',
                          '${weatherData!['weather_main']}',
                          subtitle: weatherData!['weather_description'] ?? '',
                          color: Colors.blue.shade50,
                        ),
                      _infoCard(
                        '🌡️ Temperature',
                        '${weatherData!['temperature']?.toStringAsFixed(1)} °C',
                        subtitle: weatherData!['feels_like'] != null ? 'Feels like ${weatherData!['feels_like']?.toStringAsFixed(1)} °C' : null,
                        color: Colors.orange.shade50,
                      ),
                      _infoCard(
                        '☀️ UV Index',
                        '${weatherData!['uv_index']?.toStringAsFixed(1)}',
                        subtitle: _getUVDescription(weatherData!['uv_index']),
                        color: Colors.yellow.shade50,
                      ),
                      _info('💧 Humidity', '${weatherData!['humidity']} %'),
                      _info('🌬️ Wind Speed', '${weatherData!['wind_speed']?.toStringAsFixed(1)} m/s'),
                      if (weatherData!['is_current'] == true)
                        _infoCard(
                          '💧 Precipitation',
                          weatherData!['precipitation'] > 0 ? '${weatherData!['precipitation']?.toStringAsFixed(2)} mm/h' : 'No precipitation',
                          subtitle: 'Real-time data',
                          color: Colors.blue.shade50,
                        )
                      else if (weatherData!['rain_chance'] != null)
                        _infoCard(
                          '🌧️ Rain Forecast',
                          '${weatherData!['rain_chance']?.toStringAsFixed(0)}% chance',
                          subtitle: weatherData!['precipitation'] > 0 ? 'Expected: ${weatherData!['precipitation']?.toStringAsFixed(2)} mm/h' : null,
                          color: Colors.lightBlue.shade50,
                        ),
                      if (weatherData!['clouds'] != null)
                        _info('☁️ Cloud Coverage', '${weatherData!['clouds']} %'),
                      if (weatherData!['visibility'] != null)
                        _info('👁️ Visibility', '${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km'),
                      if (weatherData!['pressure'] != null)
                        _info('🌡️ Pressure', '${weatherData!['pressure']} hPa'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _getWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '✨ All data from OpenWeather API',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[dateTime.weekday - 1];
    final monthName = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$dayName, $monthName ${dateTime.day}, ${dateTime.year} at $hour:$minute';
  }

  String _getUVDescription(dynamic uvIndex) {
    if (uvIndex == null) return 'Unknown';
    final uv = (uvIndex as num).toDouble();
    if (uv <= 2) return 'Low - Safe';
    if (uv <= 5) return 'Moderate - Caution';
    if (uv <= 7) return 'High - Protection needed';
    if (uv <= 10) return 'Very High - Extra protection';
    return 'Extreme - Avoid sun';
  }

  Widget _info(String title, String value) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      );

  Widget _infoCard(String title, String value, {String? subtitle, Color? color}) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: color,
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
            ],
          ),
        ),
      );
}



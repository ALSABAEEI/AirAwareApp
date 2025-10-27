import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeatherTestScreen extends StatefulWidget {
  const WeatherTestScreen({super.key});

  @override
  State<WeatherTestScreen> createState() => _WeatherTestScreenState();
}

class _WeatherTestScreenState extends State<WeatherTestScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? weatherData;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    try {
      // CHANGED: Use current location instead of hardcoded coordinates
      final data = await apiService.fetchWeatherForCurrentLocation();
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather API Test')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
                ? Text('Error: $error', style: const TextStyle(color: Colors.red))
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // ADD: Location information section
                      if (weatherData!['city_name'] != null)
                        _info('�� Location', weatherData!['city_name']),
                      if (weatherData!['latitude'] != null && weatherData!['longitude'] != null)
                        _info('��️ Coordinates', '${weatherData!['latitude']?.toStringAsFixed(4)}, ${weatherData!['longitude']?.toStringAsFixed(4)}'),
                      if (weatherData!['location_source'] != null)
                        _info('📡 Source', weatherData!['location_source']),
                      const Divider(),
                      // Existing weather data
                      _info('🌡 Temperature', '${weatherData!['temperature']} °C'),
                      _info('☀ UV Index', '${weatherData!['uv_index']}'),
                      _info('💧 Humidity', '${weatherData!['humidity']} %'),
                      _info('🌬 Wind Speed', '${weatherData!['wind_speed']} m/s'),
                      _info('🌧 Rain Chance', '${weatherData!['rain_chance']} %'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _getWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _info(String title, String value) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      );
}

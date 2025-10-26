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
      const lat = 3.139; // Kuala Lumpur
      const lon = 101.6869;
      final data = await apiService.fetchWeather(lat, lon);
      setState(() {
        weatherData = data;
        loading = false;
      });
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

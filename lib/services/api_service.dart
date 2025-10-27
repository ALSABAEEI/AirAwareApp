import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_service.dart';

class ApiService {
  final String _apiKey = 'ce2b307f42afeb9ba84bd4836d76bb17'; // Replace with your OpenWeather key

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/3.0/onecall'
        '?lat=$lat&lon=$lon'
        '&units=metric'
        '&exclude=minutely,hourly,alerts'
        '&appid=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    return {
      'temperature': data['current']['temp'],
      'uv_index': data['current']['uvi'],
      'humidity': data['current']['humidity'],
      'wind_speed': data['current']['wind_speed'],
      'rain_chance': (data['daily'][0]['pop'] ?? 0) * 100,
    };
  }

  // Fetch weather for current location
  Future<Map<String, dynamic>?> fetchWeatherForCurrentLocation() async {
    try {
      final locationService = LocationService();
      
      // Get user's current location
      final location = await locationService.getUserLocation();
      
      if (location == null) {
        print('❌ Could not get current location for weather');
        return null;
      }
      
      final lat = location['latitude']!;
      final lon = location['longitude']!;
      
      print('🌤️ Fetching weather for location: $lat, $lon');
      
      // Fetch weather data using coordinates
      final weatherData = await fetchWeather(lat, lon);
      
      // Add location info to weather data
      weatherData['latitude'] = lat;
      weatherData['longitude'] = lon;
      weatherData['location_source'] = locationService.lastLocationSource;
      
      // Get city name
      final cityName = await locationService.getCityName(lat, lon);
      weatherData['city_name'] = cityName;
      
      print('✅ Weather data fetched successfully for ${cityName ?? 'Unknown City'}');
      
      return weatherData;
    } catch (e) {
      print('❌ Error fetching weather for current location: $e');
      return null;
    }
  }
}

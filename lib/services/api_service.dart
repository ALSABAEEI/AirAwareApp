import 'dart:convert';
import 'package:http/http.dart' as http;

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
}

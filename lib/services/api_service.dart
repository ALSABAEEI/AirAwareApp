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
        '&exclude=minutely,alerts'
        '&appid=$_apiKey';

    print('🌐 Calling OpenWeather API: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      print('❌ API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load weather: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    print('✅ API Response received successfully');

    // Return full data structure for better processing
    return {
      'current': data['current'],
      'hourly': data['hourly'],
      'daily': data['daily'],
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

  // Fetch weather for current location at specific hour offset
  Future<Map<String, dynamic>?> fetchWeatherForHour(int hourOffset) async {
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
      
      print('🌤️ Fetching weather for location: $lat, $lon (hour offset: $hourOffset)');
      
      // Fetch weather data using coordinates
      final weatherData = await fetchWeather(lat, lon);
      
      // Extract data for specific hour
      Map<String, dynamic> result;
      
      if (hourOffset == 0) {
        // Current weather - use real-time current data
        final current = weatherData['current'];
        
        // Get actual precipitation data if available
        double precipitation = 0.0;
        if (current['rain'] != null && current['rain']['1h'] != null) {
          precipitation = (current['rain']['1h'] as num).toDouble();
        } else if (current['snow'] != null && current['snow']['1h'] != null) {
          precipitation = (current['snow']['1h'] as num).toDouble();
        }
        
        result = {
          'temperature': (current['temp'] as num).toDouble(),
          'feels_like': (current['feels_like'] as num).toDouble(),
          'uv_index': (current['uvi'] as num).toDouble(),
          'humidity': current['humidity'],
          'wind_speed': (current['wind_speed'] as num).toDouble(),
          'precipitation': precipitation, // Actual precipitation in mm
          'weather_description': current['weather'][0]['description'] ?? 'Unknown',
          'weather_main': current['weather'][0]['main'] ?? 'Unknown',
          'clouds': current['clouds'], // Cloud coverage percentage
          'visibility': current['visibility'], // Visibility in meters
          'pressure': current['pressure'], // Atmospheric pressure in hPa
          'is_current': true,
        };
        
        print('📊 Current Weather Data:');
        print('   Temperature: ${result['temperature']}°C (Feels like: ${result['feels_like']}°C)');
        print('   Condition: ${result['weather_main']} - ${result['weather_description']}');
        print('   Humidity: ${result['humidity']}%');
        print('   UV Index: ${result['uv_index']}');
        print('   Wind Speed: ${result['wind_speed']} m/s');
        print('   Precipitation: ${result['precipitation']} mm/h');
        
      } else {
        // Hourly forecast - use accurate hourly data
        final hourlyData = weatherData['hourly'] as List;
        
        if (hourOffset >= hourlyData.length) {
          print('⚠️ Hour offset $hourOffset is out of range (max: ${hourlyData.length - 1})');
          print('   OpenWeather provides 48 hours of forecast data');
          return null;
        }
        
        final hourData = hourlyData[hourOffset];
        
        // Get actual precipitation data
        double precipitation = 0.0;
        if (hourData['rain'] != null && hourData['rain']['1h'] != null) {
          precipitation = (hourData['rain']['1h'] as num).toDouble();
        } else if (hourData['snow'] != null && hourData['snow']['1h'] != null) {
          precipitation = (hourData['snow']['1h'] as num).toDouble();
        }
        
        // Get probability of precipitation (POP) - this is accurate for hourly
        double rainChance = 0.0;
        if (hourData['pop'] != null) {
          rainChance = (hourData['pop'] as num).toDouble() * 100;
        }
        
        result = {
          'temperature': (hourData['temp'] as num).toDouble(),
          'feels_like': (hourData['feels_like'] as num).toDouble(),
          'uv_index': (hourData['uvi'] as num).toDouble(),
          'humidity': hourData['humidity'],
          'wind_speed': (hourData['wind_speed'] as num).toDouble(),
          'rain_chance': rainChance, // Probability of precipitation
          'precipitation': precipitation, // Actual precipitation amount in mm
          'weather_description': hourData['weather'][0]['description'] ?? 'Unknown',
          'weather_main': hourData['weather'][0]['main'] ?? 'Unknown',
          'clouds': hourData['clouds'], // Cloud coverage percentage
          'visibility': hourData['visibility'] ?? 10000, // Visibility in meters
          'pressure': hourData['pressure'], // Atmospheric pressure in hPa
          'is_current': false,
        };
        
        print('📊 Forecast for +$hourOffset hour(s):');
        print('   Temperature: ${result['temperature']}°C (Feels like: ${result['feels_like']}°C)');
        print('   Condition: ${result['weather_main']} - ${result['weather_description']}');
        print('   Rain Chance: ${result['rain_chance']}%');
        print('   Precipitation: ${result['precipitation']} mm/h');
      }
      
      // Add location info
      result['latitude'] = lat;
      result['longitude'] = lon;
      result['location_source'] = locationService.lastLocationSource;
      
      // Get city name
      final cityName = await locationService.getCityName(lat, lon);
      result['city_name'] = cityName;
      
      print('✅ Weather data processed successfully for ${cityName ?? 'Unknown City'}');
      
      return result;
    } catch (e, stackTrace) {
      print('❌ Error fetching weather for specific hour: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}

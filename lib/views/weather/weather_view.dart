import 'dart:ui';
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
      appBar: AppBar(
        title: const Text('Weather',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCCDEFF), Color(0xFFEFF5FF), Colors.white],
          ),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : error != null
                  ? Text('Error: $error',
                      style: const TextStyle(color: Colors.red))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 44),
                      children: [
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⏰ Forecast Time',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '⚡ Forecast preview limited to 24 hours',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 12),
                              _HourSegments(
                                selected: selectedHours,
                                onChanged: _onHourChanged,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor:
                                            const Color(0xFF3C6CFF),
                                        inactiveTrackColor:
                                            const Color(0xFF3C6CFF)
                                                .withOpacity(0.25),
                                        thumbColor: const Color(0xFF3C6CFF),
                                        overlayColor: const Color(0xFF3C6CFF)
                                            .withOpacity(0.15),
                                      ),
                                      child: Slider(
                                        value: selectedHours.toDouble(),
                                        min: 0,
                                        max: 24,
                                        divisions: 24,
                                        label: selectedHours == 0
                                            ? 'Now'
                                            : '+$selectedHours hrs',
                                        onChanged: (value) =>
                                            _onHourChanged(value.toInt()),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      selectedHours == 0
                                          ? 'Now'
                                          : '+$selectedHours hrs',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (weatherData!['city_name'] != null)
                          _GlassCard(
                            child: _infoRow(
                                '📍 Location', weatherData!['city_name']),
                          ),
                        const SizedBox(height: 12),
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🌤️ Conditions',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (weatherData!['weather_main'] != null)
                                _tile(
                                    icon: Icons.wb_cloudy_rounded,
                                    title: 'Condition',
                                    value: '${weatherData!['weather_main']}',
                                    subtitle:
                                        weatherData!['weather_description'] ??
                                            ''),
                              _tile(
                                  icon: Icons.thermostat_rounded,
                                  title: 'Temperature',
                                  value:
                                      '${weatherData!['temperature']?.toStringAsFixed(1)} °C',
                                  subtitle: weatherData!['feels_like'] != null
                                      ? 'Feels like ${weatherData!['feels_like']?.toStringAsFixed(1)} °C'
                                      : null),
                              _tile(
                                  icon: Icons.wb_sunny_rounded,
                                  title: 'UV Index',
                                  value:
                                      '${weatherData!['uv_index']?.toStringAsFixed(1)}',
                                  subtitle: _getUVDescription(
                                      weatherData!['uv_index'])),
                              _tile(
                                  icon: Icons.water_drop_rounded,
                                  title: 'Humidity',
                                  value: '${weatherData!['humidity']} %'),
                              _tile(
                                  icon: Icons.air_rounded,
                                  title: 'Wind Speed',
                                  value:
                                      '${weatherData!['wind_speed']?.toStringAsFixed(1)} m/s'),
                              if (weatherData!['is_current'] == true)
                                _tile(
                                    icon: Icons.grain_rounded,
                                    title: 'Precipitation',
                                    value: weatherData!['precipitation'] > 0
                                        ? '${weatherData!['precipitation']?.toStringAsFixed(2)} mm/h'
                                        : 'No precipitation',
                                    subtitle: 'Real-time data')
                              else if (weatherData!['rain_chance'] != null)
                                _tile(
                                    icon: Icons.umbrella_rounded,
                                    title: 'Rain Forecast',
                                    value:
                                        '${weatherData!['rain_chance']?.toStringAsFixed(0)}% chance',
                                    subtitle: weatherData!['precipitation'] > 0
                                        ? 'Expected: ${weatherData!['precipitation']?.toStringAsFixed(2)} mm/h'
                                        : null),
                              if (weatherData!['clouds'] != null)
                                _tile(
                                    icon: Icons.cloud_queue_rounded,
                                    title: 'Cloud Coverage',
                                    value: '${weatherData!['clouds']} %'),
                              if (weatherData!['visibility'] != null)
                                _tile(
                                    icon: Icons.remove_red_eye_rounded,
                                    title: 'Visibility',
                                    value:
                                        '${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km'),
                              if (weatherData!['pressure'] != null)
                                _tile(
                                    icon: Icons.speed_rounded,
                                    title: 'Pressure',
                                    value: '${weatherData!['pressure']} hPa'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _getWeather,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '✨ All data from OpenWeather API',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
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

  // Old card helpers were replaced by glass tiles; intentionally removed.

  Widget _infoRow(String title, String value) => Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _tile(
      {required IconData icon,
      required String title,
      required String value,
      String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _HourSegments extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _HourSegments({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [0, 1, 3, 6, 12, 24];
    const brand = Color(0xFF3C6CFF);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (i) {
          final h = options[i];
          final bool isFirst = i == 0;
          final bool isLast = i == options.length - 1;
          final bool isSelected = h == selected;
          final BorderRadius radius = BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(16) : Radius.zero,
            right: isLast ? const Radius.circular(16) : Radius.zero,
          );
          return Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 8),
            decoration: BoxDecoration(
              color: isSelected ? brand : Colors.white.withOpacity(0.7),
              borderRadius: radius,
              border: Border.all(color: isSelected ? brand : Colors.black12),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: () => onChanged(h),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  h == 0 ? 'Now' : '+${h}h',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

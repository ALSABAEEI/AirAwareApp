import 'package:flutter/material.dart';
import 'dart:math';

// Data model for our hourly forecast
class HourlyForecast {
  final String time;
  final int aqi; // Fake AQI value
  final double recommendation; // 0.0 to 1.0

  HourlyForecast({required this.time, required this.aqi, required this.recommendation});
}

class ActivityDetailView extends StatefulWidget {
  final String activityTitle;
  final IconData activityIcon;
  final Color iconBackground;

  const ActivityDetailView({
    super.key,
    required this.activityTitle,
    required this.activityIcon,
    required this.iconBackground,
  });

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<HourlyForecast> _todayForecast;
  late final List<HourlyForecast> _tomorrowForecast;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _todayForecast = _generateFakeForecast(DateTime.now());
    _tomorrowForecast = _generateFakeForecast(DateTime.now().add(const Duration(days: 1)), isTomorrow: true);
  }

  // Generates 12 hours of fake data
  List<HourlyForecast> _generateFakeForecast(DateTime startTime, {bool isTomorrow = false}) {
    final random = Random();
    final forecasts = <HourlyForecast>[];
    int startHour = isTomorrow ? 7 : startTime.hour; // Start tomorrow at 7 AM

    for (int i = 0; i < 12; i++) {
      final hour = (startHour + i) % 24;
      final ampm = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final recommendation = random.nextDouble() * 0.8 + 0.1; // Skew towards decent recommendations

      forecasts.add(HourlyForecast(
        time: '$displayHour:00 $ampm',
        aqi: random.nextInt(150),
        recommendation: recommendation,
      ));
    }
    return forecasts;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.activityTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.iconBackground.withOpacity(0.8),
              widget.iconBackground.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(widget.activityIcon, color: widget.iconBackground, size: 40),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 16),
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Tomorrow'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ForecastList(forecasts: _todayForecast),
                    _ForecastList(forecasts: _tomorrowForecast),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForecastList extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const _ForecastList({required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: forecasts.length,
      itemBuilder: (context, index) {
        return _HourlyForecastRow(forecast: forecasts[index]);
      },
    );
  }
}

class _HourlyForecastRow extends StatelessWidget {
  final HourlyForecast forecast;
  const _HourlyForecastRow({required this.forecast});

  Color _getBarColor(double recommendation) {
    if (recommendation > 0.75) return Colors.green.shade400;
    if (recommendation > 0.4) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentText = '${(forecast.recommendation * 100).round()}%';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              forecast.time,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: forecast.recommendation,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: _getBarColor(forecast.recommendation),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  percentText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

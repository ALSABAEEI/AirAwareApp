import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF3C6CFF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirAware',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Color(0xFFEAF6F6)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(theme: theme),
                const SizedBox(height: 20),
                _RecommendationsCard(),
                const SizedBox(height: 20),
                // Activity cards grid
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.92,
                  ),
                  children: const [
                    ActivityCard(
                      icon: Icons.directions_run_rounded,
                      iconBackground: Color(0xFF2BB0ED),
                      title: 'Jogging',
                      percent: 0.85,
                      barColor: Color(0xFF2BB673),
                    ),
                    ActivityCard(
                      icon: Icons.pool_rounded,
                      iconBackground: Color(0xFF2D7FF9),
                      title: 'Swimming',
                      percent: 0.92,
                      barColor: Color(0xFF1AA27A),
                    ),
                    ActivityCard(
                      icon: Icons.pedal_bike_rounded,
                      iconBackground: Color(0xFFFF8C1A),
                      title: 'Cycling',
                      percent: 0.55,
                      barColor: Color(0xFFFF9D1E),
                    ),
                    ActivityCard(
                      icon: Icons.sports_soccer_rounded,
                      iconBackground: Color(0xFFE83C3C),
                      title: 'Football',
                      percent: 0.25,
                      barColor: Color(0xFFFF6275),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'AirAware',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF3152FF),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF6B5CF6),
              ),
              tooltip: 'Notifications',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.place_outlined, color: Color(0xFF6B5CF6)),
              tooltip: 'Location',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Exercise Prediction Dashboard',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Exercise\nRecommendations",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Based on current air quality conditions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.percent,
    required this.barColor,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final double percent; // 0.0 - 1.0
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentText = '${(percent * 100).round()}%';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: iconBackground.withOpacity(0.15),
            child: Icon(icon, color: iconBackground, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                percentText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProgressBar(value: percent, color: barColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final filledWidth = width * value.clamp(0, 1);
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: filledWidth,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }
}

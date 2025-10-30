import 'package:flutter/material.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AirAwareApp());
}

// MVVM entry now lives in app/app.dart; this file only boots the app.

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // In a later step, tie this to real AQI data
  // 0 = good (green), 1 = moderate (orange), 2 = poor (red)
  int airQualityLevel = 0;

  late final AnimationController _bgController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  List<Color> _baseGradientForLevel(int level) {
    switch (level) {
      case 2:
        return const [Color(0xFF8B0000), Color(0xFFFFFFFF)]; // soft red tint
      case 1:
        return const [Color(0xFFFFA500), Color(0xFFFFFFFF)]; // soft orange tint
      case 0:
      default:
        return const [Color(0xFF00008B), Color(0xFFFFFFFF)]; // soft blue/clear
    }
  }

  List<Color> _secondaryGradientForLevel(int level) {
    switch (level) {
      case 2:
        return const [Color(0xFFDC143C), Color(0xFFFFFFFF)];
      case 1:
        return const [Color(0xFFFFD700), Color(0xFFFFFFFF)];
      case 0:
      default:
        return const [Color(0xFFADD8E6), Color(0xFFFFFFFF)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = _baseGradientForLevel(airQualityLevel);
    final alt = _secondaryGradientForLevel(airQualityLevel);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_bgController.value);
          final c0 = Color.lerp(base[0], alt[0], t)!;
          final c1 = Color.lerp(base[1], alt[1], t)!;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c0, c1],
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
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          title: 'aming',
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
          );
        },
      ),
    );
  }
}

// Profile page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFF3C6CFF),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'A. User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Runner • AirAware Member',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileCard(
              title: 'Health Metrics',
              children: const [
                _ProfileRow(label: 'Age', value: '26'),
                _ProfileRow(label: 'Height', value: '178 cm'),
                _ProfileRow(label: 'Weight', value: '72 kg'),
                _ProfileRow(label: 'Allergies', value: 'None'),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileCard(
              title: 'Preferences',
              children: const [
                _ProfileRow(label: 'Jogging Window', value: '6:00 – 8:00 AM'),
                _ProfileRow(label: 'Units', value: 'Metric'),
                _ProfileRow(label: 'Notifications', value: 'Enabled'),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileCard(
              title: 'Connected Services',
              children: const [
                _ProfileRow(label: 'Location', value: 'Allowed'),
                _ProfileRow(label: 'Huawei Health', value: 'Connected'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black87)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF1FF), Color(0xFFDDEBFF)], // subtle cool tint
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
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
              _IconChip(
                icon: Icons.notifications_none_rounded,
                color: const Color(0xFF6B5CF6),
                tooltip: 'Notifications',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _IconChip(
                icon: Icons.place_outlined,
                color: const Color(0xFF6B5CF6),
                tooltip: 'Location',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Exercise Prediction Dashboard',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5E6B87),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatefulWidget {
  const _IconChip({
    required this.icon,
    required this.color,
    this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  State<_IconChip> createState() => _IconChipState();
}

class _IconChipState extends State<_IconChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    reverseDuration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.08, // scale down up to 8%
  );

  bool _hovering = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    final baseShadow = BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    );

    Widget chip = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapCancel: () => _controller.reverse(),
        onTapUp: (_) => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 1 - _controller.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              transform: Matrix4.identity()..scale(scale, scale),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _hovering ? Colors.white : Colors.white,
                borderRadius: borderRadius,
                border: Border.all(
                  color: widget.color.withOpacity(_hovering ? 0.25 : 0.15),
                ),
                boxShadow: [
                  baseShadow,
                  if (_hovering)
                    BoxShadow(
                      color: widget.color.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Icon(widget.icon, color: widget.color),
            );
          },
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      chip = Tooltip(message: widget.tooltip!, child: chip);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(color: Colors.transparent, child: chip),
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

class ActivityCard extends StatefulWidget {
  const ActivityCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.percent,
    required this.barColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final double percent; // 0.0 - 1.0
  final Color barColor;
  final VoidCallback? onTap;

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    reverseDuration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.06,
  );

  bool _hovering = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentText = '${(widget.percent * 100).round()}%';
    final borderRadius = BorderRadius.circular(22);
    final baseShadow = BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 8),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapCancel: () => _controller.reverse(),
        onTapUp: (_) => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 1 - _controller.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.identity()..scale(scale, scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
                boxShadow: [
                  baseShadow,
                  if (_hovering)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: widget.iconBackground.withOpacity(0.15),
                    child: Icon(
                      widget.icon,
                      color: widget.iconBackground,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
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
                        child: _ProgressBar(
                          value: widget.percent,
                          color: widget.barColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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

// Simple notifications screen placeholder
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _NotificationTile(
              icon: Icons.air_rounded,
              color: const Color(0xFF2BB673),
              title: 'Air quality is excellent for jogging',
              subtitle: 'Best time: 6:00–8:00 AM',
            ),
            const SizedBox(height: 12),
            _NotificationTile(
              icon: Icons.wb_sunny_outlined,
              color: const Color(0xFFFFA726),
              title: 'UV Index rising by noon',
              subtitle: 'Consider indoor workouts 12:00–15:00',
            ),
            const SizedBox(height: 12),
            _NotificationTile(
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFEF5350),
              title: 'Air quality alert in your area',
              subtitle: 'Avoid intense outdoor activities',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.settings_outlined),
        label: const Text('Preferences'),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

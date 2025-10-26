import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../detail/activity_detail_view.dart';
import '../../services/location_service.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../widgets/header.dart';
import '../../widgets/recommend_card.dart';
import '../../widgets/activity_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto-run the first-time flow: request permission and fetch location → show city
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().initialize(LocationService());
    });
  }

  List<Color> _baseGradientForLevel(int level) {
    switch (level) {
      case 2:
        return const [Color(0xFFF87671), Color(0xFFFFFFFF)]; // Salmon Red
      case 1:
        return const [Color(0xFFFFAA4C), Color(0xFFFFFFFF)]; // Amber
      case 0:
      default:
        return const [Color(0xFF43C6AC), Color(0xFFFFFFFF)]; // Light Teal
    }
  }

  List<Color> _secondaryGradientForLevel(int level) {
    switch (level) {
      case 2:
        return const [
          Color(0xFFFFD1D1),
          Color(0xFFFFFFFF),
        ]; // Light Pinkish Red
      case 1:
        return const [Color(0xFFFFE5B4), Color(0xFFFFFFFF)]; // Light Peach
      case 0:
      default:
        return const [Color(0xFFB8F2E6), Color(0xFFFFFFFF)]; // Pale Teal/Mint
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final level = vm.airQualityLevel;
    final base = _baseGradientForLevel(level);
    final alt = _secondaryGradientForLevel(level);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Header(),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: RecommendCard(),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<DashboardViewModel>()
                                .refreshWithCurrentLocation(LocationService()),
                            icon: const Icon(Icons.my_location),
                            label: const Text('Use my location'),
                          ),
                          const SizedBox(width: 12),
                          if (vm.cityName != null)
                            Text(
                              vm.cityName!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (vm.lastLatitude != null)
                            Text(
                              '(${vm.lastLatitude!.toStringAsFixed(4)}, ${vm.lastLongitude!.toStringAsFixed(4)})',
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: _Grid(),
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

class _Grid extends StatelessWidget {
  const _Grid();

  void _navigateToDetail(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityDetailView(
          activityTitle: title,
          activityIcon: icon,
          iconBackground: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      children: [
        ActivityCard(
          icon: Icons.directions_run_rounded,
          iconBackground: const Color(0xFF50C878), // Emerald Green
          title: 'Jogging',
          onTap: () => _navigateToDetail(
            context,
            'Jogging',
            Icons.directions_run_rounded,
            const Color(0xFF50C878),
          ),
        ),
        ActivityCard(
          icon: Icons.pool_rounded,
          iconBackground: const Color(0xFF4682B4), // Steel Blue
          title: 'Swimming',
          onTap: () => _navigateToDetail(
            context,
            'Swimming',
            Icons.pool_rounded,
            const Color(0xFF4682B4),
          ),
        ),
        ActivityCard(
          icon: Icons.pedal_bike_rounded,
          iconBackground: const Color(0xFFFF7F50), // Coral
          title: 'Bike',
          onTap: () => _navigateToDetail(
            context,
            'Bike',
            Icons.pedal_bike_rounded,
            const Color(0xFFFF7F50),
          ),
        ),
        ActivityCard(
          icon: Icons.sports_soccer_rounded,
          iconBackground: const Color(0xFF6A5ACD), // Slate Blue
          title: 'Football',
          onTap: () => _navigateToDetail(
            context,
            'Football',
            Icons.sports_soccer_rounded,
            const Color(0xFF6A5ACD),
          ),
        ),
        ActivityCard(
          icon: Icons.directions_walk_rounded,
          iconBackground: const Color(0xFF8A9A5B), // Sage Green
          title: 'Walking',
          onTap: () => _navigateToDetail(
            context,
            'Walking',
            Icons.directions_walk_rounded,
            const Color(0xFF8A9A5B),
          ),
        ),
        ActivityCard(
          icon: Icons.hiking_rounded,
          iconBackground: const Color(0xFF967969), // Woodsy Brown
          title: 'Hiking',
          onTap: () => _navigateToDetail(
            context,
            'Hiking',
            Icons.hiking_rounded,
            const Color(0xFF967969),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../detail/activity_detail_view.dart';
import 'package:provider/provider.dart';
import '../../view_models/activity_hourly_view_model.dart';
import '../../services/location_service.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../widgets/header.dart';
import '../../widgets/recommend_card.dart';
import '../../widgets/activity_card.dart';
import '../../screens/weather_test_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<DashboardViewModel>();
      await vm.initialize(LocationService());
      
      // After initialization, check if we need to show location prompt
      if (mounted && vm.needsLocationPrompt) {
        _showLocationDialog();
      }
    });
  }
  
  void _showLocationDialog() async {
    final vm = context.read<DashboardViewModel>();
    
    showDialog(
      context: context,
      barrierDismissible: false, // User must respond
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                vm.isLocationServiceEnabled 
                  ? Icons.location_off 
                  : Icons.gps_off,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Location Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!vm.isLocationServiceEnabled)
                const Text(
                  'Location services are turned off. Please enable location/GPS to use AirAware and get accurate air quality data for your area.',
                  style: TextStyle(fontSize: 15),
                )
              else
                const Text(
                  'Location permission is required to detect your current location and provide accurate air quality information.',
                  style: TextStyle(fontSize: 15),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      !vm.isLocationServiceEnabled 
                        ? '📍 Steps to enable:' 
                        : '📍 You will see options:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (!vm.isLocationServiceEnabled) ...[
                      const Text('1. Tap "Enable Location" below'),
                      const Text('2. Turn ON location/GPS'),
                      const Text('3. Return to the app'),
                    ] else ...[
                      const Text('• Allow only this time'),
                      const Text('• Allow while using the app (Recommended)'),
                      const Text('• Don\'t allow'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                vm.clearLocationPrompt();
                Navigator.pop(dialogContext);
              },
              child: const Text('Maybe Later'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                if (!vm.isLocationServiceEnabled) {
                  // Open location settings
                  await Geolocator.openLocationSettings();
                  // Wait a bit for user to enable location
                  await Future.delayed(const Duration(seconds: 1));
                  // Re-check status
                  if (mounted) {
                    await vm.checkLocationStatus();
                    // If still disabled, show dialog again
                    if (vm.needsLocationPrompt && mounted) {
                      _showLocationDialog();
                    } else if (!vm.needsLocationPrompt && mounted) {
                      // Location enabled, now get it
                      await vm.refreshWithCurrentLocation(LocationService());
                    }
                  }
                } else {
                  // Request location permission
                  final locationService = LocationService();
                  final granted = await locationService.requestPermission();
                  
                  if (granted && mounted) {
                    // Permission granted, get location
                    await vm.refreshWithCurrentLocation(locationService);
                    vm.clearLocationPrompt();
                  } else if (mounted) {
                    // Permission denied, check again
                    await vm.checkLocationStatus();
                  }
                }
              },
              icon: const Icon(Icons.check_circle),
              label: Text(
                !vm.isLocationServiceEnabled 
                  ? 'Enable Location' 
                  : 'Grant Permission'
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const WeatherTestScreen()));
        },
        icon: const Icon(Icons.cloud),
        label: const Text('Weather Test'),
        backgroundColor: Colors.blue.shade600,
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
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ActivityHourlyViewModel(),
          child: ActivityDetailView(
            activityTitle: title,
            activityIcon: icon,
            iconBackground: color,
          ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../widgets/header.dart';
import '../../widgets/recommend_card.dart';
import '../../widgets/activity_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final level = vm.airQualityLevel;
    List<Color> base;
    switch (level) {
      case 2:
        base = const [Color(0xFFFFEDEA), Color(0xFFFFFFFF)];
        break;
      case 1:
        base = const [Color(0xFFFFF3E6), Color(0xFFFFFFFF)];
        break;
      default:
        base = const [Color(0xFFEAF6FF), Color(0xFFFFFFFF)];
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // simple static choice based on VM; animated version can be added
            colors: base,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Header(),
                SizedBox(height: 20),
                RecommendCard(),
                SizedBox(height: 20),
                _Grid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid();
  @override
  Widget build(BuildContext context) {
    return GridView(
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
    );
  }
}

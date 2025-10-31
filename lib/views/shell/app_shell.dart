import 'dart:ui';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_view.dart';
import '../weather/weather_view.dart';
import 'package:provider/provider.dart';
import '../../view_models/shell_view_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _pages = const [DashboardView(), WeatherView()];

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellViewModel>();
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: shell.index, children: _pages),
      bottomNavigationBar: _GlassNavBar(
        index: shell.index,
        onChanged: (i) => shell.setIndex(i),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 4,
          top: 0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.65)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: index == 0,
                    onTap: () => onChanged(0),
                  ),
                  _NavItem(
                    icon: Icons.cloud_outlined,
                    label: 'Weather',
                    selected: index == 1,
                    onTap: () => onChanged(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF3C6CFF);
    final inactiveColor = Colors.black54;
    final color = selected ? activeColor : inactiveColor;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1.08 : 1.0,
                curve: Curves.easeOut,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 1),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
                child: Text(label),
              ),
              const SizedBox(height: 1),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: 2,
                width: selected ? 16 : 0,
                decoration: BoxDecoration(
                  color: selected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

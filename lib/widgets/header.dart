import 'package:flutter/material.dart';

import '../views/notifications/notifications_view.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF1FF), Color(0xFFDDEBFF)],
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
                      builder: (_) => const NotificationsView(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const _IconChip(
                icon: Icons.place_outlined,
                color: Color(0xFF6B5CF6),
                tooltip: 'Location',
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
    upperBound: 0.08,
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
                color: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/activity_hourly_view_model.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Kick off loading real data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityHourlyViewModel>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.iconBackground;

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
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withOpacity(0.55),
              base.withOpacity(0.25),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white.withOpacity(0.95),
                  child: Icon(
                    widget.activityIcon,
                    color: widget.iconBackground,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: widget.iconBackground,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Tomorrow'),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<ActivityHourlyViewModel>(
                  builder: (context, vm, _) {
                    if (vm.loading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (vm.error != null) {
                      return Center(
                        child: Text(
                          vm.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _ForecastList(
                          activity: widget.activityTitle,
                          items: vm.today,
                        ),
                        _ForecastList(
                          activity: widget.activityTitle,
                          items: vm.tomorrow,
                        ),
                      ],
                    );
                  },
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
  final String activity; // which activity to show
  final List<HourSuitability> items;

  const _ForecastList({required this.activity, required this.items});

  String _normalizeActivity(String name) {
    switch (name) {
      case 'Bike':
        return 'Cycling';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final h = items[index];
        final key = _normalizeActivity(activity);
        final percent = ((h.percents[key] ?? 0) / 100.0).clamp(0.0, 1.0);
        final dt = h.time;
        final hour = dt.hour;
        final ampm = hour < 12 ? 'AM' : 'PM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return _HourlyForecastRow(
          label: '$displayHour:00 $ampm',
          percent: percent,
        );
      },
    );
  }
}

class _HourlyForecastRow extends StatelessWidget {
  final String label;
  final double percent; // 0..1
  const _HourlyForecastRow({required this.label, required this.percent});

  Color _getBarColor(double recommendation) {
    if (recommendation > 0.75) return const Color(0xFF34D399); // emerald
    if (recommendation > 0.4) return const Color(0xFFF59E0B); // amber
    return const Color(0xFFEF4444); // red
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentInt = (percent * 100).round();
    final barColor = _getBarColor(percent);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [barColor.withOpacity(0.9), barColor],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$percentInt%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

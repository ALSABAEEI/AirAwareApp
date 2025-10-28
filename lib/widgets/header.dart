import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../views/notifications/notifications_view.dart';
import '../view_models/dashboard_view_model.dart';
import '../services/location_service.dart';

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
                icon: Icons.location_on,
                color: const Color(0xFF4CAF50),
                tooltip: 'Location',
                onTap: () {
                  _showLocationDialog(context);
                },
              ),
              const SizedBox(width: 8),
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

void _showLocationDialog(BuildContext context) async {
  final vm = context.read<DashboardViewModel>();
  
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  
  // Check if location permission is granted
  PermissionStatus permissionStatus = await Permission.location.status;
  
  // If location is disabled or permission not granted, handle it
  if (!serviceEnabled || !permissionStatus.isGranted) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
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
            if (!serviceEnabled)
              const Text(
                'Location services are turned off. Please enable location to use this feature.',
                style: TextStyle(fontSize: 15),
              )
            else if (permissionStatus.isPermanentlyDenied)
              const Text(
                'Location permission was permanently denied. Please enable it manually in app settings.',
                style: TextStyle(fontSize: 15),
              )
            else
              const Text(
                'Location permission is required to detect your current location and provide accurate air quality information.',
                style: TextStyle(fontSize: 15),
              ),
            const SizedBox(height: 16),
            if (!permissionStatus.isPermanentlyDenied)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 You will see options:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text('• Allow only this time'),
                    Text('• Allow while using the app'),
                    Text('• Don\'t allow'),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚙️ Steps to enable:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text('1. Open app settings'),
                    Text('2. Tap "Permissions"'),
                    Text('3. Tap "Location"'),
                    Text('4. Select your preferred option'),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Close dialog first to allow native dialogs to show
              Navigator.pop(dialogContext);
              
              if (!serviceEnabled) {
                // Open location settings
                await Geolocator.openLocationSettings();
                return;
              }
              
              if (permissionStatus.isPermanentlyDenied) {
                // Open app settings for permanently denied permission
                await openAppSettings();
                return;
              }
              
              // Request location permission - this will show Android's native dialog
              final status = await Permission.location.request();
              
              if (status.isGranted && context.mounted) {
                // Refresh location
                final locationService = LocationService();
                context.read<DashboardViewModel>()
                  .refreshWithCurrentLocation(locationService);
              }
            },
            icon: const Icon(Icons.settings),
            label: Text(
              !serviceEnabled 
                ? 'Enable Location' 
                : permissionStatus.isPermanentlyDenied
                  ? 'Open Settings'
                  : 'Grant Permission'
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    return;
  }
  
  // Location is enabled and permission granted, show location info
  final hasLocation = vm.lastLatitude != null;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasLocation ? Icons.location_on : Icons.location_off,
                  color: hasLocation ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  hasLocation ? 'Location Active' : 'Getting Location...',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (hasLocation) ...[
              if (vm.cityName != null) ...[
                _LocationInfoRow(
                  icon: Icons.location_city,
                  label: 'City',
                  value: vm.cityName!,
                ),
                const SizedBox(height: 12),
              ],
              _LocationInfoRow(
                icon: vm.locationSource.contains('HMS') 
                  ? Icons.hub 
                  : Icons.gps_fixed,
                label: 'Source',
                value: vm.locationSource,
                valueColor: vm.locationSource.contains('HMS') 
                  ? Colors.red.shade700 
                  : Colors.blue.shade700,
              ),
              const SizedBox(height: 12),
              _LocationInfoRow(
                icon: Icons.my_location,
                label: 'Latitude',
                value: vm.lastLatitude!.toStringAsFixed(6),
              ),
              const SizedBox(height: 12),
              _LocationInfoRow(
                icon: Icons.my_location,
                label: 'Longitude',
                value: vm.lastLongitude!.toStringAsFixed(6),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<DashboardViewModel>()
                      .refreshWithCurrentLocation(LocationService());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Requesting permission and fetching your location...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _LocationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _LocationInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

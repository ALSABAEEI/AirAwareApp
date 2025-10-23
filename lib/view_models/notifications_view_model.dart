import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationsViewModel extends ChangeNotifier {
  final List<NotificationItem> items = const [
    NotificationItem(
      icon: Icons.air_rounded,
      color: Color(0xFF2BB673),
      title: 'Air quality is excellent for jogging',
      subtitle: 'Best time: 6:00–8:00 AM',
    ),
    NotificationItem(
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFFFA726),
      title: 'UV Index rising by noon',
      subtitle: 'Consider indoor workouts 12:00–15:00',
    ),
    NotificationItem(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFEF5350),
      title: 'Air quality alert in your area',
      subtitle: 'Avoid intense outdoor activities',
    ),
  ];
}

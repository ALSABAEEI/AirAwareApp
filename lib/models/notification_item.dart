import 'package:flutter/material.dart';

class NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

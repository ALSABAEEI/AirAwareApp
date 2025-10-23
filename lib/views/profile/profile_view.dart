import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>().profile;
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
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Runner • AirAware Member',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _ProfileCard(
              title: 'Health Metrics',
              rows: [
                _ProfileRowDynamic(label: 'Age'),
                _ProfileRowDynamic(label: 'Height'),
                _ProfileRowDynamic(label: 'Weight'),
                _ProfileRow(label: 'Allergies', value: 'None'),
              ],
            ),
            const SizedBox(height: 16),
            const _ProfileCard(
              title: 'Preferences',
              rows: [
                _ProfileRow(label: 'Jogging Window', value: '6:00 – 8:00 AM'),
                _ProfileRow(label: 'Units', value: 'Metric'),
                _ProfileRow(label: 'Notifications', value: 'Enabled'),
              ],
            ),
            const SizedBox(height: 16),
            const _ProfileCard(
              title: 'Connected Services',
              rows: [
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
  const _ProfileCard({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

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
          ...rows,
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

class _ProfileRowDynamic extends StatelessWidget {
  const _ProfileRowDynamic({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>().profile;
    final value = switch (label) {
      'Age' => '${profile.age}',
      'Height' => '${profile.heightCm} cm',
      'Weight' => '${profile.weightKg} kg',
      _ => '-',
    };
    return _ProfileRow(label: label, value: value);
  }
}

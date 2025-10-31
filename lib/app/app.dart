import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../views/shell/app_shell.dart';
import '../view_models/shell_view_model.dart';
import '../view_models/dashboard_view_model.dart';
import '../view_models/profile_view_model.dart';

class AirAwareApp extends StatelessWidget {
  const AirAwareApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF3C6CFF);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShellViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AirAware',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AppShell(),
      ),
    );
  }
}

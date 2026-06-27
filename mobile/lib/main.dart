import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChoirdApp());
}

class ChoirdApp extends StatelessWidget {
  const ChoirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Choird',
      theme: AppTheme.light,
      home: const MainScreen(),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Transisi antar halaman memakai Shared Axis (paket `animations`).
    const transitions = SharedAxisPageTransitionsBuilder(
      transitionType: SharedAxisTransitionType.horizontal,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: transitions,
            TargetPlatform.iOS: transitions,
            TargetPlatform.linux: transitions,
            TargetPlatform.macOS: transitions,
            TargetPlatform.windows: transitions,
            TargetPlatform.fuchsia: transitions,
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

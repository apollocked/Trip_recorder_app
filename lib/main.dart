import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TripService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 1. Light Theme Definition
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF00796B),
        ),
      ),
      // 2. Dark Theme Definition
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF00796B),
        ),
      ),
      // 3. THE FIX: Force light mode to test it, or keep .system
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

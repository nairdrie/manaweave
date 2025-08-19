import 'package:flutter/material.dart';
import 'package:manaweave/theme.dart';
import 'package:manaweave/screens/home_screen.dart';

void main() {
  runApp(const ManaWeaveApp());
}

class ManaWeaveApp extends StatelessWidget {
  const ManaWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManaWeave',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

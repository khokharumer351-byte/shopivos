import 'package:flutter/material.dart';

void main() {
  runApp(const ShopivoApp());
}

class ShopivoApp extends StatelessWidget {
  const ShopivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopivo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF8F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4BDB),
        ),
      ),
      home: const ShopivoHome(),
    );
  }
}




class ShopivoHome extends StatelessWidget {
  const ShopivoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'SHOPIVO',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
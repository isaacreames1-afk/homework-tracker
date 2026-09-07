import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'home_screen.dart';

void main() {
  runApp(const HomeworkTrackerApp());
}

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3), () {
        if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const FourRotatingDotsLoadingScreen(); 
  }
}

class FourRotatingDotsLoadingScreen extends StatelessWidget {
  const FourRotatingDotsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: Colors.blue,
              size: 100.0,
            ),
          const SizedBox(height: 20),
          const Text(
            'Loading... Loading...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:toba_bersih/features/onboarding/onboarding_screen.dart'; // Sesuaikan nama package
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer 3 detik sebelum pindah ke Onboarding
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10C65C), // Warna hijau sesuai desain
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo / Ikon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.waves, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            // Judul
            const Text(
              'Toba Bersih',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Subjudul
            const Text(
              'Eco-friendly Lake Toba',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            // Progress Bar / Loading di bawah
            const Text(
              'Protecting our waters...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
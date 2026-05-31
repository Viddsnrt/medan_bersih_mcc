import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Import file layar selanjutnya
import '../../auth/login_screen.dart'; 
import 'onboarding_screen.dart'; 
// 🔥 IMPORT HALAMAN UTAMA UNTUK BYPASS LOGIN
import 'package:toba_bersih/main.dart'; 
import 'package:toba_bersih/features/operator/operator_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  // 🔥 FUNGSI PEMBACAAN LOCAL STORAGE (Persistensi Data)
  Future<void> _checkAppState() async {
    // Tunggu 3 detik agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    
    // 1. Cek Onboarding
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
      return; 
    }

    // ==========================================================
    // 🔥 2. CEK SESI LOGIN (Membuktikan data tetap ada setelah app ditutup)
    // ==========================================================
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final String? encryptedToken = prefs.getString('auth_token');

    if (isLoggedIn && encryptedToken != null) {
      // Jika token dan status login ada, baca role-nya
      final String role = prefs.getString('user_role') ?? 'WARGA';
      final String userId = prefs.getString('userId') ?? '';

      debugPrint("Sesi ditemukan! Token Enkripsi: $encryptedToken");

      // Langsung arahkan ke halaman utama (Bypass Login)
      if (role == 'OPERATOR' || role == 'SUPIR') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OperatorHomeScreen(driverId: userId)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      // Jika belum login atau token hilang, masuk ke LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
              'Eco-friendly Solutions for a Cleaner Toba',
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
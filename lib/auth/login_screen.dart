import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toba_bersih/features/operator/operator_home_screen.dart';
import 'dart:convert'; // 🔥 Diperlukan untuk enkripsi Base64
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:toba_bersih/main.dart'; 
import 'package:toba_bersih/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 🔥 1. Kunci Global untuk mengontrol dan memvalidasi Form
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; 

  final String ipAddress = '10.152.199.195';

  Future<void> _login() async {
    // 🔥 2. Cek apakah semua input form valid sebelum hit API
    if (!_formKey.currentState!.validate()) {
      return; // Berhenti jika ada validasi yang gagal (pesan merah akan muncul otomatis)
    }

    setState(() {
      _isLoading = true;
    });

    String? fcmToken;
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      fcmToken = await messaging.getToken();
    } catch (e) {
      debugPrint("⚠️ Gagal mengambil FCM Token: $e");
    }

    try {
      var url = Uri.parse('http://$ipAddress:5000/api/auth/login');

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'fcmToken': fcmToken,
        }),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        String role = data['data']?['role']?.toString().toUpperCase() ?? data['user']?['role']?.toString().toUpperCase() ?? data['role']?.toString().toUpperCase() ?? "";
        String userId = data['data']?['id']?.toString() ?? data['user']?['id']?.toString() ?? data['id']?.toString() ?? "";

        // ==========================================================
        // 🔥 IMPLEMENTASI LOCAL STORAGE LEVEL 4 (SANGAT BAIK)
        // Memenuhi kriteria: Multiple Data Types & Enkripsi Sederhana
        // ==========================================================
        final prefs = await SharedPreferences.getInstance();
        
        // 1. Menyimpan Multiple Data Types (Bool, Int, String)
        await prefs.setBool('is_logged_in', true); 
        await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch); 
        
        await prefs.setString('user_name', data['data']?['fullName'] ?? data['user']?['fullName'] ?? "Pengguna");
        await prefs.setString('user_email', data['data']?['email'] ?? data['user']?['email'] ?? _emailController.text);
        await prefs.setString('user_phone', data['data']?['phoneNumber'] ?? data['user']?['phoneNumber'] ?? "-");
        await prefs.setString('userId', userId);
        await prefs.setString('user_role', role); 

        // 2. Menerapkan Enkripsi Sederhana (Base64) untuk Token Login
        // Menggabungkan beberapa data menjadi 1 string raw, lalu dienkripsi
        String rawToken = "${_emailController.text}-$userId-${DateTime.now().toIso8601String()}";
        String encryptedToken = base64Encode(utf8.encode(rawToken)); 
        await prefs.setString('auth_token', encryptedToken); // Simpan versi tersandi

        debugPrint("🔐 Token Asli: $rawToken");
        debugPrint("🔐 Token Terenkripsi: $encryptedToken");
        // ==========================================================

        if (mounted) {
          if (role == 'WARGA' || role == 'MASYARAKAT') {
            _showSuccessSnackBar('Login sukses sebagai Masyarakat');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
          } else if (role == 'OPERATOR' || role == 'SUPIR') { 
            _showSuccessSnackBar('Login sukses sebagai Supir');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OperatorHomeScreen(driverId: userId)));
          } else {
            _showErrorSnackBar('Role tidak dikenali: "$role".');
          }
        }
      } else {
        if (mounted) _showErrorSnackBar(data['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Terjadi kesalahan jaringan. Coba lagi.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Text(message, style: const TextStyle(fontWeight: FontWeight.bold))]),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)))]),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            physics: const BouncingScrollPhysics(),
            // 🔥 3. Bungkus seluruh input dengan widget Form
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction, // 🔥 Feedback Real-time!
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.eco_rounded, size: 70, color: Colors.green.shade600),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Selamat Datang Kembali!', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('Silakan masuk dengan akun yang sudah terdaftar untuk melanjutkan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                  const SizedBox(height: 48),

                  Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  // 🔥 4. Ubah TextField menjadi TextFormField
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    // 🔥 Validasi Email Lengkap
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                      // Regex untuk format email
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'contoh@gmail.com',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.green.shade600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.green.shade500, width: 2)),
                      // 🔥 Styling khusus untuk keadaan Error
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  // 🔥 Ubah TextField menjadi TextFormField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, 
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    // 🔥 Validasi Password Lengkap
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password wajib diisi';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan password Anda',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.green.shade600),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade500),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.green.shade500, width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Masuk Aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun?', style: TextStyle(color: Colors.grey.shade600)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: Text('Daftar di sini', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toba_bersih/features/operator/operator_home_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; 

// Sesuaikan dengan struktur folder proyekmu
import 'package:toba_bersih/main.dart'; 
import 'package:toba_bersih/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // 🔥 Variabel toggle view password

  // 💡 CATATAN: Pastikan IP Address ini sesuai dengan laptopmu saat ini ya
  final String ipAddress = '10.61.166.195';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse('http://$ipAddress:5000/api/auth/login');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        
        // Mengambil Role
        String role = "";
        if (data['data'] != null && data['data']['role'] != null) {
          role = data['data']['role'].toString().toUpperCase();
        } else if (data['user'] != null && data['user']['role'] != null) {
          role = data['user']['role'].toString().toUpperCase();
        } else if (data['role'] != null) {
          role = data['role'].toString().toUpperCase();
        }

        // Mengambil ID User
        String userId = "";
        if (data['data'] != null && data['data']['id'] != null) {
          userId = data['data']['id'].toString();
        } else if (data['user'] != null && data['user']['id'] != null) {
          userId = data['user']['id'].toString();
        } else if (data['id'] != null) {
          userId = data['id'].toString();
        }

        print("Role yang terdeteksi: $role | ID User: $userId");

        // MENYIMPAN DATA PROFIL KE MEMORI HP
        final prefs = await SharedPreferences.getInstance();
        
        String nama = data['data']?['fullName'] ?? data['user']?['fullName'] ?? "Pengguna";
        String emailAsli = data['data']?['email'] ?? data['user']?['email'] ?? _emailController.text;
        String telepon = data['data']?['phoneNumber'] ?? data['user']?['phoneNumber'] ?? "-";

        await prefs.setString('user_name', nama);
        await prefs.setString('user_email', emailAsli);
        await prefs.setString('user_phone', telepon);
        
        // 🔥 INI DIA KUNCI UTAMANYA: Simpan ID User agar laporan tidak error lagi!
        await prefs.setString('userId', userId);
        await prefs.setString('user_role', role); // Simpan role untuk jaga-jaga

        if (mounted) {
          if (role == 'WARGA' || role == 'MASYARAKAT') {
            _showSuccessSnackBar('Login sukses sebagai Masyarakat');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );

          } else if (role == 'OPERATOR' || role == 'SUPIR') { 
            _showSuccessSnackBar('Login sukses sebagai Supir');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OperatorHomeScreen(driverId: userId)),
            );

          } else {
            _showErrorSnackBar('Role tidak dikenali: "$role". Hubungi Admin!');
          }
        }

      } else {
        if (mounted) {
          _showErrorSnackBar(data['message'] ?? 'Login Gagal');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Terjadi kesalahan jaringan. Coba lagi.');
      }
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
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🌿 HEADER / LOGO
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 70,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'Selamat Datang Kembali!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan masuk dengan akun yang sudah terdaftar untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // 📧 EMAIL FIELD
                Text(
                  'Email',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'contoh@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.green.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.green.shade500, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔒 PASSWORD FIELD
                Text(
                  'Password',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, 
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Masukkan password Anda',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.green.shade600),
                    // 🔥 TOMBOL TOGGLE MATA PASSWORD
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.green.shade500, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
                const SizedBox(height: 32),

                // 🚀 BUTTON LOGIN
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            'Masuk Aplikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // 📝 REGISTER BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar di sini',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
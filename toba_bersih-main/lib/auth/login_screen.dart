import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toba_bersih/features/operator/operator_home.dart';
import 'dart:convert';

// Sesuaikan dengan struktur folder proyekmu
import 'package:toba_bersih/main.dart';
import 'package:toba_bersih/features/operator/operator_home.dart';
import 'package:toba_bersih/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {

    setState(() {
      _isLoading = true;
    });

    try {

      var url = Uri.parse(
          'http://10.225.176.144:5000/api/auth/login');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'email':
              _emailController.text.trim(),
          'password':
              _passwordController.text.trim(),
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {

        String role =
            data['user']?['role'] ?? "";

        if (mounted) {

          if (role == 'WARGA') {

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                    'Login sukses sebagai Masyarakat'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MainScreen(),
              ),
            );

          } else if (role == 'OPERATOR') {

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content:
                    Text('Login sukses sebagai Supir'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const OperatorHomeScreen(),
              ),
            );

          } else {

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content:
                    Text('Role tidak dikenali'),
                backgroundColor: Colors.red,
              ),
            );

          }

        }

      } else {

        if (mounted) {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ??
                    'Login Gagal',
              ),
              backgroundColor: Colors.red,
            ),
          );

        }

      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan jaringan: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );

      }

    } finally {

      if (mounted) {

        setState(() {
          _isLoading = false;
        });

      }

    }

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

      body: Center(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(30.0),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.eco,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Silakan masuk untuk melanjutkan',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // EMAIL
              TextField(
                controller:
                    _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration:
                    InputDecoration(
                  labelText: 'Email',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),
                  prefixIcon:
                      const Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextField(
                controller:
                    _passwordController,
                obscureText: true,
                decoration:
                    InputDecoration(
                  labelText: 'Password',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),
                  prefixIcon:
                      const Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON LOGIN
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              10),
                    ),
                  ),

                  onPressed:
                      _isLoading
                          ? null
                          : _login,

                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color:
                              Colors.white)
                      : const Text(
                          'Masuk Aplikasi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // REGISTER BUTTON
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  const Text(
                      'Belum punya akun?'),

                  TextButton(

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen(),
                        ),
                      );

                    },

                    child: const Text(
                      'Daftar di sini',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                  ),

                ],
              ),

            ],

          ),

        ),

      ),

    );

  }

}
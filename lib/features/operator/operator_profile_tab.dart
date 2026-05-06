import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:toba_bersih/auth/login_screen.dart'; 
import 'package:toba_bersih/features/profile/privacy_policy_screen.dart'; 
import 'package:toba_bersih/features/profile/help_center_screen.dart';
// Sesuaikan import di bawah ini jika DriverHistoryScreen ada di file terpisah. 
// Jika di file yang sama, tidak perlu import.

class OperatorProfileTab extends StatefulWidget {
  final String driverId;
  const OperatorProfileTab({super.key, required this.driverId});

  @override
  State<OperatorProfileTab> createState() => _OperatorProfileTabState();
}

class _OperatorProfileTabState extends State<OperatorProfileTab> {
  String _driverName = "Supir Toba";
  List<dynamic> _tasks = []; 
  final String ipAddress = '10.72.28.195'; // Ganti jika IP berubah

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
    _fetchTaskStats();
  }

  Future<void> _loadDriverProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _driverName = prefs.getString('user_name') ?? "Supir Toba");
  }

  Future<void> _fetchTaskStats() async {
    try {
      final response = await http.get(Uri.parse('http://$ipAddress:5000/api/driver/${widget.driverId}/tasks'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) setState(() => _tasks = data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("Stat Error: $e");
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.power_settings_new_rounded, size: 50, color: Colors.red),
            SizedBox(height: 16),
            Text('Akhiri Sesi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menyelesaikan shift dan keluar dari aplikasi?', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.4)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600, 
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); 

              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchTaskStats,
      color: Colors.blueGrey.shade800,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800, 
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 100, width: 100,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Text(
                            _driverName.isNotEmpty ? _driverName.substring(0, 1).toUpperCase() : "S", 
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.verified_user_rounded, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_driverName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('Driver ID: ${widget.driverId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  )
                ],
              ),
            ),
            
            Transform.translate(
              offset: const Offset(0, -25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(child: _buildDriverStatCard(Icons.task_alt_rounded, 'Diselesaikan', '${_tasks.where((t) => t['status'] == 'SELESAI').length}', Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDriverStatCard(Icons.route_rounded, 'Sisa Rute', '${_tasks.where((t) => t['status'] != 'SELESAI').length}', Colors.orange)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operasional & Kendaraan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  _buildProfileMenu(icon: Icons.history_rounded, title: 'Riwayat Tugas Selesai', color: Colors.blueGrey, onTap: () {
                    // 🔥 BERIKAN HANYA DATA TUGAS YANG SUDAH SELESAI
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DriverHistoryScreen(
                      completedTasks: _tasks.where((t) => t['status'] == 'SELESAI').toList()
                    )));
                  }),
                  _buildProfileMenu(icon: Icons.build_circle_rounded, title: 'Lapor Kendala Truk', color: Colors.amber.shade800, onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Laporan Kendala Truk segera hadir!'), backgroundColor: Colors.amber));
                  }),
                  const SizedBox(height: 24),
                  Text('Informasi Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  _buildProfileMenu(icon: Icons.shield_outlined, title: 'Kebijakan Privasi', color: Colors.purple, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                  }),
                  _buildProfileMenu(icon: Icons.help_outline_rounded, title: 'Pusat Bantuan', color: Colors.teal, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                  }),
                  const SizedBox(height: 32),
                  _buildProfileMenu(icon: Icons.power_settings_new_rounded, title: 'Akhiri Sesi Kerja', color: Colors.red, isLogout: true, onTap: _logout),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStatCard(IconData icon, String title, String count, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade600, size: 28),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileMenu({required IconData icon, required String title, required Color color, bool isLogout = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isLogout ? Colors.red.shade50 : color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: isLogout ? Colors.red.shade700 : color, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isLogout ? Colors.red.shade700 : Colors.black87)),
        trailing: isLogout ? null : Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ==============================================================
// 🔥 HALAMAN RIWAYAT TUGAS SUPIR 
// ==============================================================
class DriverHistoryScreen extends StatelessWidget {
  final List<dynamic> completedTasks;
  const DriverHistoryScreen({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Riwayat Tugas', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: completedTasks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("Belum Ada Riwayat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Text("Anda belum menyelesaikan tugas apapun.", style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
                  ),
                  title: Text(task['location'] ?? 'Lokasi Tugas', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text('Tugas Selesai', style: TextStyle(color: Colors.green)),
                  ),
                ),
              );
            },
          ),
    );
  }
}
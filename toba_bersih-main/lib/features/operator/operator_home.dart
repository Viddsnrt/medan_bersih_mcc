import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // 🔥 TAMBAHAN: Import url_launcher

// Import ini untuk bisa Logout kembali ke halaman Login (sesuaikan path-nya)
import 'package:toba_bersih/auth/login_screen.dart';

class OperatorHomeScreen extends StatefulWidget {
  final String driverId;

  const OperatorHomeScreen({super.key, required this.driverId});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _tasks = [];
  bool _isLoading = true;

  // Gunakan IP Laptop kamu
  final String ipAddress = '10.61.166.195';

  @override
  void initState() {
    super.initState();
    _fetchMyTasks();
  }

  Future<void> _fetchMyTasks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://$ipAddress:5000/api/driver/${widget.driverId}/tasks'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _tasks = data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat tugas. Periksa koneksi internet!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔥 FUNGSI BARU: Membuka Google Maps
  Future<void> _openMapNavigation(dynamic lat, dynamic lng, String locationName) async {
    try {
      Uri mapsUrl;

      // Cek apakah latitude dan longitude tersedia dan valid
      if (lat != null && lng != null && lat.toString().isNotEmpty && lng.toString().isNotEmpty) {
        final latitude = lat.toString();
        final longitude = lng.toString();
        // Menggunakan Universal URL untuk Rute Perjalanan (Direct to Navigation)
        mapsUrl = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving");
      } else {
        // Jika tidak ada koordinat, cari berdasarkan nama jalan/lokasi
        final encodedName = Uri.encodeComponent(locationName);
        mapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedName");
      }

      // Memaksa HP untuk membuka URL tersebut menggunakan Aplikasi Eksternal (Google Maps / Browser)
      if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
        throw 'Aplikasi peta tidak ditemukan.';
      }
      
    } catch (e) {
      debugPrint("Map Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka navigasi peta.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- HALAMAN 1: DASHBOARD TUGAS ---
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _fetchMyTasks,
      color: Colors.green[700],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[800]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30), 
                  bottomRight: Radius.circular(30)
                ),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, Pejuang Kebersihan!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Semangat bertugas hari ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.local_shipping, color: Colors.orange[700], size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Rute & Tugas', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('${_tasks.length}', style: TextStyle(color: Colors.green[800], fontSize: 28, fontWeight: FontWeight.w900)),
                                  const SizedBox(width: 4),
                                  Text('Lokasi', style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text("Daftar Penugasan Anda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            _isLoading 
              ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              : _tasks.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(_tasks[index]);
                    },
                  ),
            
            const SizedBox(height: 30), 
          ],
        ),
      ),
    );
  }

  // --- HALAMAN 2: PROFIL ---
  Widget _buildProfileTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, size: 60, color: Colors.green[700]),
            ),
            const SizedBox(height: 16),
            const Text("Akun Operator", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("ID Driver: ${widget.driverId}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildProfileMenu(icon: Icons.history, title: 'Riwayat Tugas', onTap: () {}),
            _buildProfileMenu(icon: Icons.settings, title: 'Pengaturan Akun', onTap: () {}),
            _buildProfileMenu(icon: Icons.help_outline, title: 'Pusat Bantuan', onTap: () {}),
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Keluar dari Aplikasi", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.green[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[200]),
          const SizedBox(height: 16),
          const Text(
            "Tidak Ada Tugas Aktif", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          const Text(
            "Semua tugas hari ini sudah selesai atau admin belum memberikan tugas baru.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    bool isAduan = task['type'] == 'ADUAN';
    Color themeColor = isAduan ? Colors.orange[700]! : Colors.indigo[600]!;
    
    String timeStr = "Waktu tidak diketahui";
    if (task['scheduledAt'] != null) {
      DateTime dt = DateTime.parse(task['scheduledAt']).toLocal();
      timeStr = "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} WIB";
    }

    Color statusColor = Colors.grey;
    String statusStr = task['status'] ?? 'DITUGASKAN';
    if (statusStr == 'DITUGASKAN') statusColor = Colors.blue;
    if (statusStr == 'BEKERJA' || statusStr == 'DALAM_PERJALANAN') statusColor = Colors.amber[700]!;
    if (statusStr == 'SELESAI') statusColor = Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(isAduan ? Icons.warning_rounded : Icons.route, size: 14, color: themeColor),
                      const SizedBox(width: 6),
                      Text(
                        isAduan ? 'ADUAN WARGA' : 'RUTE RUTIN', 
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: themeColor)
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    statusStr.replaceAll('_', ' '), 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1),
            ),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.location_on, color: Colors.red),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['location'] ?? 'Lokasi tidak diketahui', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2)
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_filled, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text("Jadwal: $timeStr", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            
            if (task['notes'] != null && task['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), border: Border.all(color: Colors.orange.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.orange[800]),
                        const SizedBox(width: 4),
                        Text("Catatan Admin:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(task['notes'], style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                  ],
                ),
              )
            ],

            const SizedBox(height: 20),
            
            // 🔥 TOMBOL MULAI TUGAS YANG SUDAH DIPERBAIKI
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Panggil fungsi buka Google Maps dengan data dari Task
                  _openMapNavigation(
                    task['latitude'], 
                    task['longitude'], 
                    task['location'] ?? ''
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.navigation_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('MULAI TUGAS & NAVIGASI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white, letterSpacing: 1)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Tugas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
// Sesuaikan nama 'toba_bersih' dengan nama project di pubspec.yaml kamu
import 'package:toba_bersih/features/report/report_screen.dart';
import 'package:toba_bersih/features/history/history_screen.dart';
import 'package:toba_bersih/features/profile/profile_screen.dart';
import 'package:toba_bersih/features/onboarding/splash_screen.dart'; // TAMBAHAN: Import Splash Screen

void main() {
  runApp(const TobaBersihApp());
}

class TobaBersihApp extends StatelessWidget {
  const TobaBersihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toba Bersih',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const SplashScreen(), 
    );
  }
}

// ==========================================
// 1. MAIN SCREEN (NAVIGASI 4 TAB BARU)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar 4 halaman sesuai urutan Navigation Bar
  final List<Widget> _pages = [
    const DashboardScreen(),
    const ReportScreen(), // Halaman Form Laporan Kamera
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Menggunakan BottomNavigationBar standar untuk 4 item
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Penting agar teks tidak hilang saat item > 3
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo_outlined),
            activeIcon: Icon(Icons.add_a_photo),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. DASHBOARD SCREEN (DENGAN TRACKING TRUK)
// ==========================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[700],
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Warga Toba!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Mari jaga kebersihan lingkungan kita',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 24),
            
            // --- FITUR BARU: JADWAL & LACAK TRUK SAMPAH ---
            const Text(
              'Pengangkutan Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTrackingSection(),
            const SizedBox(height: 24),

            const Text(
              'Statistik Laporan Kamu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatisticsSection(),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Laporan Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lihat Semua', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            _buildRecentReportsList(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BARU: KARTU TRACKING ---
  Widget _buildTrackingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  const Text('Jadwal Area Rumahmu', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50], 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text('Aktif', 
                  style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Truk DLH #02 - Rute Balige', 
                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600, fontSize: 13)
                    ),
                    const SizedBox(height: 4),
                    Text('Estimasi Tiba: 15:30 - 16:00 WIB', 
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)
                    ),
                    const SizedBox(height: 4),
                    Text('Status: Sedang di Jl. Sisingamangaraja', 
                      style: TextStyle(color: Colors.orange[700], fontSize: 12, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  print("Buka Live Tracking Map");
                },
                icon: const Icon(Icons.map, size: 16),
                label: const Text('Lacak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Toba Bersih, Toba Sehat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Pisahkan sampah organik dan anorganik untuk memudahkan daur ulang.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total\nLaporan', '12', Icons.assignment, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Sedang\nDiproses', '3', Icons.sync, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Selesai\nDitangani', '9', Icons.check_circle, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList() {
    final List<Map<String, dynamic>> dummyReports = [
      {'title': 'Tumpukan sampah di Pasar Balige', 'date': '10 Mar 2026', 'status': 'Diproses', 'statusColor': Colors.orange},
      {'title': 'Sampah plastik di pinggir Danau', 'date': '08 Mar 2026', 'status': 'Selesai', 'statusColor': Colors.green},
      {'title': 'Pohon tumbang dan sampah daun', 'date': '05 Mar 2026', 'status': 'Selesai', 'statusColor': Colors.green},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyReports.length,
      itemBuilder: (context, index) {
        final report = dummyReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)),
            ),
            title: Text(report['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(report['date'], style: const TextStyle(fontSize: 12)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: report['statusColor'].withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(report['status'], style: TextStyle(color: report['statusColor'], fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
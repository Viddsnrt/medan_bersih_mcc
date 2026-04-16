import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Sesuaikan nama 'toba_bersih' dengan nama project di pubspec.yaml kamu
import 'package:toba_bersih/features/report/report_screen.dart';
import 'package:toba_bersih/features/history/history_screen.dart';
import 'package:toba_bersih/features/profile/profile_screen.dart';
import 'package:toba_bersih/features/onboarding/splash_screen.dart'; 

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
      // 🔥 KEMBALI 100% KE TEMA ASLIMU
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey,
      ),
      home: const SplashScreen(), 
    );
  }
}

// ==========================================
// 1. MAIN SCREEN (NAVIGASI 4 TAB)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ReportScreen(), 
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, 
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
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
// 2. DASHBOARD SCREEN (DENGAN DATA ASLI SERVER)
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _reports = [];

  // Variabel untuk menyimpan angka statistik asli
  int _totalLaporan = 0;
  int _laporanDiproses = 0;
  int _laporanSelesai = 0;

  final String ipAddress = '10.61.166.195'; // IP Laptop kamu

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // --- FUNGSI MENGAMBIL DATA DARI SERVER ---
  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('http://$ipAddress:5000/api/laporan/user/2'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> reportsData = data['data'];

        // Perbarui state secara halus tanpa memicu loading screen penuh
        if (mounted) {
          setState(() {
            _reports = reportsData;
            _totalLaporan = reportsData.length;
            _laporanDiproses = reportsData.where((r) => r['status'] == 'DIPROSES').length;
            _laporanSelesai = reportsData.where((r) => r['status'] == 'SELESAI').length;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
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
      // 🔥 STRUKTUR UI DIKEMBALIKAN PERSIS 100% SEPERTI KODE ASLIMU
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 24),
            
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
                  Icon(Icons.local_shipping, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Jadwal Area Rumahmu', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green, 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text('Aktif', 
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)
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
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)
                    ),
                    const SizedBox(height: 4),
                    Text('Estimasi Tiba: 15:30 - 16:00 WIB', 
                      style: TextStyle(color: Colors.grey, fontSize: 12)
                    ),
                    const SizedBox(height: 4),
                    Text('Status: Sedang di Jl. Sisingamangaraja', 
                      style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500)
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
                  backgroundColor: Colors.green,
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
          colors: [Colors.green!, Colors.green!],
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
        // 🔥 Memasukkan variabel statistik langsung ke dalam parameter fungsi
        Expanded(child: _buildStatCard('Total\nLaporan', _totalLaporan.toString(), Icons.assignment, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Sedang\nDiproses', _laporanDiproses.toString(), Icons.sync, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Selesai\nDitangani', _laporanSelesai.toString(), Icons.check_circle, Colors.green)),
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
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList() {
    if (_reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("Memuat laporan...", style: TextStyle(color: Colors.grey))),
      );
    }

    // Ambil maksimal 3 data terbaru
    final recentReports = _reports.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentReports.length,
      itemBuilder: (context, index) {
        final report = recentReports[index];
        
        // Logika warna status
        Color statusColor = Colors.orange; 
        String statusLabel = report['status'] ?? 'PENDING';
        
        if (statusLabel == 'PENDING') { 
          statusColor = Colors.blue; 
          statusLabel = 'Dilaporkan'; 
        } else if (statusLabel == 'DIPROSES') { 
          statusColor = Colors.orange; 
          statusLabel = 'Diproses'; 
        } else if (statusLabel == 'SELESAI') { 
          statusColor = Colors.green; 
          statusLabel = 'Selesai'; 
        }

        // Format Tanggal
        String formattedDate = '';
        if (report['createdAt'] != null) {
          DateTime dt = DateTime.parse(report['createdAt']).toLocal();
          List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
          formattedDate = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: report['photoUrl'] != null 
                  ? Image.network(report['photoUrl'], width: 60, height: 60, fit: BoxFit.cover)
                  : Container(width: 60, height: 60, color: Colors.grey, child: const Icon(Icons.image, color: Colors.grey)),
            ),
            title: Text(
              report['description'] ?? 'Laporan', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(formattedDate, style: const TextStyle(fontSize: 12)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
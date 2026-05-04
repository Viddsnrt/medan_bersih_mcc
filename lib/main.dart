import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Sesuaikan nama 'toba_bersih' dengan nama project di pubspec.yaml kamu
import 'package:toba_bersih/features/report/report_screen.dart';
import 'package:toba_bersih/features/history/history_screen.dart';
import 'package:toba_bersih/features/profile/profile_screen.dart';
import 'package:toba_bersih/features/onboarding/splash_screen.dart'; 

// 🔥 IMPORT FILE PETA YANG BARU DIBUAT (Sesuaikan path-nya)
import 'package:toba_bersih/features/report/live_tracking_screen.dart';

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
  int _totalLaporan = 0;
  int _laporanDiproses = 0;
  int _laporanSelesai = 0;

  final String ipAddress = '10.61.166.195'; 

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

 // Jangan lupa import di atas: import 'package:shared_preferences/shared_preferences.dart';

Future<void> _fetchDashboardData() async {
  try {
    // 🔥 1. AMBIL ID DARI MEMORI HP
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedUserId = prefs.getString('userId');

    if (savedUserId == null) {
      debugPrint("Waduh, User ID belum tersimpan! Harus login ulang.");
      return; // Stop fungsi kalau ID gak ada
    }

    // 🔥 2. GUNAKAN ID OTOMATIS TERSEBUT KE DALAM URL
    final response = await http.get(Uri.parse('http://$ipAddress:5000/api/laporan/user/$savedUserId'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reportsData = data['data'];

      if (mounted) {
        setState(() {
          _reports = reportsData;
          _totalLaporan = reportsData.length;
          _laporanDiproses = reportsData.where((r) => 
            r['status'] == 'PENDING' || 
            r['status'] == 'DIPROSES' || 
            r['status'] == 'DITINDAKLANJUTI'
          ).length;
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
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Warga Toba!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            Text(
              'Mari jaga kebersihan lingkungan kita',
              style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 24),
            
            Text(
              'Pengangkutan Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildTrackingSection(),
            const SizedBox(height: 24),

            Text(
              'Statistik Laporan Kamu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildStatisticsSection(),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Laporan Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Lihat Semua', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w800)),
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
    final double truckLatitude = 2.3333; 
    final double truckLongitude = 99.0667; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  Icon(Icons.location_on_rounded, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text('Jadwal Area Rumahmu', 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50, 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text('Aktif', 
                  style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Truk DLH #02 - Rute Amplas', 
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 14)
                    ),
                    const SizedBox(height: 6),
                    Text('Estimasi Tiba: 15:30 - 16:00 WIB', 
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 6),
                    Text('Status: Sedang di Jl. Sisingamangaraja', 
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w800)
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // 🔥 MEMBUKA PETA DI DALAM APLIKASI
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveTrackingScreen(
                        truckLat: truckLatitude,
                        truckLng: truckLongitude,
                        truckName: 'Truk DLH #02 - Balige',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('Lacak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Toba Bersih, Toba Sehat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Pisahkan sampah organik dan anorganik untuk memudahkan daur ulang.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4)),
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
        Expanded(child: _buildStatCard('Total\nLaporan', _totalLaporan.toString(), Icons.assignment_rounded, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Sedang\nDiproses', _laporanDiproses.toString(), Icons.sync_rounded, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Selesai\nDitangani', _laporanSelesai.toString(), Icons.check_circle_rounded, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.shade50, shape: BoxShape.circle),
            child: Icon(icon, color: color.shade600, size: 24),
          ),
          const SizedBox(height: 12),
          Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList() {
    if (_reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("Belum ada laporan terbaru.", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
      );
    }

    final recentReports = _reports.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentReports.length,
      itemBuilder: (context, index) {
        final report = recentReports[index];
        
        Color statusColor = Colors.orange; 
        String statusLabel = report['status'] ?? 'PENDING';
        
        if (statusLabel == 'PENDING') { 
          statusColor = Colors.blue.shade600; 
          statusLabel = 'Dilaporkan'; 
        } else if (statusLabel == 'DIPROSES' || statusLabel == 'DITINDAKLANJUTI') { 
          statusColor = Colors.orange.shade700; 
          statusLabel = 'Diproses'; 
        } else if (statusLabel == 'SELESAI') { 
          statusColor = Colors.green.shade600; 
          statusLabel = 'Selesai'; 
        }

        String formattedDate = '';
        if (report['createdAt'] != null) {
          DateTime dt = DateTime.parse(report['createdAt']).toLocal();
          List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
          formattedDate = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: report['photoUrl'] != null 
                  ? Image.network(report['photoUrl'], width: 65, height: 65, fit: BoxFit.cover)
                  : Container(width: 65, height: 65, color: Colors.grey[100], child: Icon(Icons.image_not_supported_rounded, color: Colors.grey.shade400)),
            ),
            title: Text(
              report['description'] ?? 'Laporan', 
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(formattedDate, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
        );
      },
    );
  }
}
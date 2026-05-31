import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // 🔥 IMPORT PROVIDER

// 🔥 IMPORT FIREBASE UNTUK NOTIFIKASI
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Sesuaikan nama 'toba_bersih' dengan nama project di pubspec.yaml kamu
import 'package:toba_bersih/features/report/report_screen.dart';
import 'package:toba_bersih/features/history/history_screen.dart';
import 'package:toba_bersih/features/profile/profile_screen.dart';
import 'package:toba_bersih/features/onboarding/splash_screen.dart';
import 'package:toba_bersih/features/report/live_tracking_screen.dart';

// ==========================================
// 🔥 1. STATE MANAGEMENT PROFESIONAL (PROVIDER)
// Memisahkan logika API dari tampilan (UI)
// ==========================================
class DashboardProvider extends ChangeNotifier {
  List<dynamic> _reports = [];
  int _totalLaporan = 0;
  int _laporanDiproses = 0;
  int _laporanSelesai = 0;
  bool _isLoading = true;

  List<dynamic> get reports => _reports;
  int get totalLaporan => _totalLaporan;
  int get laporanDiproses => _laporanDiproses;
  int get laporanSelesai => _laporanSelesai;
  bool get isLoading => _isLoading;

  final String ipAddress = '10.152.199.195';

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners(); // Memberitahu UI untuk loading

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedUserId = prefs.getString('userId');

      if (savedUserId == null) return;

      final response = await http.get(
        Uri.parse('http://$ipAddress:5000/api/laporan/user/$savedUserId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> reportsData = data['data'];

        _reports = reportsData;
        _totalLaporan = reportsData.length;
        _laporanDiproses = reportsData.where((r) => r['status'] == 'PENDING' || r['status'] == 'DIPROSES' || r['status'] == 'DITINDAKLANJUTI').length;
        _laporanSelesai = reportsData.where((r) => r['status'] == 'SELESAI').length;
      }
    } catch (e) {
      debugPrint("Error fetching dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Memberitahu UI bahwa data siap
    }
  }
}

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  final String ipAddress = '10.152.199.195';

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId == null) return;

      final response = await http.get(
        Uri.parse('http://$ipAddress:5000/api/penugasan/notifikasi/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _notifications = data['data'];
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ==========================================
// 🔥 FUNGSI PENANGKAP NOTIFIKASI BACKGROUND
// ==========================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Menerima notifikasi Background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const TobaBersihApp(),
    ),
  );
}

class TobaBersihApp extends StatelessWidget {
  const TobaBersihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toba Bersih',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2D7B3F),
        scaffoldBackgroundColor: const Color(0xFFF8FAFB),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 2. MAIN SCREEN (NAVIGASI)
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
  void initState() {
    super.initState();
    _setupForegroundNotifications();
  }

  void _setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.notification!.title ?? 'Notifikasi Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message.notification!.body ?? ''),
              ],
            ),
            backgroundColor: const Color(0xFF2D7B3F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.02, 0.0), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey<int>(_currentIndex), child: _pages[_currentIndex]),
      ),
      
      // 🔥 PENYEMPURNAAN BOTTOM NAVIGATION BAR (TARGET NILAI 4)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2D7B3F),
          unselectedItemColor: Colors.grey.shade400,
          
          // 🔥 Animasi Skala Ikon (Responsive Icon)
          selectedIconTheme: const IconThemeData(size: 28), // Membesar saat aktif
          unselectedIconTheme: const IconThemeData(size: 24), // Ukuran normal
          
          // 🔥 Animasi Teks membesar/menebal
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.add_a_photo_outlined), activeIcon: Icon(Icons.add_a_photo_rounded), label: 'Lapor'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history_rounded), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. DASHBOARD SCREEN (MENGGUNAKAN PROVIDER)
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D7B3F),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Warga Toba! 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            Text('Mari jaga kebersihan lingkungan', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D7B3F)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InfoBannerWidget(),
                  const SizedBox(height: 28),
                  
                  const Text('Pengangkutan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const TrackingWidget(),
                  const SizedBox(height: 28),

                  const Text('Statistik Laporan Kamu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  StatisticsWidget(provider: provider),
                  const SizedBox(height: 28),

                  const Text('Laporan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  RecentReportsWidget(reports: provider.reports),
                ],
              ),
            ),
    );
  }
}

// ==========================================
// 4. KUMPULAN WIDGET MODULAR
// ==========================================
class InfoBannerWidget extends StatelessWidget {
  const InfoBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2D7B3F), Color(0xFF38A050)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Toba Bersih = Toba Sehat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                Text('Pisahkan sampah organik & anorganik.', style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingWidget extends StatelessWidget {
  const TrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: Color(0xFF2D7B3F)),
              SizedBox(width: 10),
              Text('Truk DLH #02 - Rute Amplas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          const Divider(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackingScreen(truckLat: 2.33, truckLng: 99.06, truckName: 'Truk DLH'))),
            icon: const Icon(Icons.map_rounded),
            label: const Text('Lacak Truk'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7B3F), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class StatisticsWidget extends StatelessWidget {
  final DashboardProvider provider;
  const StatisticsWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total\nLaporan', provider.totalLaporan.toString(), Icons.assignment, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Diproses', provider.laporanDiproses.toString(), Icons.sync, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Selesai', provider.laporanSelesai.toString(), Icons.check_circle, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Icon(icon, color: color.shade600, size: 26),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class RecentReportsWidget extends StatelessWidget {
  final List<dynamic> reports;
  const RecentReportsWidget({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) return const Center(child: Text("Belum ada laporan terbaru"));
    final recent = reports.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final report = recent[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(report['description'] ?? 'Laporan', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text(report['status'] ?? 'PENDING', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 5. NOTIFICATION SCREEN (MENGGUNAKAN PROVIDER)
// ==========================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pemberitahuan', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF2D7B3F)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D7B3F)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.info_rounded, color: Color(0xFF2D7B3F)),
                    ),
                    title: Text(notif['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(notif['message'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
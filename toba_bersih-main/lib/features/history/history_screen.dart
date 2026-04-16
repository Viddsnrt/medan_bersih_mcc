import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'report_detail_screen.dart'; 

// 🔥 1. Import library Socket.io
import 'package:socket_io_client/socket_io_client.dart' as IO; 

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _allReports = [];
  bool _isLoading = true;
  
  // 🔥 2. Deklarasi variabel Socket dan IP Address
  IO.Socket? socket; 
  final String ipAddress = '10.61.166.195';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _initSocket(); // 🔥 3. Panggil fungsi penyambung socket saat layar dibuka
  }

  // =========================================================
  // 🔥 4. FUNGSI UNTUK MENGHUBUNGKAN WEBSOCKET KE SERVER
  // =========================================================
  void _initSocket() {
    socket = IO.io('http://$ipAddress:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint('🔌 Berhasil terhubung ke WebSocket Server!');
    });

    // MENDENGARKAN EVENT DARI NODE.JS
    socket!.on('status_laporan_berubah', (data) {
      debugPrint('🔔 ADA UPDATE REALTIME DARI ADMIN: $data');
      
      // Jika komponen masih aktif di layar (mounted), perbarui UI-nya
      if (mounted && data != null && data['reportId'] != null) {
        setState(() {
          // Cari laporan yang ID-nya cocok dengan yang dikirim server
          for (var i = 0; i < _allReports.length; i++) {
            if (_allReports[i]['id'].toString() == data['reportId'].toString()) {
              // Langsung timpa status lamanya dengan status baru
              _allReports[i]['status'] = data['newStatus']; 
              break;
            }
          }
        });
      }
    });
  }

  // 🔥 5. PENTING: Putuskan koneksi socket saat pengguna keluar dari halaman ini agar tidak boros baterai
  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }
  // =========================================================

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Memakai variabel ipAddress agar seragam dengan Socket
      final response = await http.get(Uri.parse('http://$ipAddress:5000/api/laporan/user/2')); 
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _allReports = data['data']);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal terhubung ke server. Pastikan HP dan Laptop di WiFi yang sama!')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Laporan'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dilaporkan'),
              Tab(text: 'Diproses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchData,
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildReportList(context, _allReports),
                  _buildReportList(context, _allReports.where((r) => r['status'] == 'PENDING').toList()),
                  _buildReportList(context, _allReports.where((r) => r['status'] == 'DIPROSES').toList()),
                  _buildReportList(context, _allReports.where((r) => r['status'] == 'SELESAI').toList()),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildReportList(BuildContext context, List<dynamic> reports) {
    if (reports.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("Belum ada laporan di kategori ini", style: TextStyle(color: Colors.grey))),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) => _buildReportCard(context, reports[index]),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    Color statusColor = Colors.grey;
    String statusLabel = report['status'] ?? 'PENDING';
    
    if (statusLabel == 'PENDING') { statusColor = Colors.blue; statusLabel = 'Dilaporkan'; }
    if (statusLabel == 'DIPROSES') { statusColor = Colors.orange; statusLabel = 'Diproses'; }
    if (statusLabel == 'SELESAI') { statusColor = Colors.green; statusLabel = 'Selesai'; }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailScreen(reportData: report))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: report['photoUrl'] != null 
                  ? Image.network(report['photoUrl'], width: 80, height: 80, fit: BoxFit.cover)
                  : Container(width: 80, height: 80, color: Colors.grey, child: const Icon(Icons.image)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report['jenisSampah'] ?? 'Laporan Warga', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(report['description'] ?? 'Tidak ada deskripsi', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; 
import 'package:socket_io_client/socket_io_client.dart' as IO; 

// 🔥 Pastikan file ini ada di folder yang sama
import 'report_detail_screen.dart'; 

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _allReports = [];
  bool _isLoading = true;
  
  IO.Socket? socket; 
  final String ipAddress = '10.72.28.195';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _initSocket(); 
  }

  void _initSocket() {
    socket = IO.io('http://$ipAddress:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();
    socket!.onConnect((_) => debugPrint('🔌 Berhasil terhubung ke WebSocket Server!'));

    socket!.on('status_laporan_berubah', (data) {
      debugPrint('🔔 ADA UPDATE REALTIME DARI ADMIN: $data');
      if (mounted && data != null && data['reportId'] != null) {
        setState(() {
          for (var i = 0; i < _allReports.length; i++) {
            if (_allReports[i]['id'].toString() == data['reportId'].toString()) {
              _allReports[i]['status'] = data['newStatus']; 
              break;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://$ipAddress:5000/api/laporan/user/80')); 
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _allReports = data['data']);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Gagal memuat riwayat. Periksa koneksi internet!')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, 
        appBar: AppBar(
          title: const Text('Riwayat Laporan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // 🔥 PERBAIKAN TAB BAR ADA DI SINI
          bottom: const TabBar(
            // isScrollable dihilangkan agar tab otomatis membagi rata lebar layar
            labelColor: Colors.white, // Memaksa teks yang dipilih berwarna putih
            unselectedLabelColor: Colors.white70, // Teks yang tidak dipilih berwarna putih pudar
            indicatorColor: Colors.white,
            indicatorWeight: 4, 
            labelPadding: EdgeInsets.zero, // Membuang padding berlebih
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            splashFactory: NoSplash.splashFactory, 
            tabs: [
              Tab(text: 'Semua'), // Dipersingkat agar tidak kepanjangan
              Tab(text: 'Dilaporkan'),
              Tab(text: 'Diproses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchData,
          color: Colors.green.shade700,
          backgroundColor: Colors.white,
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: Colors.green.shade700))
            : TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildReportList(context, _allReports),
                  _buildReportList(context, _allReports.where((r) => r['status'] == 'PENDING').toList()),
                  _buildReportList(context, _allReports.where((r) => r['status'] == 'DIPROSES' || r['status'] == 'DITINDAKLANJUTI').toList()),
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
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 24),
                Text(
                  "Belum ada laporan", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey.shade700)
                ),
                const SizedBox(height: 8),
                Text(
                  "Laporan Anda di kategori ini masih kosong.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: reports.length,
      itemBuilder: (context, index) => _buildReportCard(context, reports[index]),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    Color statusColor = Colors.grey;
    String statusLabel = report['status'] ?? 'PENDING';
    IconData statusIcon = Icons.info_outline;
    
    if (statusLabel == 'PENDING') { 
      statusColor = Colors.blue.shade600; 
      statusLabel = 'Dilaporkan'; 
      statusIcon = Icons.send_rounded;
    } else if (statusLabel == 'DIPROSES' || statusLabel == 'DITINDAKLANJUTI') { 
      statusColor = Colors.orange.shade700; 
      statusLabel = 'Diproses'; 
      statusIcon = Icons.sync_rounded;
    } else if (statusLabel == 'SELESAI') { 
      statusColor = Colors.green.shade600; 
      statusLabel = 'Selesai'; 
      statusIcon = Icons.check_circle_rounded;
    }

    String formattedDate = 'Waktu tidak diketahui';
    if (report['createdAt'] != null) {
      try {
        DateTime dt = DateTime.parse(report['createdAt']).toLocal();
        formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dt);
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

    String jenisSampah = report['jenisSampah'] ?? 'UMUM';
    jenisSampah = jenisSampah.replaceAll('_', ' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100)
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailScreen(reportData: report))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'report_image_${report['id']}', 
                  child: Container(
                    width: 90, 
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: report['photoUrl'] != null && report['photoUrl'].toString().isNotEmpty
                        ? Image.network(
                            report['photoUrl'], 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              formattedDate, 
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              jenisSampah, 
                              style: TextStyle(fontSize: 9, color: Colors.green.shade800, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        report['description'] ?? 'Laporan sampah di area ini', 
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, height: 1.3, color: Colors.black87), 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              statusLabel, 
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.2)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_rounded, color: Colors.grey.shade400, size: 28),
        const SizedBox(height: 4),
        Text("No Image", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
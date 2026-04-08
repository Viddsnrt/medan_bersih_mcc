import 'package:flutter/material.dart';
import 'package:toba_bersih/features/history/report_detail_screen.dart'; // Sesuaikan nama package

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data riwayat laporan
    final List<Map<String, dynamic>> historyReports = [
      {
        'title': 'Tumpukan sampah plastik di tepian Danau, Balige',
        'date': '10 Mar 2026',
        'status': 'Diproses',
        'category': 'Sampah Danau',
      },
      {
        'title': 'Fasilitas tempat sampah rusak di Alun-alun',
        'date': '08 Mar 2026',
        'status': 'Dilaporkan',
        'category': 'Fasilitas Rusak',
      },
      {
        'title': 'Sampah pasar belum diangkut 3 hari',
        'date': '05 Mar 2026',
        'status': 'Selesai',
        'category': 'Tumpukan Sampah',
      },
      {
        'title': 'Limbah rumah tangga di selokan',
        'date': '01 Mar 2026',
        'status': 'Ditolak',
        'category': 'Lainnya',
      },
    ];

    return DefaultTabController(
      length: 4, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Laporan'),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dilaporkan'),
              Tab(text: 'Diproses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // PERUBAHAN: Sekarang kita menambahkan 'context' ke dalam pemanggilan fungsi
            _buildReportList(context, historyReports),
            _buildReportList(context, historyReports.where((r) => r['status'] == 'Dilaporkan').toList()),
            _buildReportList(context, historyReports.where((r) => r['status'] == 'Diproses').toList()),
            _buildReportList(context, historyReports.where((r) => r['status'] == 'Selesai').toList()),
          ],
        ),
      ),
    );
  }

  // PERUBAHAN: Menambahkan 'BuildContext context' sebagai parameter pertama
  Widget _buildReportList(BuildContext context, List<Map<String, dynamic>> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada laporan di kategori ini',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        // PERUBAHAN: Meneruskan 'context' ke dalam _buildReportCard
        return _buildReportCard(context, report);
      },
    );
  }

  // PERUBAHAN: Menambahkan 'BuildContext context' di sini agar Navigator bisa bekerja
  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    Color statusColor;
    switch (report['status']) {
      case 'Dilaporkan':
        statusColor = Colors.blue;
        break;
      case 'Diproses':
        statusColor = Colors.orange;
        break;
      case 'Selesai':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context, // Sekarang context ini valid dan dikenali!
             MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportData: report),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey, size: 30),
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
                        Text(
                          report['category'],
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          report['date'],
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        report['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
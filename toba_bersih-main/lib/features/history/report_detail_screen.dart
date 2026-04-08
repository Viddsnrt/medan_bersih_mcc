import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportDetailScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    // Menentukan status untuk mewarnai badge dan timeline
    final String status = reportData['status'] ?? 'Dilaporkan';
    Color statusColor = Colors.blue;
    if (status == 'Diproses') statusColor = Colors.orange;
    if (status == 'Selesai') statusColor = Colors.green;
    if (status == 'Ditolak') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black, // Warna panah back dan text
        title: const Text('Status Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.green),
            onPressed: () {
              // TODO: Fitur share laporan
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR LAPORAN
            Container(
              width: double.infinity,
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
                image: const DecorationImage(
                  // Menggunakan placeholder gambar alam/sampah dari internet untuk simulasi
                  image: NetworkImage('https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&q=80&w=800'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. BADGE STATUS & ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'ID: TB-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. JUDUL LAPORAN
                  Text(
                    reportData['title'] ?? 'Judul Tidak Tersedia',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),

                  // 4. TANGGAL & LOKASI
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${reportData['date']}, 09:15 WIB',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jl. Sisingamangaraja No. 12, Balige, Kabupaten Toba',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),

                  // 5. LACAK PROGRESS (TIMELINE)
                  const Text(
                    'Lacak Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Logika sederhana untuk status aktif timeline
                  _buildTimelineItem(
                    isFirst: true,
                    isDone: true,
                    isActive: status == 'Dilaporkan',
                    icon: Icons.check_circle_outline,
                    title: 'Laporan Diterima',
                    subtitle: 'Sistem telah memverifikasi laporan Anda',
                    time: '09:15',
                  ),
                  _buildTimelineItem(
                    isDone: status == 'Diproses' || status == 'Selesai',
                    isActive: false,
                    icon: Icons.person_pin_circle_outlined,
                    title: 'Petugas Ditugaskan',
                    subtitle: 'Petugas DLH menuju lokasi',
                    time: status == 'Diproses' || status == 'Selesai' ? '10:30' : '--:--',
                  ),
                  _buildTimelineItem(
                    isDone: status == 'Diproses' || status == 'Selesai',
                    isActive: status == 'Diproses',
                    icon: Icons.local_shipping_outlined,
                    title: 'Dalam Perjalanan / Penanganan',
                    subtitle: status == 'Diproses' 
                        ? 'Armada sedang menuju lokasi Anda' 
                        : 'Menunggu penanganan...',
                    time: status == 'Diproses' || status == 'Selesai' ? '11:45' : '--:--',
                  ),
                  _buildTimelineItem(
                    isLast: true,
                    isDone: status == 'Selesai',
                    isActive: status == 'Selesai',
                    icon: Icons.delete_outline,
                    title: 'Sampah Diangkut',
                    subtitle: status == 'Selesai' 
                        ? 'Penyelesaian pembersihan lokasi'
                        : 'Menunggu proses selesai',
                    time: status == 'Selesai' ? '13:00' : '--:--',
                  ),
                  
                  const SizedBox(height: 40), // Ruang kosong di bawah (tanpa profil petugas)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KUSTOM UNTUK ITEM TIMELINE
  Widget _buildTimelineItem({
    bool isFirst = false,
    bool isLast = false,
    required bool isDone,
    required bool isActive,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    // Warna dinamis berdasarkan status
    Color iconColor = isDone || isActive ? Colors.white : Colors.grey.shade400;
    Color circleColor = isDone || isActive ? const Color(0xFF10C65C) : Colors.grey.shade200;
    Color lineColor = isDone ? const Color(0xFF10C65C) : Colors.grey.shade300;
    Color titleColor = isActive ? const Color(0xFF10C65C) : (isDone ? Colors.black87 : Colors.grey.shade500);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bagian Garis dan Ikon
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Garis Atas
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : lineColor,
                  ),
                ),
                // Lingkaran Ikon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: isActive ? [
                      BoxShadow(color: const Color(0xFF10C65C).withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                    ] : [],
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                // Garis Bawah
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Bagian Teks (Judul, Subjudul, Waktu)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive ? const Color(0xFF10C65C) : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
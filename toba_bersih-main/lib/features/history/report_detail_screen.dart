import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportDetailScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final String status = reportData['status'] ?? 'PENDING';
    
    // Status Logic untuk Timeline
    bool step1 = true; 
    bool step2 = status == 'DIPROSES' || status == 'SELESAI';
    bool step3 = status == 'DIPROSES' || status == 'SELESAI';
    bool step4 = status == 'SELESAI';

    // Format Tanggal (Dari createdAt backend ke format jam dan tanggal)
    String formattedDate = "Waktu tidak diketahui";
    if (reportData['createdAt'] != null) {
      DateTime dt = DateTime.parse(reportData['createdAt']).toLocal();
      formattedDate = "${dt.day}/${dt.month}/${dt.year}, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} WIB";
    }

    // Ubah text status
    String statusLabel = 'Dilaporkan';
    Color statusColor = Colors.blue;
    if (status == 'DIPROSES') { statusLabel = 'Diproses'; statusColor = Colors.orange; }
    if (status == 'SELESAI') { statusLabel = 'Selesai'; statusColor = Colors.green; }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Status Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR DARI DATABASE
            Container(
              width: double.infinity,
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: reportData['photoUrl'] != null
                    ? Image.network(reportData['photoUrl'], fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
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
                          statusLabel.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'ID: #${reportData['id'].toString().padLeft(5, '0')}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. JENIS SAMPAH & DESKRIPSI
                  Text(
                    reportData['jenisSampah'] ?? 'Kategori Laporan',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reportData['description'] ?? 'Tidak ada deskripsi rinci dari pelapor.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // 4. TANGGAL & KOORDINAT
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(formattedDate, style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Koordinat: ${reportData['latitude']}, ${reportData['longitude']}',
                          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
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

                  _buildTimelineItem(
                    isFirst: true, isDone: step1, isActive: status == 'PENDING',
                    icon: Icons.check_circle_outline, title: 'Laporan Diterima', 
                    subtitle: 'Laporan telah diverifikasi oleh sistem', time: '',
                  ),
                  _buildTimelineItem(
                    isDone: step2, isActive: false,
                    icon: Icons.person_pin_circle_outlined, title: 'Menunggu Petugas', 
                    subtitle: 'Admin meninjau laporan Anda', time: '',
                  ),
                  _buildTimelineItem(
                    isDone: step3, isActive: status == 'DIPROSES',
                    icon: Icons.local_shipping_outlined, title: 'Dalam Penanganan', 
                    subtitle: status == 'DIPROSES' ? 'Armada / Petugas menuju lokasi' : 'Menunggu armada...', time: '',
                  ),
                  _buildTimelineItem(
                    isLast: true, isDone: step4, isActive: status == 'SELESAI',
                    icon: Icons.delete_outline, title: 'Selesai', 
                    subtitle: status == 'SELESAI' ? 'Sampah / Masalah telah diatasi' : 'Menunggu penyelesaian', time: '',
                  ),
                  const SizedBox(height: 40),
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
    Color iconColor = isDone || isActive ? Colors.white : Colors.grey.shade400;
    Color circleColor = isDone || isActive ? const Color(0xFF10C65C) : Colors.grey.shade200;
    Color lineColor = isDone ? const Color(0xFF10C65C) : Colors.grey.shade300;
    Color titleColor = isActive ? const Color(0xFF10C65C) : (isDone ? Colors.black87 : Colors.grey.shade500);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : lineColor)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: isActive ? [BoxShadow(color: const Color(0xFF10C65C).withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] : [],
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
                        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: titleColor)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 13, color: isActive ? const Color(0xFF10C65C) : Colors.grey)),
                      ],
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
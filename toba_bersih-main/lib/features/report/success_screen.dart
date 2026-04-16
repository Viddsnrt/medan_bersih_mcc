import 'package:flutter/material.dart';
// 🔥 Pastikan path import ini sesuai dengan letak file HistoryScreen kamu
import 'package:toba_bersih/features/history/history_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Checklist hijau
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              
              // Judul Text
              const Text(
                "Laporan Berhasil Dikirim!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Deskripsi Text
              const Text(
                "Terima kasih! Laporan kamu telah kami terima\ndan akan segera diproses oleh tim kami.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              
              // Tombol Kembali ke Beranda
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Logic menghapus semua halaman dan kembali ke halaman pertama (Beranda)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol Lihat Status Laporan
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green, width: 1.5),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // 🔥 MENGARAHKAN KE HALAMAN RIWAYAT
                  // Menggunakan pushReplacement agar setelah masuk ke riwayat, warga tidak bisa "back" ke SuccessScreen lagi
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const HistoryScreen())
                  );
                },
                child: const Text(
                  "Lihat Status Laporan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
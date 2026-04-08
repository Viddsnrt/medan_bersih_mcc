import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  // Widget untuk Header Profil (Foto, Nama, Info)
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: Colors.green[700],
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.grey),
                // backgroundImage: AssetImage('assets/profile.jpg'), // Hapus komentar ini jika ada gambar
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'David Gian Filbert',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+62 812-3456-7890',
            style: TextStyle(fontSize: 14, color: Colors.green[100]),
          ),
          const SizedBox(height: 4),
          Text(
            'Balige Kota, Kab. Toba',
            style: TextStyle(fontSize: 14, color: Colors.green[100]),
          ),
        ],
      ),
    );
  }

  // Widget untuk Daftar Menu Pengaturan
  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan Akun',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildListTile(Icons.person_outline, 'Edit Profil', () {
            // TODO: Navigasi ke Edit Profil
          }),
          _buildListTile(Icons.notifications_none, 'Pengaturan Notifikasi', () {
            // TODO: Buka Pengaturan Notifikasi
          }),
          const Divider(height: 32),

          const Text(
            'Informasi Umum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          _buildListTile(Icons.help_outline, 'Help Center', () {}),
          _buildListTile(Icons.info_outline, 'Tentang Aplikasi', () {}),
          const Divider(height: 32),

          // Tombol Logout Khusus
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.red[700]),
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // TODO: Implementasi logika logout ke API/Supabase
              print("Proses Logout...");
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper Widget agar kode menu tidak berulang
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green[700]),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

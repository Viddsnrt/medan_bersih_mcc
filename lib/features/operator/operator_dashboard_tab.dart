import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart'; 

import 'driver_map_screen.dart'; // Sesuaikan import Peta Supir kamu

class OperatorDashboardTab extends StatefulWidget {
  final String driverId;
  const OperatorDashboardTab({super.key, required this.driverId});

  @override
  State<OperatorDashboardTab> createState() => _OperatorDashboardTabState();
}

class _OperatorDashboardTabState extends State<OperatorDashboardTab> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  String _driverName = "Supir Toba";
  final String ipAddress = '10.72.28.195'; // Ganti jika IP berubah
  
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadDriverName();
    _fetchMyTasks();
    _getCurrentLocation(); 
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) setState(() => _currentPosition = position);
  }

  String _calculateDistance(double targetLat, double targetLng) {
    if (_currentPosition == null) return "Mencari lokasi...";
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, targetLat, targetLng,
    );
    if (distanceInMeters > 1000) return "${(distanceInMeters / 1000).toStringAsFixed(1)} km dari Anda";
    return "${distanceInMeters.toStringAsFixed(0)} meter dari Anda";
  }

  Future<void> _loadDriverName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _driverName = prefs.getString('user_name') ?? "Supir Toba");
  }

  Future<void> _fetchMyTasks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://$ipAddress:5000/api/driver/${widget.driverId}/tasks'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) setState(() => _tasks = data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 FILTER: HANYA TAMPILKAN TUGAS YANG BELUM SELESAI
    final activeTasks = _tasks.where((t) => t['status'] != 'SELESAI').toList();

    return RefreshIndicator(
      onRefresh: () async {
        await _getCurrentLocation(); 
        await _fetchMyTasks();
      },
      color: Colors.green.shade700,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, $_driverName!', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          const Text('Semangat bertugas hari ini 💪', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: IconButton(icon: const Icon(Icons.notifications_active_rounded, color: Colors.white), onPressed: () {}),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.local_shipping_rounded, color: Colors.orange.shade700, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tugas Aktif Saat Ini', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('${activeTasks.length}', style: TextStyle(color: Colors.green.shade800, fontSize: 32, fontWeight: FontWeight.w900)),
                                  const SizedBox(width: 6),
                                  const Text('Lokasi', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text("Daftar Penugasan Anda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
            ),
            _isLoading 
              ? Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.green.shade700)))
              : activeTasks.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: activeTasks.length, // 🔥 Pakai activeTasks
                    itemBuilder: (context, index) => _buildTaskCard(activeTasks[index]),
                  ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
            child: Icon(Icons.task_alt_rounded, size: 60, color: Colors.green.shade400),
          ),
          const SizedBox(height: 24),
          const Text("Tidak Ada Tugas Aktif", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 8),
          Text("Semua tugas hari ini sudah selesai atau admin belum memberikan tugas baru.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    bool isAduan = task['type'] == 'ADUAN';
    Color themeColor = isAduan ? Colors.orange.shade700 : Colors.indigo.shade600;
    String timeStr = "Waktu tidak diketahui";
    if (task['scheduledAt'] != null) {
      DateTime dt = DateTime.parse(task['scheduledAt']).toLocal();
      timeStr = "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} WIB";
    }

    Color statusColor = Colors.grey;
    String statusStr = task['status'] ?? 'DITUGASKAN';
    if (statusStr == 'DITUGASKAN') statusColor = Colors.blue.shade600;
    if (statusStr == 'BEKERJA' || statusStr == 'DALAM_PERJALANAN') statusColor = Colors.amber.shade700;

    double lat = task['latitude'] != null ? double.tryParse(task['latitude'].toString()) ?? 2.3333 : 2.3333;
    double lng = task['longitude'] != null ? double.tryParse(task['longitude'].toString()) ?? 99.0667 : 99.0667;
    String distanceStr = _calculateDistance(lat, lng);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(isAduan ? Icons.warning_rounded : Icons.route_rounded, size: 14, color: themeColor),
                      const SizedBox(width: 6),
                      Text(isAduan ? 'ADUAN WARGA' : 'RUTE RUTIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: themeColor, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusStr.replaceAll('_', ' '), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, thickness: 1)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.location_on_rounded, color: Colors.red.shade600, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task['location'] ?? 'Lokasi tidak diketahui', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87, height: 1.3)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text("Jadwal: $timeStr", style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_car_rounded, size: 14, color: Colors.blue.shade400),
                          const SizedBox(width: 6),
                          Text(distanceStr, style: TextStyle(color: Colors.blue.shade700, fontSize: 13, fontWeight: FontWeight.w800)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            if (task['notes'] != null && task['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade100), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_rounded, size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 6),
                        Text("Catatan Admin", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.orange.shade800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(task['notes'], style: TextStyle(fontSize: 13, color: Colors.orange.shade900, fontWeight: FontWeight.w500, height: 1.4)),
                  ],
                ),
              )
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () async {
                  // 🔥 TUNGGU HASIL KEMBALIAN DARI PETA
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverMapScreen(
                        taskId: task['id'].toString(), // 🔥 WAJIB KIRIM ID TUGAS KE PETA
                        destinationLat: lat,
                        destinationLng: lng,
                        destinationName: task['location'] ?? 'Lokasi Tujuan',
                        taskType: task['type'] ?? 'RUTE',
                      ),
                    ),
                  );
                  
                  // 🔥 JIKA PETA MEMBERI KABAR "TRUE" (TUGAS SELESAI), REFRESH LIST!
                  if (result == true) {
                    _fetchMyTasks();
                  }
                },
                icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                label: const Text('MULAI TUGAS & NAVIGASI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
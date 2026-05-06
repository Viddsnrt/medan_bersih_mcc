import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http; // 🔥 WAJIB IMPORT INI
import 'dart:convert'; // 🔥 WAJIB IMPORT INI

class DriverMapScreen extends StatefulWidget {
  final String taskId; // 🔥 INI DIA YANG BIKIN ERROR TADI, SEKARANG SUDAH ADA!
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final String taskType; 

  const DriverMapScreen({
    super.key,
    required this.taskId, // 🔥 WAJIB DITAMBAHKAN DI SINI
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    required this.taskType,
  });

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  final MapController _mapController = MapController();
  
  // Variabel Lokasi & Jarak
  LatLng? _currentDriverPos;
  StreamSubscription<Position>? _positionStream;
  double _distanceToTarget = 9999.0; // Default sangat jauh
  bool _isWithinRadius = false;
  final double _allowedRadiusInMeters = 50.0; // Batas toleransi 50 meter

  // 🔥 Socket IO Config
  IO.Socket? socket; 
  final String ipAddress = '10.72.28.195'; // Pastikan IP ini sama dengan Backend kamu

  @override
  void initState() {
    super.initState();
    _initSocket();
    _startLocationTracking();
  }

  // 🔌 MENGHIDUPKAN SOCKET IO
  void _initSocket() {
    socket = IO.io('http://$ipAddress:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();
    socket!.onConnect((_) => debugPrint('🔌 [Supir] Terhubung ke WebSocket Server!'));
  }

  // 📡 FUNGSI MEMULAI STREAM LOKASI REAL-TIME
  Future<void> _startLocationTracking() async {
    // 1. Cek Izin
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi diperlukan untuk navigasi.')),
        );
      }
      return;
    }

    // 2. Dapatkan lokasi pertama kali untuk memusatkan peta
    Position initialPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _currentDriverPos = LatLng(initialPos.latitude, initialPos.longitude);
        _calculateDistance();
      });
      
      // 🔥 PUSATKAN KAMERA KE LOKASI SUPIR SAAT INI (Bukan ke lokasi sampah)
      _mapController.move(_currentDriverPos!, 16.0); 
    }

    // 3. Mulai mendengarkan pergerakan (Stream)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update setiap supir bergerak 5 meter
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (mounted) {
        setState(() {
          _currentDriverPos = LatLng(position.latitude, position.longitude);
          _calculateDistance();
          
          // Kamera peta otomatis mengikuti supir
          _mapController.move(_currentDriverPos!, _mapController.camera.zoom);

          // 🔥 PANCARKAN (EMIT) LOKASI SUPIR KE SERVER AGAR MASYARAKAT BISA MELIHAT
          if (socket != null && socket!.connected) {
            socket!.emit('driver_location_update', {
              'driverId': '2', // Bisa kamu ambil dari SharedPreferences nantinya
              'latitude': position.latitude,
              'longitude': position.longitude,
            });
            debugPrint('📡 Lokasi baru dikirim ke server: ${position.latitude}, ${position.longitude}');
          }
        });
      }
    });
  }

  // 📏 FUNGSI MENGHITUNG JARAK SUPIR KE TARGET (GEOFENCING)
  void _calculateDistance() {
    if (_currentDriverPos == null) return;

    _distanceToTarget = Geolocator.distanceBetween(
      _currentDriverPos!.latitude, 
      _currentDriverPos!.longitude,
      widget.destinationLat, 
      widget.destinationLng
    );

    // Cek apakah supir sudah masuk radius 50 meter
    _isWithinRadius = _distanceToTarget <= _allowedRadiusInMeters;
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // MATIKAN STREAM LOKASI
    socket?.disconnect();      // PUTUSKAN SOCKET IO
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destination = LatLng(widget.destinationLat, widget.destinationLng);
    final bool isAduan = widget.taskType == 'ADUAN';
    final Color themeColor = isAduan ? Colors.orange.shade700 : Colors.indigo.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigasi Tugas', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. LAYER PETA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // 🔥 JIKA _currentDriverPos belum dapat, arahkan ke sampah sementara. Kalau sudah, arahkan ke Supir.
              initialCenter: _currentDriverPos ?? destination,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.toba_bersih',
              ),
              
              // Lingkaran Radius Keamanan di sekitar target
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: destination,
                    color: themeColor.withOpacity(0.2),
                    borderColor: themeColor.withOpacity(0.5),
                    borderStrokeWidth: 2,
                    radius: _allowedRadiusInMeters, // 50 meter
                    useRadiusInMeter: true,
                  ),
                ],
              ),

              // Layer Marka Peta
              MarkerLayer(
                markers: [
                  // A. Marka Tujuan (Lokasi Sampah)
                  Marker(
                    point: destination,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Text('Tujuan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Icon(Icons.location_on_rounded, color: themeColor, size: 40),
                      ],
                    ),
                  ),

                  // B. Marka Supir (Titik Biru yang Bergerak)
                  if (_currentDriverPos != null)
                    Marker(
                      point: _currentDriverPos!,
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.drive_eta_rounded, color: Colors.blue, size: 24),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. PANEL INFO BAWAH DENGAN TOMBOL PINTAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Icon(isAduan ? Icons.warning_rounded : Icons.route_rounded, color: themeColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAduan ? 'Menuju Lokasi Aduan' : 'Menuju Rute Rutin', 
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: themeColor, letterSpacing: 0.5)
                            ),
                            const SizedBox(height: 4),
                            Text(widget.destinationName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                            const SizedBox(height: 6),
                            
                            // 🔥 INDIKATOR JARAK REAL-TIME
                            Row(
                              children: [
                                Icon(
                                  _isWithinRadius ? Icons.check_circle_rounded : Icons.social_distance_rounded, 
                                  size: 16, 
                                  color: _isWithinRadius ? Colors.green.shade600 : Colors.red.shade600
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isWithinRadius 
                                    ? "Anda sudah tiba di lokasi!" 
                                    : "Jarak: ${_distanceToTarget.toStringAsFixed(0)} meter lagi", 
                                  style: TextStyle(
                                    color: _isWithinRadius ? Colors.green.shade700 : Colors.red.shade700, 
                                    fontSize: 13, 
                                    fontWeight: FontWeight.w700
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 🔥 TOMBOL ANTI-NIPU & TEMBAK API
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWithinRadius ? Colors.green.shade600 : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isWithinRadius 
                        ? () async {
                            // Tampilkan Loading Dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
                            );

                            try {
                              // 🔥 TEMBAK API BACKEND UNTUK UBAH STATUS JADI SELESAI
                              final response = await http.patch(
                                Uri.parse('http://$ipAddress:5000/api/penugasan/${widget.taskId}/status'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({'status': 'SELESAI'}),
                              );

                              // Tutup loading dialog
                              if (!context.mounted) return;
                              Navigator.pop(context); 

                              if (response.statusCode == 200) {
                                // 🔥 POP DENGAN NILAI 'TRUE' AGAR DASHBOARD TAHU DAN REFRESH
                                Navigator.pop(context, true); 
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tugas Berhasil Diselesaikan!'), backgroundColor: Colors.green),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menyelesaikan tugas: ${response.body}')),
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              Navigator.pop(context); // Tutup loading jika error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error jaringan: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Terlalu Jauh! Anda harus berada dalam radius 50m dari lokasi.', style: TextStyle(fontWeight: FontWeight.bold)), 
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                      icon: Icon(
                        _isWithinRadius ? Icons.check_circle_rounded : Icons.lock_rounded, 
                        color: Colors.white
                      ),
                      label: Text(
                        _isWithinRadius ? 'Selesaikan Tugas Ini' : 'Terlalu Jauh dari Lokasi', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
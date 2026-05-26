import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// 🔥 IMPORT SOCKET.IO UNTUK MENERIMA LOKASI REAL-TIME
import 'package:socket_io_client/socket_io_client.dart' as IO; 

class LiveTrackingScreen extends StatefulWidget {
  final double truckLat;
  final double truckLng;
  final String truckName;

  const LiveTrackingScreen({
    super.key,
    required this.truckLat,
    required this.truckLng,
    required this.truckName,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late LatLng _currentTruckPos;
  final MapController _mapController = MapController();
  
  IO.Socket? socket; 
  final String ipAddress = '10.152.199.195'; // Sesuaikan dengan IP Servermu

  @override
  void initState() {
    super.initState();
    // Set posisi awal dari data saat tombol "Lacak" diklik
    _currentTruckPos = LatLng(widget.truckLat, widget.truckLng);
    _initSocket();
  }

  // 📡 FUNGSI UNTUK MENDENGARKAN PERGERAKAN SUPIR
  void _initSocket() {
    socket = IO.io('http://$ipAddress:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    // Pastikan event ini sama dengan yang dipancarkan oleh Node.js kamu
    socket!.on('truck_location_update', (data) {
      if (mounted && data != null) {
        setState(() {
          // Update titik koordinat truk dengan data terbaru dari server
          _currentTruckPos = LatLng(
            double.parse(data['latitude'].toString()),
            double.parse(data['longitude'].toString())
          );
          
          // 🔥 Pindahkan kamera otomatis mengikuti pergerakan truk
          _mapController.move(_currentTruckPos, _mapController.camera.zoom);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Truk DLH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. LAYER PETA
          FlutterMap(
            mapController: _mapController, // Pasang controller untuk menggerakkan kamera
            options: MapOptions(
              initialCenter: _currentTruckPos,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.toba_bersih',
              ),
              // Layer Marker (Pin Truk yang akan bergerak)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentTruckPos, // Titik ini akan terus berubah
                    width: 60,
                    height: 60,
                    child: const Column(
                      children: [
                        Icon(Icons.local_shipping_rounded, color: Colors.green, size: 36),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. PANEL INFO BAWAH
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.local_shipping_rounded, color: Colors.green.shade700, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.truckName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                            const SizedBox(height: 4),
                            // Indikator animasi berkedip (opsional, memberikan kesan live)
                            Row(
                              children: [
                                const Icon(Icons.sensors_rounded, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('Live GPS Aktif', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: const Text('Tutup Pelacakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
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
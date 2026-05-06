import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 IMPORT DITAMBAHKAN

// Tambahkan import untuk halaman SuccessScreen
import 'success_screen.dart'; 

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  // 🔥 PERBAIKAN 1: Tambahkan WidgetsBindingObserver untuk melacak aplikasi diminimize/dibuka lagi
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with WidgetsBindingObserver {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Tumpukan Sampah';

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationMessage = "Mencari lokasi...";
  
  bool _isSubmitting = false; 

  // 💡 CATATAN: Pastikan IP ini sesuai dengan IPv4 laptopmu saat ini
  final String ipAddress = '10.72.28.195';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation(showDialogIfOff: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getCurrentLocation(showDialogIfOff: false);
    }
  }

  void _resetForm() {
    setState(() {
      _imageFile = null;
      _titleController.clear();
      _descController.clear();
      _selectedCategory = 'Tumpukan Sampah';
    });
  }

  Future<void> _getCurrentLocation({bool showDialogIfOff = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _isLoadingLocation = true;
      _locationMessage = "Memeriksa status GPS...";
    });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
        _locationMessage = "GPS mati. Tap di sini untuk menyalakan.";
      });

      if (showDialogIfOff && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.location_off_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text('GPS Tidak Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: const Text('Toba Bersih butuh akses lokasi untuk memastikan titik tumpukan sampah akurat. Yuk, nyalakan GPS-mu dulu!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(); 
                    await Geolocator.openLocationSettings(); 
                  },
                  child: const Text('Buka Pengaturan'),
                ),
              ],
            );
          },
        );
      }
      return; 
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _locationMessage = "Izin lokasi ditolak.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
        _locationMessage = "Izin ditolak permanen.";
      });
      return;
    }

    setState(() {
      _locationMessage = "Mencari titik kordinat...";
    });

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
          _locationMessage = "${position.latitude}, ${position.longitude}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationMessage = "Gagal mendapatkan lokasi.";
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
    }
  }

  Future<void> _submitReport() async {
    if (_imageFile == null || _titleController.text.isEmpty || _currentPosition == null) {
      _showCustomSnackBar('Mohon lengkapi foto, judul, dan pastikan GPS menyala!', isError: true);
      return;
    }

    // 🔥 AMBIL ID USER DARI MEMORI HP
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedUserId = prefs.getString('userId');

    if (savedUserId == null) {
      _showCustomSnackBar('Sesi login tidak valid. Silakan logout dan login kembali.', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true; 
    });

    try {
      var uri = Uri.parse('http://$ipAddress:5000/api/laporan/create');
      var request = http.MultipartRequest('POST', uri);

      request.fields['description'] = "[${_titleController.text}] - ${_descController.text}";
      request.fields['jenisSampah'] = _selectedCategory;
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();
      
      // 🔥 GUNAKAN ID OTOMATIS
      request.fields['userId'] = savedUserId; 

      var multipartFile = await http.MultipartFile.fromPath('photo', _imageFile!.path);
      request.files.add(multipartFile);

      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        if (mounted) {
          _resetForm();
          showDialog(
            context: context,
            barrierDismissible: false, 
            builder: (BuildContext context) {
              return const SuccessScreen();
            },
          );
        }
      } else {
        if (mounted) {
          _showCustomSnackBar(data['message'] ?? 'Gagal mengirim laporan', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar('Terjadi kesalahan jaringan atau waktu habis.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false; 
        });
      }
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buat Laporan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📸 KOTAK GAMBAR
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_imageFile!, fit: BoxFit.cover),
                            Container(color: Colors.black.withOpacity(0.2)),
                            const Center(
                              child: Icon(Icons.change_circle_rounded, color: Colors.white, size: 50),
                            )
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                            child: Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.green.shade600),
                          ),
                          const SizedBox(height: 12),
                          const Text('Tap untuk mengambil foto\nbukti tumpukan sampah', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade600, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 📍 KARTU LOKASI GPS
            GestureDetector(
              onTap: () => _getCurrentLocation(showDialogIfOff: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _currentPosition == null ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _currentPosition == null ? Colors.red.shade200 : Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        _currentPosition == null ? Icons.location_off_rounded : Icons.location_on_rounded, 
                        color: _currentPosition == null ? Colors.red.shade600 : Colors.blue.shade600, 
                        size: 24
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lokasi Terdeteksi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _currentPosition == null ? Colors.red.shade800 : Colors.blue.shade800)),
                          const SizedBox(height: 4),
                          _isLoadingLocation
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  _locationMessage,
                                  style: TextStyle(fontSize: 13, color: _currentPosition == null ? Colors.red.shade900 : Colors.blue.shade900, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.my_location_rounded, color: _currentPosition == null ? Colors.red.shade700 : Colors.blue.shade700),
                      onPressed: () {
                        _getCurrentLocation(showDialogIfOff: true);
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 📝 FORM INPUT
            Text('Judul Laporan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Cth: Sampah berserakan di jalan',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),

            Text('Kategori Masalah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green.shade700),
              items: ['Tumpukan Sampah', 'Fasilitas Rusak', 'Sampah Danau', 'Lainnya']
                  .map((category) => DropdownMenuItem(value: category, child: Text(category, style: const TextStyle(fontWeight: FontWeight.w500))))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            Text('Deskripsi Detail (Opsional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan patokan lokasi atau detail lainnya...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // 🚀 TOMBOL KIRIM
            Container(
              height: 56,
              decoration: BoxDecoration(
                boxShadow: _isSubmitting ? [] : [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded),
                          SizedBox(width: 8),
                          Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:toba_bersih/main.dart'; // Import MainScreen dari main.dart

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data konten untuk ke-3 halaman onboarding
  final List<Map<String, String>> onboardingData = [
    {
      "title": "Laporkan Sampah dengan Mudah",
      "text": "Laporkan lokasi sampah di sekitar Anda melalui aplikasi dan bantu jaga kebersihan Toba.",
      "icon": "phone", // Penanda untuk ikon placeholder
    },
    {
      "title": "Pantau Pengangkutan",
      "text": "Lihat status pengangkutan sampah secara realtime di wilayah Anda.",
      "icon": "map",
    },
    {
      "title": "Lingkungan Lebih Bersih",
      "text": "Bersama kita menjaga kebersihan Kabupaten Toba demi masa depan yang lebih hijau.",
      "icon": "nature",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Skip di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: Text(
                  _currentPage == 2 ? 'Lewati' : 'Skip',
                  style: const TextStyle(color: Color(0xFF10C65C), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            // Area Konten yang bisa digeser (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: onboardingData[index]["title"]!,
                  text: onboardingData[index]["text"]!,
                  iconType: onboardingData[index]["icon"]!,
                ),
              ),
            ),

            // Indikator Titik (Dots) dan Tombol Lanjut
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          // Jika halaman terakhir, masuk ke MainScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                        } else {
                          // Lanjut ke halaman berikutnya
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10C65C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? "Mulai" : "Lanjut →",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desain titik indikator
  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF10C65C) : Colors.green[100],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// Widget untuk isi konten Onboarding
class OnboardingContent extends StatelessWidget {
  final String title, text, iconType;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.text,
    required this.iconType,
  });

  @override
  Widget build(BuildContext context) {
    IconData displayIcon = Icons.image;
    if (iconType == "phone") displayIcon = Icons.phone_android;
    if (iconType == "map") displayIcon = Icons.map_outlined;
    if (iconType == "nature") displayIcon = Icons.landscape;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(),
          // PLACEHOLDER GAMBAR (Nanti bisa diganti Image.asset)
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(displayIcon, size: 80, color: Colors.grey[400]),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
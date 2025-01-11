import 'package:flutter/material.dart';
import 'main_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80), // Padding di bagian atas untuk memindahkan komponen ke tengah
                // Hero animation untuk logo yang halus

                const SizedBox(height: 50),
                const SizedBox(height: 15),
                const Spacer(), // Menambahkan Spacer untuk menggeser tombol ke bawah

                // Tombol Let's Explore
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800), // Durasi lebih lama
                          pageBuilder: (context, animation, secondaryAnimation) =>
                          const MyHomePage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = 0.0;
                            var end = 1.0;
                            var curve = Curves.easeInOutCubic; // Curve halus
                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(curve: curve),
                            );

                            return FadeTransition(
                              opacity: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent), // Tanpa border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bentuk lebih bulat
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Color(0xFF8B5E3C), // Warna coklat sesuai referensi
                    ),
                    child: const Text(
                      'Let\'s Explore',
                      style: TextStyle(
                        color: Colors.white, // Warna teks putih
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

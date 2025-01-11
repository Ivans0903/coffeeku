import 'package:coffeeku/contact_page.dart';
import 'package:coffeeku/login_page.dart';
import 'package:flutter/material.dart';
import 'videos_tips.dart';  // Import untuk video tips
import 'calculator_page.dart'; // Import halaman kalkulator

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const HomePage(),
    const VideosTipsPage(),
    const UnifiedCalculatorPage(),
    const FriendsPage(),
    const LoginPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update index halaman yang dipilih
    });
  }

  // Fungsi untuk mendapatkan judul berdasarkan index
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Coffee Tips';
      case 1:
        return 'Video Tips';
      case 2:
        return 'Calculator';
      case 3:
        return 'Contacts';
      case 4:
        return 'Chat for Help';
      default:
        return 'Coffee Tips';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8D6E63), // Warna coklat (brown)
        elevation: 0,
        leading: _selectedIndex == 0
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedIndex = 0; // Kembali ke halaman home
            });
          },
        ),
        title: Text(
          _getTitle(_selectedIndex),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: _pages[_selectedIndex],  // Menampilkan halaman yang dipilih berdasarkan index
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Menambahkan ini agar warna tidak hilang
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8D6E63), // Warna item yang dipilih
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Video Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          )
        ],
        onTap: _onItemTapped,  // Fungsi untuk menangani perubahan halaman
      ),
    );
  }
}

// Home Page untuk menampilkan artikel-artikel
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // First article - Tips on Brewing the Perfect Coffee
        _buildArticle(
            'assets/images/coffee_tips_1.jpg',
            'How to Brew the Perfect Coffee',
            'Learn how to brew the perfect cup of coffee with simple tips. From choosing the right coffee beans to the best brewing methods, we will guide you through each step.',
        ),
        // Second article - Coffee Bean Varieties
        _buildArticle(
          'assets/images/coffee_tips_2.jpg',
          'Different Coffee Bean Varieties',
          'Discover the different types of coffee beans: Arabica, Robusta, and more. Each variety has a unique flavor profile and brew method.',
        ),
        // Third article - Coffee and Health
        _buildArticle(
          'assets/images/coffee_tips_3.jpg',
          'Health Benefits of Coffee',
          'Coffee is not only delicious but can also offer health benefits. From boosting your energy to improving brain function, find out why coffee can be good for you.',
        ),
        _buildArticle(
          'assets/images/coffee-_tips_4.jpg',
          'Decaf Doesn’t Mean No Caffeine',
          'For a coffee to be classed as decaf, it needs to have less than 0.3% caffeine',
        ),
        _buildArticle(
          'assets/images/coffee_tips_5.jpg',
          'The Most Expensive Coffee in The World Costs 600USD Per Pound',
          'Kopi Luwak is the most expensive coffee in the world, and as of 2019, it cost 600USD per pound. Native to Indonesia, the coffee is roasted after being eaten, digested and expelled by the Palm Civet. It’s said that they only eat the very best, sweetest and freshest coffee cherries and when ingested, it’s naturally fermented, giving it a distinctive flavour.',
        ),
        _buildArticle(
        'assets/images/coffee_tips_6.jpg',
        'National Coffee Day.',
        'National Coffee Day is September 29th.',
        ),
      ],
    );
  }

  Widget _buildArticle(String imageUrl, String title, String description) {
    return GestureDetector(
      onTap: () {
        // Navigate to the article detail page
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menggunakan AspectRatio untuk crop gambar dengan rasio 4:3
              AspectRatio(
                aspectRatio: 4 / 3,  // Menentukan rasio 4:3
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),  // Membuat sudut gambar melengkung
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,  // Memastikan gambar ter-crop dan terisi dengan baik
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(description),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
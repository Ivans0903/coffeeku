import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late Database _database;
  List<Map<String, dynamic>> friends = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Inisialisasi database
  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'friends.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE friends (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL
          )
        ''');
      },
    );

    _loadFriends();
  }

  // Memuat data dari database
  Future<void> _loadFriends() async {
    final data = await _database.query('friends');
    setState(() {
      friends = data;
    });
  }

  // Menambah kontak ke database
  Future<void> _addFriend(String name, String phone) async {
    if (name.isEmpty || phone.isEmpty) return;

    await _database.insert('friends', {'name': name, 'phone': phone});
    _loadFriends();
    _nameController.clear();
    _phoneController.clear();
    _showMessage("Berhasil Menyimpan Kontak");
  }

  // Menampilkan pesan menggunakan ScaffoldMessenger
  void _showMessage(String message) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Daftarkan navigatorKey di MaterialApp
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Buku Telepon',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: const Color(0xFFD7CCC8), // Warna AppBar lebih konsisten
          elevation: 2, // Tambahkan bayangan untuk AppBar
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactListPage(
                      database: _database, // Kirim database ke ContactListPage
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang konsisten
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Membuat Card melengkung
                ),
                color: const Color(0xFFD7CCC8), // Warna Card konsisten
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Input Nama
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Sudut melengkung
                          ),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF5D4037)),
                          filled: true,
                          fillColor: const Color(0xFFEDE7F6), // Warna latar belakang input
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Input Nomor Telepon
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Nomor Telepon',
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Sudut melengkung
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFF5D4037)),
                          filled: true,
                          fillColor: const Color(0xFFEDE7F6), // Warna latar belakang input
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Tambah Teman
                      SizedBox(
                        width: double.infinity, // Membuat tombol memenuhi lebar
                        child: ElevatedButton(
                          onPressed: () => _addFriend(
                            _nameController.text,
                            _phoneController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D4037), // Warna tombol
                            padding: const EdgeInsets.symmetric(vertical: 16), // Padding vertikal
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Sudut melengkung tombol
                            ),
                          ),
                          child: const Text(
                            'Tambah Teman',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 18, // Ukuran teks lebih besar
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _database.close();
    super.dispose();
  }
}

// Halaman untuk menampilkan daftar kontak
class ContactListPage extends StatefulWidget {
  final Database database; // Tambahkan database sebagai parameter
  const ContactListPage({super.key, required this.database});


  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Map<String, dynamic>> friends = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadFriends(); // Memuat data kontak saat halaman dibuka
  }

  // Memuat data dari database
  Future<void> _loadFriends() async {
    final data = await widget.database.query('friends');
    setState(() {
      friends = data;
    });
  }

  // Memperbarui kontak di database
  Future<void> _updateFriend(BuildContext context, int id, String name, String phone) async {
    if (name.isEmpty || phone.isEmpty) return;

    await widget.database.update(
      'friends',
      {'name': name, 'phone': phone},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadFriends(); // Segera muat ulang data
    _showMessage(context, "Kontak Berhasil Diperbarui");
  }

  // Menghapus kontak dari database
  Future<void> _deleteFriend(BuildContext context, int id) async {
    await widget.database.delete('friends', where: 'id = ?', whereArgs: [id]);
    await _loadFriends(); // Segera muat ulang data
    _showMessage(context, "Kontak Berhasil Dihapus");
  }

  // Menampilkan pesan menggunakan ScaffoldMessenger
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
        backgroundColor: const Color(0xFF5D4037), // Warna konsisten
      ),
      backgroundColor: const Color(0xFF8D6E63), // Warna latar belakang konsisten
      body: friends.isEmpty
          ? const Center(
        child: Text(
          'Belum ada kontak yang disimpan.',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: friends.length,
        padding: const EdgeInsets.all(10), // Tambahkan jarak
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFFD7CCC8), // Warna Card
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF5D4037),
                child: Text(
                  friend['name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                friend['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              subtitle: Text(
                friend['phone'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5D4037),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showUpdateDialog(
                      context,
                      friend['id'],
                      friend['name'],
                      friend['phone'],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFriend(context, friend['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUpdateDialog(
      BuildContext context, int id, String currentName, String currentPhone) {
    final TextEditingController nameController =
    TextEditingController(text: currentName);
    final TextEditingController phoneController =
    TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perbarui Kontak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateFriend(context, id, nameController.text, phoneController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Set text color to white
              // You can add other styling attributes here if needed
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

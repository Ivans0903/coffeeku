import 'package:coffeeku/main_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Pastikan jalur import benar
import 'main.dart'; // Untuk GlobalDrawer

class ChatPageWithDrawer extends StatefulWidget {
  const ChatPageWithDrawer({super.key});

  @override
  _ChatPageWithDrawerState createState() => _ChatPageWithDrawerState();
}

class _ChatPageWithDrawerState extends State<ChatPageWithDrawer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('messages').add({
        'text': _messageController.text.trim(),
        'sender': currentUser.email,
        'receiver': 'bismillah@gmail.com',
        'participants': [currentUser.email, 'bismillah@gmail.com'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();

      // Gulir otomatis ke pesan terbaru
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      _showError('Gagal mengirim pesan. Error: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } catch (e) {
      _showError('Gagal logout: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('User Chat'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5D4037), // Warna AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('participants', arrayContains: currentUser?.email)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}\n'
                          'Pastikan Anda telah membuat indeks yang diminta.',
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pesan. Mulailah percakapan!'),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                    messages[index].data() as Map<String, dynamic>;
                    final isSender = message['sender'] == currentUser?.email;

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // Warna background chat
                          color: isSender
                              ? const Color(0xFF8D6E63) // Warna pengirim
                              : const Color(0xFFD7CCC8), // Warna penerima
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft:
                            isSender ? const Radius.circular(10) : Radius.zero,
                            bottomRight:
                            isSender ? Radius.zero : const Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isSender
                                ? Colors.white // Warna teks pengirim
                                : Colors.black, // Warna teks penerima
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // Sudut melengkung
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEFEBE9), // Warna field input
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Kirim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

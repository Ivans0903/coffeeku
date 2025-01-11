import 'package:coffeeku/main_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Pastikan jalur ke LoginPage benar
import 'main.dart'; // Untuk GlobalDrawer

class AdminPageWithDrawer extends StatefulWidget {
  const AdminPageWithDrawer({super.key});

  @override
  _AdminPageWithDrawerState createState() => _AdminPageWithDrawerState();
}

class _AdminPageWithDrawerState extends State<AdminPageWithDrawer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false, // Menghapus semua rute sebelumnya
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Chat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .where('receiver', isEqualTo: 'bismillah@gmail.com') // Admin sebagai penerima
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!.docs;
          final Set<String> uniqueUsers = {};

          // Ambil pengguna unik yang pernah mengirim pesan ke admin
          for (var message in messages) {
            final data = message.data() as Map<String, dynamic>; // Konversi ke Map
            final sender = data['sender'];
            if (sender != 'Admin') {
              uniqueUsers.add(sender);
            }
          }

          if (uniqueUsers.isEmpty) {
            return const Center(
              child: Text('Belum ada pengguna yang mengirim pesan.'),
            );
          }

          return ListView(
            children: uniqueUsers.map((email) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(email),
                onTap: () {
                  // Navigasi ke halaman percakapan dengan pengguna tertentu
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserChatPage(userEmail: email),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class UserChatPage extends StatefulWidget {
  final String userEmail;

  const UserChatPage({required this.userEmail, super.key});

  @override
  _UserChatPageState createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('messages').add({
        'text': _messageController.text.trim(),
        'sender': 'Admin',
        'receiver': widget.userEmail,
        'participants': ['Admin', widget.userEmail],
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      _showError('Gagal mengirim pesan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${widget.userEmail}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('participants', arrayContains: widget.userEmail)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pesan. Mulailah percakapan!'),
                  );
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                    messages[index].data() as Map<String, dynamic>; // Konversi ke Map
                    final isSender = data['sender'] == 'Admin';

                    return Align(
                      alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data['text'] ?? '',
                          style: TextStyle(
                              color: isSender ? Colors.white : Colors.black),
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
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(),
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

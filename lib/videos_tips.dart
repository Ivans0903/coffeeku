import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'youtube_player_page.dart';

class VideosTipsPage extends StatefulWidget {
  const VideosTipsPage({super.key});

  @override
  _VideosTipsPageState createState() => _VideosTipsPageState();
}

class _VideosTipsPageState extends State<VideosTipsPage> {
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  /// Memuat daftar video dari file JSON
  Future<void> _loadVideos() async {
    final String response = await rootBundle.loadString('assets/videos.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      videos = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: videos.isEmpty
          ? const Center(
        child: CircularProgressIndicator(), // Loading jika data belum dimuat
      )
          : ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                video['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.play_arrow, size: 30),
              onTap: () {
                // Navigasi ke halaman YouTube Player untuk memutar video
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YouTubePlayerPage(
                      videoId: video['url'],
                      title: video['title'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

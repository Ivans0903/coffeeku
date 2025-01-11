import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class YouTubePlayerPage extends StatefulWidget {
  final String videoId;
  final String title;

  const YouTubePlayerPage({super.key, required this.videoId, required this.title});

  @override
  _YouTubePlayerPageState createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk maju 5 detik
  void _seekForward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition + const Duration(seconds: 5);
    _controller.seekTo(newPosition);
  }

  // Fungsi untuk mundur 5 detik
  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 5);
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        // Memasukkan mode fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      onExitFullScreen: () {
        // Keluar dari mode fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        // Menambahkan tombol di area bawah video
        bottomActions: [
          IconButton(
            icon: const Icon(Icons.replay_5, color: Colors.white),
            onPressed: _seekBackward,
          ),
          const CurrentPosition(),
          const ProgressBar(isExpanded: true),
          const RemainingDuration(),
          IconButton(
            icon: const Icon(Icons.forward_5, color: Colors.white),
            onPressed: _seekForward,
          ),
          FullScreenButton(
            controller: _controller,
          ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }
}

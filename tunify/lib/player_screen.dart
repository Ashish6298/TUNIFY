import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayerScreen extends StatefulWidget {
  final Map<String, dynamic> song;

  PlayerScreen({required this.song});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _audioPlayer.positionStream.listen((p) {
      setState(() => position = p);
    });
    _audioPlayer.durationStream.listen((d) {
      setState(() => duration = d ?? Duration.zero);
    });
  }

  Future<void> _initPlayer() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/stream/${widget.song['id']}'),
      );
      if (response.statusCode == 200) {
        final streamData = jsonDecode(response.body);
        await _audioPlayer.setUrl(streamData['url']);
        await _audioPlayer.play();
        setState(() => isPlaying = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading song: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song['title'] ?? 'Unknown Title'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art
            Container(
              width: 250,
              height: 250,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(widget.song['thumbnail'] ?? ''),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) => Icon(Icons.music_note),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Song title and artist
            Text(
              widget.song['title'] ?? 'Unknown Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              widget.song['author'] ?? 'Unknown Artist',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 30),
            // Progress slider
            Slider(
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              onChanged: (value) async {
                await _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            // Position and duration
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10),
                  iconSize: 36,
                  onPressed: () => _audioPlayer.seek(
                    position - Duration(seconds: 10),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 48,
                    onPressed: () async {
                      if (isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play();
                      }
                      setState(() => isPlaying = !isPlaying);
                    },
                  ),
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.forward_10),
                  iconSize: 36,
                  onPressed: () => _audioPlayer.seek(
                    position + Duration(seconds: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
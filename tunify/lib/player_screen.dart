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
        Uri.parse('https://tunify-ztgw.onrender.com/stream/${widget.song['id']}'),
      );
      if (response.statusCode == 200) {
        final streamData = jsonDecode(response.body);
        await _audioPlayer.setUrl(streamData['url']);
        await _audioPlayer.play();
        setState(() => isPlaying = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('TRANSMISSION ERROR: $e'),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  Future<void> _addToPlaylist() async {
    try {
      final response = await http.post(
        Uri.parse('https://tunify-ztgw.onrender.com/playlist/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.song),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Song added to playlist'),
            backgroundColor: Colors.teal[700],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add song: ${response.statusCode}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to playlist: $e'),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TUNIFY',
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 2,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.tealAccent.withOpacity(0.5), blurRadius: 10),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.blueGrey[800]!,
              Colors.teal[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.tealAccent.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: widget.song['thumbnail'] != null
                            ? Image.network(
                                widget.song['thumbnail'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800]!.withOpacity(0.5),
                                    child: Center(
                                      child: Text(
                                        'VISUAL DATA LOST',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[800]!.withOpacity(0.5),
                                child: Center(
                                  child: Text(
                                    'NO VISUAL DATA',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      widget.song['title']?.toUpperCase() ?? 'UNKNOWN TRANSMISSION',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.tealAccent.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.song['author']?.toUpperCase() ?? 'UNIDENTIFIED SOURCE',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        letterSpacing: 2,
                        fontFamily: 'Courier',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addToPlaylist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.playlist_add, color: Colors.grey[900]),
                          SizedBox(width: 8),
                          Text(
                            'Add to Playlist',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 2,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                              activeTrackColor: Colors.tealAccent,
                              inactiveTrackColor: Colors.grey[600]!.withOpacity(0.3),
                              thumbColor: Colors.white,
                              overlayColor: Colors.tealAccent.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble() > 0
                                  ? duration.inSeconds.toDouble()
                                  : 1.0,
                              onChanged: (value) async {
                                await _audioPlayer.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          icon: Icons.replay_10,
                          onPressed: () =>
                              _audioPlayer.seek(position - Duration(seconds: 10)),
                        ),
                        SizedBox(width: 30),
                        _buildControlButton(
                          icon: isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 50,
                          onPressed: () async {
                            if (isPlaying) {
                              await _audioPlayer.pause();
                            } else {
                              await _audioPlayer.play();
                            }
                            setState(() => isPlaying = !isPlaying);
                          },
                          isMainButton: true,
                        ),
                        SizedBox(width: 30),
                        _buildControlButton(
                          icon: Icons.forward_10,
                          onPressed: () =>
                              _audioPlayer.seek(position + Duration(seconds: 10)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 36,
    bool isMainButton = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMainButton ? Colors.black : Colors.black,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size,
        onPressed: onPressed,
        padding: EdgeInsets.all(isMainButton ? 16 : 12),
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
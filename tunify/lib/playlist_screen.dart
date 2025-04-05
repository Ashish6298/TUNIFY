import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'player_screen.dart';

class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<dynamic> playlistSongs = [];

  @override
  void initState() {
    super.initState();
    fetchPlaylist();
  }

  Future<void> fetchPlaylist() async {
    try {
      final response = await http.get(Uri.parse('https://tunify-ztgw.onrender.com/playlist'));
      if (response.statusCode == 200) {
        setState(() {
          playlistSongs = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load playlist: ${response.statusCode}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading playlist: $e'),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  void _navigateToPlayer(Map<String, dynamic> song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(song: song),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PLAYLIST',
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.tealAccent.withOpacity(0.5),
                blurRadius: 10,
              ),
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
        child: playlistSongs.isEmpty
            ? Center(
                child: Text(
                  'Your Playlist is Empty',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[400],
                    letterSpacing: 1.5,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: playlistSongs.length,
                itemBuilder: (context, index) {
                  final song = playlistSongs[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[850]!.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        song['title'] ?? 'Unknown Track',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        song['author'] ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      leading: song['thumbnail'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song['thumbnail'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.tealAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.music_off,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.music_off,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                      onTap: () => _navigateToPlayer(song),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
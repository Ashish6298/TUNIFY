import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'player_screen.dart';

class CollectionScreen extends StatefulWidget {
  final String collectionName;
  final String keyword;

  CollectionScreen({required this.collectionName, required this.keyword});

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<dynamic> songs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final endpoint = widget.keyword.contains('top songs')
          ? 'http://10.0.2.2:3000/top-songs'
          : 'http://10.0.2.2:3000/collection-songs?keyword=${Uri.encodeComponent(widget.keyword)}';

      final response = await http.get(
        Uri.parse(endpoint),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          songs = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load songs: ${response.statusCode}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading songs: $e'),
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
          widget.collectionName.toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 4,
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                ),
              )
            : songs.isEmpty
                ? Center(
                    child: Text(
                      'NO SONGS FOUND',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.collectionName == 'Top 100 Songs')
                                Text(
                                  '${index + 1}.',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (widget.collectionName == 'Top 100 Songs') SizedBox(width: 8),
                              song['thumbnail'] != null
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
                                          color: Colors.tealAccent.withOpacity(0.3),
                                          child: Center(
                                            child: Icon(
                                              Icons.music_off,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.tealAccent.withOpacity(0.3),
                                      child: Center(
                                        child: Icon(
                                          Icons.music_off,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          title: Text(
                            song['title'] ?? 'UNKNOWN TRACK',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${song['author'] ?? 'UNKNOWN ARTIST'} • ${song['duration'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                          trailing: Text(
                            song['publishedAt'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
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
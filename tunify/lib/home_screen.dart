
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:retry/retry.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> latestSongs = [];
  List<dynamic> searchResults = [];
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    fetchLatestSongs();
  }

  Future<void> fetchLatestSongs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await retry(
        () => http.get(Uri.parse('http://10.0.2.2:3000/recommendations')).timeout(Duration(seconds: 30)),
        maxAttempts: 3,
        delayFactor: Duration(seconds: 2),
      );

      if (response.statusCode == 200) {
        setState(() {
          latestSongs = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load recommendations: ${response.statusCode}'),
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
          content: Text('Error loading recommendations: $e'),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/search?q=$query'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          searchResults = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${response.statusCode}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching songs: $e'),
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

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        searchResults = [];
      }
    });
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
        child: Column(
          children: [
            if (_isSearchActive)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'SEARCH MUSIC',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[800]!.withOpacity(0.7),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchResults = [];
                              });
                            },
                          ),
                        ),
                        onSubmitted: (value) => searchSongs(value),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          searchSongs(_searchController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, color: Colors.grey[900]),
                          SizedBox(width: 8),
                          Text(
                            'SCAN',
                            style: TextStyle(
                              color: Colors.grey[900],
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!_isSearchActive)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'LATEST RELEASES',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Text(
                              'LOADING LATEST HITS',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.tealAccent.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        ],
                      ),
                    )
                  : (_isSearchActive && searchResults.isEmpty && _searchController.text.isEmpty)
                      ? Center(
                          child: Text(
                            'START TYPING TO SEARCH',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        )
                      : (_isSearchActive && searchResults.isEmpty && _searchController.text.isNotEmpty)
                          ? Center(
                              child: Text(
                                'NO RESULTS FOUND',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _isSearchActive ? searchResults.length : latestSongs.length,
                              itemBuilder: (context, index) {
                                final song = _isSearchActive ? searchResults[index] : latestSongs[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800]!.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                                  ),
                                  child: ListTile(
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
                                    trailing: _isSearchActive
                                        ? null
                                        : Text(
                                            song['publishedAt'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                    leading: song['thumbnail'] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              song['thumbnail'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
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
                                    onTap: () => _navigateToPlayer(song),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(
              color: Colors.tealAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _isSearchActive ? Colors.white : Colors.tealAccent,
                size: 30,
              ),
              onPressed: () {
                if (_isSearchActive) {
                  _toggleSearch();
                } else {
                  fetchLatestSongs();
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: _isSearchActive ? Colors.tealAccent : Colors.white,
                size: 30,
              ),
              onPressed: _toggleSearch,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
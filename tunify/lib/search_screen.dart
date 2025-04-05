import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> searchResults = [];
  TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

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
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Darker, more readable background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TUNIFY',
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 4,
            color: Colors.white, // Brighter text for contrast
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
              Colors.grey[900]!, // Dark grey base
              Colors.blueGrey[800]!, // Subtle blue-grey transition
              Colors.teal[700]!, // Teal accent at bottom
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white), // White text for readability
                      decoration: InputDecoration(
                        hintText: 'SEARCH MUSIC',
                        hintStyle: TextStyle(color: Colors.grey[400]), // Lighter hint text
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
                        fillColor: Colors.grey[800]!.withOpacity(0.7), // Darker fill for contrast
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
                      backgroundColor: Colors.tealAccent, // Brighter accent color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, color: Colors.grey[900]), // Dark icon for contrast
                        SizedBox(width: 8),
                        Text(
                          'SCAN',
                          style: TextStyle(
                            color: Colors.grey[900], // Dark text on bright button
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Text(
                              'AWAITING INPUT',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white, // White for better visibility
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
                          Container(
                            width: 100,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.tealAccent.withOpacity(0.5),
                                  Colors.white,
                                  Colors.tealAccent.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final video = searchResults[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[800]!.withOpacity(0.8), // Darker card background
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                          ),
                          child: ListTile(
                            title: Text(
                              video['title'] ?? 'UNKNOWN TRANSMISSION',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white, // White for readability
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              video['author'] ?? 'UNIDENTIFIED SOURCE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[300]), // Lighter grey for contrast
                            ),
                            leading: video['thumbnail'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      video['thumbnail'],
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
                                            Icons.signal_wifi_off,
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
                                        Icons.signal_wifi_off,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                            onTap: () => _navigateToPlayer(video),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
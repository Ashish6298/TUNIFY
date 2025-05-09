// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'player_screen.dart';

// class CollectionScreen extends StatefulWidget {
//   final String collectionName;
//   final String keyword;
//   final List<dynamic> initialSongs; // Pass initial songs from HomeScreen (now up to 25)

//   CollectionScreen({required this.collectionName, required this.keyword, required this.initialSongs});

//   @override
//   _CollectionScreenState createState() => _CollectionScreenState();
// }

// class _CollectionScreenState extends State<CollectionScreen> {
//   List<dynamic> songs = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Use initialSongs if available (now up to 25 songs)
//     setState(() {
//       songs = widget.initialSongs;
//       _isLoading = false;
//     });
//   }

//   void _navigateToPlayer(Map<String, dynamic> song) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PlayerScreen(song: song),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           widget.collectionName.toUpperCase(),
//           style: TextStyle(
//             fontSize: 24,
//             letterSpacing: 2,
//             color: Colors.white,
//             shadows: [
//               Shadow(
//                 color: Colors.tealAccent.withOpacity(0.5),
//                 blurRadius: 10,
//               ),
//             ],
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.grey[900]!,
//               Colors.blueGrey[800]!,
//               Colors.teal[700]!,
//             ],
//           ),
//         ),
//         child: songs.isEmpty
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'NO SONGS FOUND',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                         letterSpacing: 2,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Failed to load songs: 404',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.red[900],
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 itemCount: songs.length, // Now handles up to 25 songs
//                 itemBuilder: (context, index) {
//                   final song = songs[index];
//                   return Container(
//                     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[800]!.withOpacity(0.8),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         song['title'] ?? 'UNKNOWN TRACK',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       subtitle: Text(
//                         song['author'] ?? 'UNKNOWN ARTIST',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(color: Colors.grey[300]),
//                       ),
//                       leading: song['thumbnail'] != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 song['thumbnail'],
//                                 width: 50,
//                                 height: 50,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) => Container(
//                                   width: 50,
//                                   height: 50,
//                                   color: Colors.tealAccent.withOpacity(0.3),
//                                   child: Center(
//                                     child: Icon(
//                                       Icons.music_off,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               width: 50,
//                               height: 50,
//                               color: Colors.tealAccent.withOpacity(0.3),
//                               child: Center(
//                                 child: Icon(
//                                   Icons.music_off,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                       onTap: () => _navigateToPlayer(song),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }










import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'player_screen.dart';

class CollectionScreen extends StatefulWidget {
  final String collectionName;
  final String keyword;
  final List<dynamic> initialSongs; // Pass initial songs from HomeScreen (up to 25)

  CollectionScreen({
    required this.collectionName,
    required this.keyword,
    required this.initialSongs,
  });

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<dynamic> songs = [];
  bool _isLoading = false;

  // Define the EC2 backend URL
  static const String baseUrl = 'http://16.171.52.170:3000';

  @override
  void initState() {
    super.initState();
    // Use initialSongs if available (up to 25 songs)
    setState(() {
      songs = widget.initialSongs;
      _isLoading = false;
    });
  }

  // Placeholder for fetching songs dynamically (uncomment if needed)
  
  Future<void> fetchSongs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collection?keyword=${widget.keyword}'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          songs = jsonDecode(response.body)['songs'];
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                  strokeWidth: 3,
                ),
              )
            : songs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NO SONGS FOUND',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Failed to load songs: 404',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[900],
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: songs.length, // Handles up to 25 songs
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
                            song['author'] ?? 'UNKNOWN ARTIST',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[300]),
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
    );
  }
}
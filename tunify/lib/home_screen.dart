// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:just_audio/just_audio.dart';
// import 'package:retry/retry.dart';
// import 'player_screen.dart';
// import 'collection_screen.dart';
// import 'playlist_screen.dart'; // New import for PlaylistScreen

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   List<dynamic> collections = [];
//   List<dynamic> searchResults = [];
//   late AnimationController _controller;
//   late Animation<double> _pulseAnimation;
//   TextEditingController _searchController = TextEditingController();
//   bool _isSearchActive = false;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);
    
//     _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
    
//     fetchCollections();
//   }

//   Future<void> fetchCollections() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await retry(
//         () => http.get(Uri.parse('https://tunify-ztgw.onrender.com/collections')).timeout(Duration(seconds: 30)),
//         maxAttempts: 3,
//         delayFactor: Duration(seconds: 2),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           collections = jsonDecode(response.body);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load collections: ${response.statusCode}'),
//             backgroundColor: Colors.red[900],
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading collections: $e'),
//           backgroundColor: Colors.red[900],
//         ),
//       );
//     }
//   }

//   Future<void> searchSongs(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         searchResults = [];
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('https://tunify-ztgw.onrender.com/search?q=$query'),
//       ).timeout(Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         setState(() {
//           searchResults = jsonDecode(response.body);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Search failed: ${response.statusCode}'),
//             backgroundColor: Colors.red[900],
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error searching songs: $e'),
//           backgroundColor: Colors.red[900],
//         ),
//       );
//     }
//   }

//   void _navigateToPlayer(Map<String, dynamic> song) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PlayerScreen(song: song),
//       ),
//     );
//   }

//   void _navigateToCollection(String name, String keyword) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CollectionScreen(
//           collectionName: name,
//           keyword: keyword,
//           initialSongs: collections.firstWhere((c) => c['name'] == name)['songs'],
//         ),
//       ),
//     );
//   }

//   void _navigateToPlaylist() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PlaylistScreen(),
//       ),
//     );
//   }

//   void _toggleSearch() {
//     setState(() {
//       _isSearchActive = !_isSearchActive;
//       if (!_isSearchActive) {
//         _searchController.clear();
//         searchResults = [];
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'TUNIFY',
//           style: TextStyle(
//             fontSize: 26,
//             letterSpacing: 5,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             shadows: [
//               Shadow(
//                 color: Colors.tealAccent.withOpacity(0.6),
//                 blurRadius: 12,
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
//               Colors.blueGrey[900]!,
//               Colors.teal[800]!,
//             ],
//           ),
//         ),
//         child: Column(
//           children: [
//             if (_isSearchActive)
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                         decoration: InputDecoration(
//                           hintText: 'Search Music',
//                           hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: Colors.tealAccent, width: 1.5),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[850]!.withOpacity(0.9),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                           suffixIcon: IconButton(
//                             icon: Icon(Icons.clear, color: Colors.grey[400]),
//                             onPressed: () {
//                               _searchController.clear();
//                               setState(() {
//                                 searchResults = [];
//                               });
//                             },
//                           ),
//                         ),
//                         onSubmitted: (value) => searchSongs(value),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (_searchController.text.isNotEmpty) {
//                           searchSongs(_searchController.text);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.tealAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//                         elevation: 4,
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.search, color: Colors.grey[900], size: 20),
//                           SizedBox(width: 6),
//                           Text(
//                             'Scan',
//                             style: TextStyle(
//                               color: Colors.grey[900],
//                               letterSpacing: 1.5,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             Expanded(
//               child: _isSearchActive
//                   ? (_searchController.text.isEmpty && searchResults.isEmpty)
//                       ? Center(
//                           child: Text(
//                             'Start Typing to Search',
//                             style: TextStyle(
//                               fontSize: 22,
//                               color: Colors.grey[400],
//                               letterSpacing: 1.5,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         )
//                       : (searchResults.isEmpty)
//                           ? Center(
//                               child: Text(
//                                 'No Results Found',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   color: Colors.grey[400],
//                                   letterSpacing: 1.5,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: searchResults.length,
//                               itemBuilder: (context, index) {
//                                 final song = searchResults[index];
//                                 return Container(
//                                   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[850]!.withOpacity(0.9),
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.2),
//                                         blurRadius: 6,
//                                         offset: Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: ListTile(
//                                     title: Text(
//                                       song['title'] ?? 'Unknown Track',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       song['author'] ?? 'Unknown Artist',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                                     ),
//                                     leading: song['thumbnail'] != null
//                                         ? ClipRRect(
//                                             borderRadius: BorderRadius.circular(8),
//                                             child: Image.network(
//                                               song['thumbnail'],
//                                               width: 50,
//                                               height: 50,
//                                               fit: BoxFit.cover,
//                                               errorBuilder: (context, error, stackTrace) =>
//                                                   Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.tealAccent.withOpacity(0.2),
//                                                   borderRadius: BorderRadius.circular(8),
//                                                 ),
//                                                 child: Center(
//                                                   child: Icon(
//                                                     Icons.music_off,
//                                                     color: Colors.grey[400],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Container(
//                                             width: 50,
//                                             height: 50,
//                                             decoration: BoxDecoration(
//                                               color: Colors.tealAccent.withOpacity(0.2),
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: Center(
//                                               child: Icon(
//                                                 Icons.music_off,
//                                                 color: Colors.grey[400],
//                                               ),
//                                             ),
//                                           ),
//                                     onTap: () => _navigateToPlayer(song),
//                                   ),
//                                 );
//                               },
//                             )
//                   : _isLoading
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ScaleTransition(
//                                 scale: _pulseAnimation,
//                                 child: Text(
//                                   'Loading Collections',
//                                   style: TextStyle(
//                                     fontSize: 26,
//                                     color: Colors.white,
//                                     letterSpacing: 2,
//                                     fontWeight: FontWeight.bold,
//                                     shadows: [
//                                       Shadow(
//                                         color: Colors.tealAccent.withOpacity(0.4),
//                                         blurRadius: 12,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 24),
//                               CircularProgressIndicator(
//                                 color: Colors.tealAccent,
//                                 strokeWidth: 3,
//                               ),
//                             ],
//                           ),
//                         )
//                       : ListView.builder(
//                           itemCount: collections.length,
//                           itemBuilder: (context, index) {
//                             final collection = collections[index];
//                             final songs = collection['songs'] as List<dynamic>;

//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     if (songs.isNotEmpty) {
//                                       if (songs.length > 1) {
//                                         _navigateToCollection(collection['name'], collection['keyword']);
//                                       } else {
//                                         _navigateToPlayer(songs[0]);
//                                       }
//                                     }
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
//                                     margin: EdgeInsets.only(top: 12),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           Colors.tealAccent.withOpacity(0.1),
//                                           Colors.transparent,
//                                         ],
//                                         begin: Alignment.centerLeft,
//                                         end: Alignment.centerRight,
//                                       ),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           collection['name'].toUpperCase(),
//                                           style: TextStyle(
//                                             fontSize: 20,
//                                             color: Colors.white,
//                                             letterSpacing: 2,
//                                             fontWeight: FontWeight.bold,
//                                             shadows: [
//                                               Shadow(
//                                                 color: Colors.tealAccent.withOpacity(0.3),
//                                                 blurRadius: 6,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Row(
//                                           children: [
//                                             if (collection['name'] == 'Top 100 Songs')
//                                               Text(
//                                                 '100 Songs',
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors.grey[500],
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             SizedBox(width: 8),
//                                             Icon(
//                                               songs.length > 1
//                                                   ? Icons.arrow_forward_ios
//                                                   : Icons.play_arrow,
//                                               color: Colors.tealAccent,
//                                               size: 22,
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 200,
//                                   child: songs.isEmpty
//                                       ? Center(
//                                           child: Text(
//                                             'No Songs Available',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.grey[500],
//                                               letterSpacing: 1.2,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         )
//                                       : ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount: songs.length > 3 ? 3 : songs.length,
//                                           itemBuilder: (context, songIndex) {
//                                             final song = songs[songIndex];
//                                             return Container(
//                                               width: 150,
//                                               margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//                                               child: GestureDetector(
//                                                 onTap: () => _navigateToPlayer(song),
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Container(
//                                                       decoration: BoxDecoration(
//                                                         borderRadius: BorderRadius.circular(12),
//                                                         boxShadow: [
//                                                           BoxShadow(
//                                                             color: Colors.black.withOpacity(0.2),
//                                                             blurRadius: 6,
//                                                             offset: Offset(0, 2),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       child: song['thumbnail'] != null
//                                                           ? ClipRRect(
//                                                               borderRadius: BorderRadius.circular(12),
//                                                               child: Image.network(
//                                                                 song['thumbnail'],
//                                                                 width: 150,
//                                                                 height: 120,
//                                                                 fit: BoxFit.cover,
//                                                                 errorBuilder: (context, error, stackTrace) =>
//                                                                     Container(
//                                                                   width: 150,
//                                                                   height: 120,
//                                                                   decoration: BoxDecoration(
//                                                                     color: Colors.tealAccent.withOpacity(0.2),
//                                                                     borderRadius: BorderRadius.circular(12),
//                                                                   ),
//                                                                   child: Center(
//                                                                     child: Icon(
//                                                                       Icons.music_off,
//                                                                       color: Colors.grey[400],
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             )
//                                                           : Container(
//                                                               width: 150,
//                                                               height: 120,
//                                                               decoration: BoxDecoration(
//                                                                 color: Colors.tealAccent.withOpacity(0.2),
//                                                                 borderRadius: BorderRadius.circular(12),
//                                                               ),
//                                                               child: Center(
//                                                                 child: Icon(
//                                                                   Icons.music_off,
//                                                                   color: Colors.grey[400],
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                     ),
//                                                     SizedBox(height: 8),
//                                                     Text(
//                                                       song['title'] ?? 'Unknown Track',
//                                                       maxLines: 1,
//                                                       overflow: TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight: FontWeight.w600,
//                                                         fontSize: 14,
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       song['author'] ?? 'Unknown Artist',
//                                                       maxLines: 1,
//                                                       overflow: TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                         color: Colors.grey[400],
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         height: 70,
//         decoration: BoxDecoration(
//           color: Colors.grey[900],
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 8,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             IconButton(
//               icon: Icon(
//                 Icons.home,
//                 color: _isSearchActive ? Colors.grey[400] : Colors.tealAccent,
//                 size: 32,
//               ),
//               onPressed: () {
//                 if (_isSearchActive) {
//                   _toggleSearch();
//                 } else {
//                   fetchCollections();
//                 }
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.search,
//                 color: _isSearchActive ? Colors.tealAccent : Colors.grey[400],
//                 size: 32,
//               ),
//               onPressed: _toggleSearch,
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.playlist_play,
//                 color: Colors.grey[400],
//                 size: 32,
//               ),
//               onPressed: _navigateToPlaylist,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _audioPlayer.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }


















import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:retry/retry.dart';
import 'player_screen.dart';
import 'collection_screen.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> collections = [];
  List<dynamic> searchResults = [];
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  bool _isLoading = false;

  // Define the EC2 backend URL
  static const String baseUrl = 'http://16.171.52.170:3000';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    fetchCollections();
  }

  Future<void> fetchCollections() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await retry(
        () => http.get(Uri.parse('$baseUrl/collections')).timeout(Duration(seconds: 30)),
        maxAttempts: 3,
        delayFactor: Duration(seconds: 2),
      );

      if (response.statusCode == 200) {
        setState(() {
          collections = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load collections: ${response.statusCode}'),
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
          content: Text('Error loading collections: $e'),
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
        Uri.parse('$baseUrl/search?q=$query'),
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

  void _navigateToCollection(String name, String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionScreen(
          collectionName: name,
          keyword: keyword,
          initialSongs: collections.firstWhere((c) => c['name'] == name)['songs'],
        ),
      ),
    );
  }

  void _navigateToPlaylist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistScreen(),
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
            fontSize: 26,
            letterSpacing: 5,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.tealAccent.withOpacity(0.6),
                blurRadius: 12,
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
              Colors.blueGrey[900]!,
              Colors.teal[800]!,
            ],
          ),
        ),
        child: Column(
          children: [
            if (_isSearchActive)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search Music',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.tealAccent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey[850]!.withOpacity(0.9),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, color: Colors.grey[900], size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Scan',
                            style: TextStyle(
                              color: Colors.grey[900],
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isSearchActive
                  ? (_searchController.text.isEmpty && searchResults.isEmpty)
                      ? Center(
                          child: Text(
                            'Start Typing to Search',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey[400],
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : (searchResults.isEmpty)
                          ? Center(
                              child: Text(
                                'No Results Found',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey[400],
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final song = searchResults[index];
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
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
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
                            )
                  : _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Text(
                                  'Loading Collections',
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.tealAccent.withOpacity(0.4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              CircularProgressIndicator(
                                color: Colors.tealAccent,
                                strokeWidth: 3,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: collections.length,
                          itemBuilder: (context, index) {
                            final collection = collections[index];
                            final songs = collection['songs'] as List<dynamic>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (songs.isNotEmpty) {
                                      if (songs.length > 1) {
                                        _navigateToCollection(collection['name'], collection['keyword']);
                                      } else {
                                        _navigateToPlayer(songs[0]);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                                    margin: EdgeInsets.only(top: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.tealAccent.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          collection['name'].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.tealAccent.withOpacity(0.3),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if (collection['name'] == 'Top 100 Songs')
                                              Text(
                                                '100 Songs',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[500],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            SizedBox(width: 8),
                                            Icon(
                                              songs.length > 1
                                                  ? Icons.arrow_forward_ios
                                                  : Icons.play_arrow,
                                              color: Colors.tealAccent,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 200,
                                  child: songs.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No Songs Available',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[500],
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: songs.length > 3 ? 3 : songs.length,
                                          itemBuilder: (context, songIndex) {
                                            final song = songs[songIndex];
                                            return Container(
                                              width: 150,
                                              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                              child: GestureDetector(
                                                onTap: () => _navigateToPlayer(song),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            blurRadius: 6,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: song['thumbnail'] != null
                                                          ? ClipRRect(
                                                              borderRadius: BorderRadius.circular(12),
                                                              child: Image.network(
                                                                song['thumbnail'],
                                                                width: 150,
                                                                height: 120,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) =>
                                                                    Container(
                                                                  width: 150,
                                                                  height: 120,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.tealAccent.withOpacity(0.2),
                                                                    borderRadius: BorderRadius.circular(12),
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
                                                              width: 150,
                                                              height: 120,
                                                              decoration: BoxDecoration(
                                                                color: Colors.tealAccent.withOpacity(0.2),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.music_off,
                                                                  color: Colors.grey[400],
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      song['title'] ?? 'Unknown Track',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      song['author'] ?? 'Unknown Artist',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _isSearchActive ? Colors.grey[400] : Colors.tealAccent,
                size: 32,
              ),
              onPressed: () {
                if (_isSearchActive) {
                  _toggleSearch();
                } else {
                  fetchCollections();
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: _isSearchActive ? Colors.tealAccent : Colors.grey[400],
                size: 32,
              ),
              onPressed: _toggleSearch,
            ),
            IconButton(
              icon: Icon(
                Icons.playlist_play,
                color: Colors.grey[400],
                size: 32,
              ),
              onPressed: _navigateToPlaylist,
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
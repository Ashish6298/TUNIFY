const express = require("express");
const cors = require("cors");
const ytdl = require("@distube/ytdl-core");
const youtubeSearch = require("youtube-search-api");
require("dotenv").config(); // Add this at the top of server.js
const app = express();
const port = 3000;

// In-memory playlist storage
const playlistSongs = new Set();

// Middleware
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type"],
  })
);
app.use(express.json()); // Parse JSON bodies

// Search endpoint
app.get("/search", async (req, res) => {
  const query = req.query.q;

  if (!query) {
    return res.status(400).json({
      success: false,
      error: 'Query parameter "q" is required',
    });
  }

  try {
    console.log(`Searching for: ${query}`);
    const result = await youtubeSearch.GetListByKeyword(query, false, 10, [
      { type: "video" },
    ]);

    if (!result?.items?.length) {
      return res.status(404).json({
        success: false,
        error: "No search results found",
      });
    }

    const results = result.items.map((item) => ({
      id: item.id,
      title: item.title || "Unknown Title",
      author: item.channelTitle || "Unknown Channel",
      thumbnail: item.thumbnail?.thumbnails?.[0]?.url || "",
    }));

    console.log(`Found ${results.length} results`);
    res.json(results);
  } catch (error) {
    console.error("Search error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to search YouTube",
      details: error.message,
    });
  }
});

// Recommendations endpoint
app.get("/recommendations", async (req, res) => {
  try {
    console.log("Fetching latest song recommendations");
    const currentYear = new Date().getFullYear();
    const result = await youtubeSearch.GetListByKeyword(
      `new music releases ${currentYear}`,
      false,
      20,
      [{ type: "video" }]
    );

    if (!result?.items?.length) {
      return res.status(404).json({
        success: false,
        error: "No recommendations found",
      });
    }

    const recommendations = result.items.map((item) => ({
      id: item.id,
      title: item.title || "Unknown Title",
      author: item.channelTitle || "Unknown Channel",
      thumbnail: item.thumbnail?.thumbnails?.[0]?.url || "",
      duration: item.length?.simpleText || "Unknown Duration",
      publishedAt: item.publishedTime || "Unknown Date",
    }));

    recommendations.sort((a, b) => {
      if (!a.publishedAt || !b.publishedAt) return 0;
      return new Date(b.publishedAt) - new Date(a.publishedAt);
    });

    console.log(`Found ${recommendations.length} latest songs`);
    res.json(recommendations);
  } catch (error) {
    console.error("Recommendations error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch recommendations",
      details: error.message,
    });
  }
});

// Stream endpoint
// app.get("/stream/:videoId", async (req, res) => {
//   const videoId = req.params.videoId;

//   if (!videoId) {
//     return res.status(400).json({
//       success: false,
//       error: "Video ID is required",
//     });
//   }

//   try {
//     console.log(`Fetching audio stream for video ID: ${videoId}`);
//     const url = `https://www.youtube.com/watch?v=${videoId}`;

//     if (!ytdl.validateID(videoId)) {
//       return res.status(400).json({
//         success: false,
//         error: "Invalid video ID",
//       });
//     }

//     // Load cookies from .env and parse the JSON string
//     const cookies = JSON.parse(process.env.YOUTUBE_COOKIES);

//     const info = await ytdl.getInfo(url, {
//       requestOptions: {
//         headers: {
//           "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
//           "Accept-Language": "en-US,en;q=0.9",
//           "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
//         },
//         cookies: cookies, // Use cookies from .env
//       },
//     });

//     const audioFormat = ytdl.chooseFormat(info.formats, {
//       filter: "audioonly",
//       quality: "highestaudio",
//     });

//     if (!audioFormat) {
//       return res.status(404).json({
//         success: false,
//         error: "No audio stream available for this video",
//       });
//     }

//     console.log(`Audio stream URL generated for ${videoId}`);
//     res.json({
//       success: true,
//       url: audioFormat.url,
//     });
//   } catch (error) {
//     console.error("Stream error:", error.message, error.stack);
//     res.status(500).json({
//       success: false,
//       error: "Failed to fetch audio stream",
//       details: error.message,
//     });
//   }
// });






app.get("/stream/:videoId", async (req, res) => {
  const videoId = req.params.videoId;

  if (!videoId) {
    return res.status(400).json({
      success: false,
      error: "Video ID is required",
    });
  }

  try {
    console.log(`Fetching audio stream for video ID: ${videoId}`);
    const url = `https://www.youtube.com/watch?v=${videoId}`;

    if (!ytdl.validateID(videoId)) {
      return res.status(400).json({
        success: false,
        error: "Invalid video ID",
      });
    }

    // Load cookies from .env, fallback to empty array if not set
    let cookies = [];
    if (process.env.YOUTUBE_COOKIES) {
      try {
        cookies = JSON.parse(process.env.YOUTUBE_COOKIES);
      } catch (parseError) {
        console.error("Failed to parse YOUTUBE_COOKIES:", parseError.message);
        return res.status(500).json({
          success: false,
          error: "Invalid cookie configuration",
          details: parseError.message,
        });
      }
    } else {
      console.warn("YOUTUBE_COOKIES not set, proceeding without cookies");
    }

    const info = await ytdl.getInfo(url, {
      requestOptions: {
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
          "Accept-Language": "en-US,en;q=0.9",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        },
        cookies: cookies, // Use cookies if available, otherwise empty array
      },
    });

    const audioFormat = ytdl.chooseFormat(info.formats, {
      filter: "audioonly",
      quality: "highestaudio",
    });

    if (!audioFormat) {
      return res.status(404).json({
        success: false,
        error: "No audio stream available for this video",
      });
    }

    console.log(`Audio stream URL generated for ${videoId}`);
    res.json({
      success: true,
      url: audioFormat.url,
    });
  } catch (error) {
    console.error("Stream error:", error.message, error.stack);
    res.status(500).json({
      success: false,
      error: "Failed to fetch audio stream",
      details: error.message,
    });
  }
});





// Playlist endpoint (GET)
app.get("/playlist", (req, res) => {
  res.json(Array.from(playlistSongs));
});

// Playlist endpoint (POST)
app.post("/playlist/add", (req, res) => {
  const song = req.body;
  if (!song || !song.id) {
    return res.status(400).json({
      success: false,
      error: "Song data with an ID is required",
    });
  }

  // Add song to playlist (using Set to avoid duplicates based on object reference)
  playlistSongs.add({
    id: song.id,
    title: song.title || "Unknown Title",
    author: song.author || "Unknown Channel",
    thumbnail: song.thumbnail || "",
    duration: song.duration || "Unknown Duration",
    publishedAt: song.publishedAt || "Unknown Date",
  });

  console.log(`Added song to playlist: ${song.title}`);
  res.status(200).json({
    success: true,
    message: "Song added to playlist",
  });
});

// Collections endpoint
app.get("/collections", async (req, res) => {
  try {
    console.log("Fetching song collections");
    const currentYear = new Date().getFullYear();

    const collections = [
      { name: "Playlist", keyword: null }, // Add Playlist as a collection
      { name: "Top 100 Songs", keyword: `top songs ${currentYear}` },
      { name: "Romantics", keyword: `romantic songs ${currentYear}` },
      { name: "Raps", keyword: `best rap songs ${currentYear}` },
      { name: "Best of Yo Yo", keyword: `yo yo honey singh best songs` },
      { name: "Best of Karan Aujla", keyword: `karan aujla best songs` },
      { name: "Party Hits", keyword: `party songs ${currentYear}` },
      { name: "Bollywood Hits", keyword: `bollywood hits ${currentYear}` },
      { name: "Punjabi Beats", keyword: `punjabi songs ${currentYear}` },
      { name: "Chill Vibes", keyword: `chill songs ${currentYear}` },
      { name: "Sad Songs", keyword: `sad songs ${currentYear}` },
      { name: "90s Hits", keyword: `90s songs` },
      { name: "Indie Pop", keyword: `indie pop songs ${currentYear}` },
      { name: "Workout Jams", keyword: `workout songs ${currentYear}` },
      { name: "Love Ballads", keyword: `love ballads ${currentYear}` },
      { name: "Hip Hop Classics", keyword: `hip hop classics` },
      { name: "Kannada", keyword: `kannada songs ${currentYear}` },
      { name: "Punjabi", keyword: `punjabi songs ${currentYear}` },
      { name: "Haryanvi", keyword: `haryanvi songs ${currentYear}` },
      { name: "Tamil", keyword: `tamil songs ${currentYear}` },
      { name: "Malayalam", keyword: `malayalam songs ${currentYear}` },
    ];

    const collectionResults = await Promise.all(
      collections.map(async (collection) => {
        if (collection.name === "Playlist") {
          const songs = Array.from(playlistSongs);
          return {
            name: collection.name,
            songs: songs.length ? songs : [],
            keyword: collection.keyword,
          };
        }

        const result = await youtubeSearch.GetListByKeyword(
          collection.keyword,
          false,
          25,
          [{ type: "video" }]
        );

        if (!result?.items?.length) {
          return {
            name: collection.name,
            songs: [],
            keyword: collection.keyword,
          };
        }

        const songs = result.items.map((item) => ({
          id: item.id,
          title: item.title || "Unknown Title",
          author: item.channelTitle || "Unknown Channel",
          thumbnail: item.thumbnail?.thumbnails?.[0]?.url || "",
          duration: item.length?.simpleText || "Unknown Duration",
          publishedAt: item.publishedTime || "Unknown Date",
        }));

        songs.sort((a, b) => {
          if (!a.publishedAt || !b.publishedAt) return 0;
          return new Date(b.publishedAt) - new Date(a.publishedAt);
        });

        return { name: collection.name, songs, keyword: collection.keyword };
      })
    );

    console.log(`Fetched ${collectionResults.length} collections`);
    res.json(collectionResults);
  } catch (error) {
    console.error("Collections error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch collections",
      details: error.message,
    });
  }
});

// Top Songs endpoint
app.get("/top-songs", async (req, res) => {
  try {
    console.log("Fetching top 100 songs");
    const keyword = "top songs 2025";

    const result = await youtubeSearch.GetListByKeyword(
      keyword,
      false,
      100,
      [{ type: "video" }]
    );

    if (!result?.items?.length) {
      return res.json([]);
    }

    const songs = result.items.map((item) => ({
      id: item.id,
      title: item.title || "Unknown Title",
      author: item.channelTitle || "Unknown Channel",
      thumbnail: item.thumbnail?.thumbnails?.[0]?.url || "",
      duration: item.length?.simpleText || "Unknown Duration",
      publishedAt: item.publishedTime || "Unknown Date",
    }));

    songs.sort((a, b) => {
      if (!a.publishedAt || !b.publishedAt) return 0;
      return new Date(b.publishedAt) - new Date(a.publishedAt);
    });

    res.json(songs);
  } catch (error) {
    console.error("Top songs error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch top songs",
      details: error.message,
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Server error:", err);
  res.status(500).json({
    success: false,
    error: "Internal server error",
    details: err.message,
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log("Music streaming server initialized");
});
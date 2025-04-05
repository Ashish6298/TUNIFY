const express = require("express");
const cors = require("cors");
const ytdl = require("@distube/ytdl-core");
const youtubeSearch = require("youtube-search-api");

const app = express();
const port = 3000;

// Middleware
app.use(
  cors({
    origin: "*", // Adjust this in production to specific origins
    methods: ["GET"],
    allowedHeaders: ["Content-Type"],
  })
);

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

    // Sort by published date if available (newest first)
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

    // Validate video ID
    if (!ytdl.validateID(videoId)) {
      return res.status(400).json({
        success: false,
        error: "Invalid video ID",
      });
    }

    // Get video info with audio-only filter
    const info = await ytdl.getInfo(url, {
      requestOptions: {
        headers: {
          "User-Agent": "Mozilla/5.0", // Helps avoid some YouTube restrictions
        },
      },
    });

    // Choose audio-only format
    const audioFormat = ytdl.chooseFormat(info.formats, {
      filter: "audioonly",
      quality: "highestaudio", // Prioritize highest audio quality
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

// Collections endpoint (Updated to include "Top 100 Songs")
app.get("/collections", async (req, res) => {
  try {
    console.log("Fetching song collections");
    const currentYear = new Date().getFullYear();

    // Define collections with their search keywords, including "Top 100 Songs"
    const collections = [
      { name: "Top 100 Songs", keyword: `top songs ${currentYear}` }, // Added "Top 100 Songs"
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
    ];

    // Fetch songs for each collection
    const collectionResults = await Promise.all(
      collections.map(async (collection) => {
        const result = await youtubeSearch.GetListByKeyword(
          collection.keyword,
          false,
          5, // Limit to 5 songs per collection for initial display
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

        // Sort songs by published date (newest first)
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

// Top Songs endpoint (Unchanged)
app.get("/top-songs", async (req, res) => {
  try {
    console.log("Fetching top 100 songs");
    const keyword = "top songs 2025";

    const result = await youtubeSearch.GetListByKeyword(
      keyword,
      false,
      100, // Fetch 100 songs
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
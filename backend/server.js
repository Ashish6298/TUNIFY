const express = require("express");
const cors = require("cors");
const ytdl = require("@distube/ytdl-core");
const youtubeSearch = require("youtube-search-api");

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

    const info = await ytdl.getInfo(url, {
      requestOptions: {
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
          "Cookie": "LOGIN_INFO=AFmmF2swRQIhANTYGZboN2NzPvlzhQvpyNcmtCCTBASHJqABrPYxjKoDAiAGtCVMH59nWepY4G_W27Aeowfv6k839rcwuqMdgLKT-A:QUQ3MjNmekpGU3NTbUMxSFdWSVpKQ2dDNGpzZmRKU3JGWGo1a21qY0FvZkZXVVR0UVBTUHQwdTlPcDFZOXFtbWNlZHgtc0tFMDJNVGZIWVRtQmN0SUpQR3ZQZUhtMGJneHM3WmQ1NV8yUmo2eFFEeTVFVTVIb1A2cFZrZ2xlNk4ySjB2a0ZKNDJLc21wOUJ2WUZ0cnVpN3lsUkF6NGhfUGhn; PREF=tz=Asia.Calcutta&f4=4000000&f6=40000000&f5=20000&f7=100; SID=g.a000vQiP8ClOXSHM_7ueWaK9ujL2iMXZJ2dIb0jeq4-Hx_xhy0OWVoNFUI0zGWq-inkTnEiKnAACgYKAbUSARUSFQHGX2MieFgVkz-yje-dtK3woQWTrRoVAUF8yKrq1l2zlk2YekcNt8NsjLo70076; __Secure-1PSIDTS=sidts-CjIB7pHptVzwjHRdv_FJFSN0H32fPjC0Pjny9zCQFBrLqhlDW2r6S21u5sbmfAjb-2d11BAA; __Secure-3PSIDTS=sidts-CjIB7pHptVzwjHRdv_FJFSN0H32fPjC0Pjny9zCQFBrLqhlDW2r6S21u5sbmfAjb-2d11BAA; __Secure-1PSID=g.a000vQiP8ClOXSHM_7ueWaK9ujL2iMXZJ2dIb0jeq4-Hx_xhy0OWn2hDRvjxP_59pTfMDIZaIgACgYKAegSARUSFQHGX2Micc9jgtha8_fPN-USDFwYTxoVAUF8yKpTlS4Sllk6_q9ABBX_D2q00076; __Secure-3PSID=g.a000vQiP8ClOXSHM_7ueWaK9ujL2iMXZJ2dIb0jeq4-Hx_xhy0OWQR91IR-F7trUS4Whfz5gcQACgYKAaUSARUSFQHGX2MiFo1Twiwxg6bzB-WEhhxZqxoVAUF8yKpwD_ChqvMrJciuXmWVIsfZ0076; HSID=At_jAq2i-98BrH_xm; SSID=A143R5E3_OCNzND4b; APISID=cGcQqX_xlrU8q2el/Al3Dqv55KTpWkDoTl; SAPISID=gAYKM6fbPOAAGgYj/AXsmsaFmmidelcqjM; __Secure-1PAPISID=gAYKM6fbPOAAGgYj/AXsmsaFmmidelcqjM; __Secure-3PAPISID=gAYKM6fbPOAAGgYj/AXsmsaFmmidelcqjM; CONSISTENCY=AKreu9s7JiLUZ2EvTUHAI3wVyi4nREiq7MZONnW9RtiLjpGodP3Z0bM7AMDcrMeTGKy-7saLyRML-4FySLalykeps7HtOa1vfoVk-9Y8ofTzMaeTdHUQXUPKtxWoiqemQAmnd1mmc6cmpobw7KP2M7N6; SIDCC=AKEyXzU8BGBdjKJjdd_x4ddgcNvkhsPGpGEUnJJVUIzCZy5GN7wpPOuqYpCWLiGL1J5U6_u3wiM; __Secure-1PSIDCC=AKEyXzXjAUuWrIExXWRPB8phMO0AyGdySs_7b5YDTM7H-oA-tzcE3BOBSKWu-slIrmVSrPt-3A; __Secure-3PSIDCC=AKEyXzXLq8A5CfR0lWuann99KL1Y-qWmj5iaOtBGR1Vu3sD63vitV9mCf6QH83XefDYOXXaOpFE; YSC=vrP5f01U2F8; VISITOR_INFO1_LIVE=spnq2cTgeX0; VISITOR_PRIVACY_METADATA=CgJJThIEGgAgLQ%3D%3D; __Secure-ROLLOUT_TOKEN=CM2ggoq4ieOjpgEQyLDG0dS5iwMY55fyw8DBjAM%3D;", // Replace with your actual cookie
          "Accept-Language": "en-US,en;q=0.9",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        },
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
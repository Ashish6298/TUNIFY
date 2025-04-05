const express = require('express');
const cors = require('cors');
const ytdl = require('@distube/ytdl-core'); // Replace ytdl-core with @distube/ytdl-core
const youtubeSearch = require('youtube-search-api');

const app = express();
const port = 3000;

// Middleware
app.use(cors({
  origin: '*', // Adjust this in production to specific origins
  methods: ['GET'],
  allowedHeaders: ['Content-Type'],
}));

// Search endpoint
app.get('/search', async (req, res) => {
  const query = req.query.q;

  if (!query) {
    return res.status(400).json({ 
      success: false,
      error: 'Query parameter "q" is required' 
    });
  }

  try {
    console.log(`Searching for: ${query}`);
    const result = await youtubeSearch.GetListByKeyword(query, false, 10, [{ type: 'video' }]);
    
    if (!result?.items?.length) {
      return res.status(404).json({ 
        success: false,
        error: 'No search results found' 
      });
    }

    const results = result.items.map(item => ({
      id: item.id,
      title: item.title || 'Unknown Title',
      author: item.channelTitle || 'Unknown Channel',
      thumbnail: item.thumbnail?.thumbnails?.[0]?.url || '',
    }));

    console.log(`Found ${results.length} results`);
    res.json(results);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to search YouTube',
      details: error.message 
    });
  }
});

// Stream endpoint
app.get('/stream/:videoId', async (req, res) => {
  const videoId = req.params.videoId;

  if (!videoId) {
    return res.status(400).json({ 
      success: false,
      error: 'Video ID is required' 
    });
  }

  try {
    console.log(`Fetching audio stream for video ID: ${videoId}`);
    const url = `https://www.youtube.com/watch?v=${videoId}`;
    
    // Validate video ID
    if (!ytdl.validateID(videoId)) {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid video ID' 
      });
    }

    // Get video info with audio-only filter
    const info = await ytdl.getInfo(url, {
      requestOptions: {
        headers: {
          'User-Agent': 'Mozilla/5.0', // Helps avoid some YouTube restrictions
        },
      },
    });

    // Choose audio-only format
    const audioFormat = ytdl.chooseFormat(info.formats, { 
      filter: 'audioonly', 
      quality: 'highestaudio', // Prioritize highest audio quality
    });

    if (!audioFormat) {
      return res.status(404).json({ 
        success: false,
        error: 'No audio stream available for this video' 
      });
    }

    console.log(`Audio stream URL generated for ${videoId}`);
    res.json({ 
      success: true,
      url: audioFormat.url 
    });
  } catch (error) {
    console.error('Stream error:', error.message, error.stack);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch audio stream',
      details: error.message 
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ 
    success: false,
    error: 'Internal server error',
    details: err.message 
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log('Music streaming server initialized');
});

## TUNIFY - Your Ultimate Music Streaming App 🎵🚀

## 📌 Overview
TUNIFY is a dynamic Android music streaming app built with Flutter, powered by a lightning-fast Node.js backend. It taps into YouTube’s massive music library, letting you search, stream, and curate playlists with ease. From Bollywood bangers to chill indie vibes, TUNIFY delivers high-quality audio and personalized playlists right to your Android device. Get ready to vibe, save your favorite tracks, and explore curated collections in style! 🎧  

## ✨ Features
✅ Search Any Song: Discover your favorite tracks or artists in a flash.✅ Stream in High Quality: Enjoy crisp, clear audio from YouTube.✅ Curated Collections: Dive into playlists like Top 100 Songs, Punjabi Beats, or Chill Vibes.✅ Personal Playlists: Build your own playlist with no duplicates.✅ Hot Recommendations: Stay updated with the freshest 2025 hits.✅ Sleek Flutter UI: A smooth, modern interface for an epic music experience.✅ Completely Free: Jam to your tunes without spending a penny!  


## 🚀 How to Use
1️⃣ Search for Songs: Type an artist, song, or genre in the app’s search bar to find tracks from YouTube.2️⃣ Stream Instantly: Tap a song to stream high-quality audio right in the app.3️⃣ Add to Playlist: Save songs to your personal playlist with a single tap.4️⃣ Explore Collections: Browse curated playlists like Bollywood Hits or Workout Jams for instant vibes.5️⃣ Discover New Music: Check out the recommendations section for the hottest 2025 tracks.  

## 🔧 Installation Guide

Clone the TUNIFY repository to your local machine. Navigate to the project folder and install Flutter dependencies. Run the app to launch it on your Android emulator or device.  
```
git clone https://github.com/Ashish6298/TUNIFY
```
    cd TUNIFY
```
flutter pub get
```
    flutter run

## Backend Setup

Clone the backend repository and install Node.js dependencies. Create a .env file with optional YouTube cookies to unlock restricted tracks. Start the Node.js server, and use your machine’s IP address to connect from your Flutter app on an Android emulator or device.  
```
git clone https://github.com/ashish6298/TUNIFY
```
    cd backend
```
npm install
```
    node server.js


## 🎤 API Features for Flutter Devs
TUNIFY’s Node.js backend powers your Flutter app with a suite of RESTful APIs:🔍 Search Songs: Find songs by any keyword, returning titles, artists, and thumbnails for your app’s UI.🔥 Recommendations: Get the latest 2025 tracks, sorted by release date, perfect for a trending section.🎶 Stream Audio: Fetch high-quality audio streams for any YouTube video to play in your app.📜 Playlist Management: View or add songs to a user’s playlist, ensuring no duplicates.📚 Curated Collections: Access themed playlists like Chill Vibes or Top 100 Songs for engaging app sections.🏆 Top Songs: Showcase the top 100 hits of 2025 for a chart-topping feature.The backend handles errors smoothly, providing clear messages for invalid inputs, missing results, or server issues, keeping your Flutter app user-friendly.  

## 💡 Pro Tips & Notes
Your playlist is stored in memory for a seamless experience, but it resets when the server restarts—great for quick jams! Add YouTube cookies in the backend’s .env file to stream restricted tracks, though most songs work fine without them. Ensure your app complies with YouTube’s Terms of Service to keep the vibes legal. For your Flutter app, consider using packages like just_audio for streaming and cached_network_image for fast thumbnails. When testing on Android, connect to the backend using your machine’s IP address. 😎  

## 🧰 Tech Stack
The frontend shines with Flutter’s Dart-based framework for a stunning Android UI. The backend rocks with Express.js for speed, @distube/ytdl-core for audio streaming, and youtube-search-api for fast searches. The dotenv package keeps secrets safe, and CORS support ensures your Flutter app connects effortlessly.  

## Turn up the volume and let TUNIFY rock your music world! 🎵

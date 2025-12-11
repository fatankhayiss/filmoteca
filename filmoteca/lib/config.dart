// Ganti dengan TMDB API Key milik Anda sendiri
// Dapatkan dari https://www.themoviedb.org/ (Account → API)
const String tmdbApiKey = '92acb8f4b5c14cbdd9414ef831c4e3c2';
const String tmdbBase = 'https://api.themoviedb.org/3';
const String tmdbImageBase = 'https://image.tmdb.org/t/p/w500';

// Base URL API untuk backend Laravel.
// WAJIB diganti sesuai lingkungan Anda:
// - Perangkat fisik di Wi‑Fi yang sama: 'http://<IP-laptop>:8000/api'
// - Android emulator (AVD): 'http://10.0.2.2:8000/api'
// - iOS simulator (macOS): 'http://localhost:8000/api'
// Jalankan backend dengan: php artisan serve --host=0.0.0.0 --port=8000
const String apiBase = 'http://192.168.2.101:8000/api';

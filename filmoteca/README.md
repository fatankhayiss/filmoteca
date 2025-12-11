# filmoteca

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Panduan Setup (Bahasa Indonesia)

Bagian ini menjelaskan konfigurasi aplikasi Flutter agar terhubung ke backend Laravel dan API TMDB.

### 1) Atur IP backend di `lib/config.dart`
- Buka file `lib/config.dart`.
- Ubah nilai `apiBase` sesuai IP laptop/PC Anda yang menjalankan Laravel:
	- Contoh jaringan lokal: `http://192.168.x.x:8000/api`
	- Android emulator (AVD): `http://10.0.2.2:8000/api`
	- iOS simulator (macOS): `http://localhost:8000/api`
- Pastikan backend dijalankan dengan `php artisan serve --host=0.0.0.0 --port=8000` agar bisa diakses dari perangkat lain.

### 2) Dapatkan TMDB API Key
- Kunjungi https://www.themoviedb.org/ dan buat akun.
- Masuk ke pengaturan akun → API → Ajukan API key.
- Setelah mendapatkan API key, buka `lib/config.dart` dan isi `tmdbApiKey` dengan key Anda.

### 3) Install dependencies dan jalankan aplikasi
```bash
flutter pub get
flutter run
```

### Catatan
- Jika aplikasi tidak bisa memanggil backend, cek:
	- IP/host dan port di `apiBase`.
	- Firewall Windows yang mungkin memblokir port 8000.
	- Perintah serve menggunakan host `0.0.0.0`.
- Untuk gambar dan data film dari TMDB, pastikan `tmdbApiKey` valid.

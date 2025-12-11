<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework. You can also check out [Laravel Learn](https://laravel.com/learn), where you will be guided through building a modern Laravel application.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

---

## Panduan Setup (Bahasa Indonesia)

Bagian ini menjelaskan cara menjalankan backend Laravel untuk proyek Filmoteca di mesin lokal.

### Prasyarat
- PHP 8.2+ dan Composer terpasang
- MySQL/MariaDB terpasang (atau database lain yang didukung Laravel)
- Node.js (opsional, jika ingin menjalankan asset via Vite)

### Langkah Instalasi
1. Salin file environment:
	- Duplikasi `.env.example` menjadi `.env`.
	- Jalankan perintah berikut untuk membuat `APP_KEY`:
	  ```bash
	  php artisan key:generate
	  ```

2. Buat database kosong di MySQL/MariaDB (nama sesuai `.env.example`: `filmoteca_db`):
	- Via phpMyAdmin atau CLI:
	  ```sql
	CREATE DATABASE filmoteca_db;
	  ```

3. Konfigurasi koneksi database di `.env`:
	- Sesuaikan dengan `.env.example`:
	  - `DB_DATABASE=filmoteca_db`
	  - `DB_USERNAME` dan `DB_PASSWORD` sesuai setelan lokal.

4. Install dependensi Composer dan jalankan migrasi:
	```bash
	composer install
	php artisan migrate
	# Opsional: isi data awal
	php artisan db:seed
	```

5. Menjalankan server pengembangan:
	```bash
	php artisan serve
	```
Secara default akan berjalan di `http://127.0.0.1:8000`.

Jika ingin menentukan host dan port secara eksplisit (mis. agar dapat diakses dari jaringan lokal/VM/WSL):
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

6. (Opsional) Menjalankan asset frontend Vite untuk view Blade:
	```bash
	npm install
	npm run dev
	```

### Catatan Penting
- File `.env` tidak disertakan di repository untuk alasan keamanan. Setiap developer harus membuatnya sendiri dari `.env.example`.
- Migrasi pada folder `database/migrations/` akan membuat tabel yang diperlukan. Pastikan database sudah dibuat dan kredensial `.env` benar.
- Jika menggunakan Laragon di Windows, Anda bisa mengatur host dan database melalui panel Laragon dan menyesuaikan `.env`.

### Endpoint API (ringkas)
- Lihat definisi route di `routes/api.php` untuk daftar endpoint yang tersedia (contoh: autentikasi, favorit, dll.).

### Troubleshooting
- Gagal koneksi DB: cek nilai `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` di `.env`.
- Error migrasi: pastikan database sudah dibuat dan user memiliki izin `CREATE/ALTER`.
- Permission storage: jalankan `php artisan storage:link` bila perlu, dan pastikan folder `storage/` dapat ditulisi.

# Koneksi API autentikasi

Base URL: `lib/core/network/api_config.dart`.
Default Android emulator: `http://10.0.2.2:4000`.
Default iOS simulator/web/desktop: `http://localhost:4000`.

Untuk HP fisik, gunakan IP LAN komputer backend (HP dan komputer satu jaringan):

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:4000
```

Backend harus mendengarkan pada interface yang dapat diakses HP, misalnya `0.0.0.0`.
Web memerlukan konfigurasi CORS backend yang mengizinkan origin aplikasi.
Android mengizinkan HTTP lokal pada build debug; gunakan HTTPS untuk release.

## Kontrak sementara

`POST /auth/login`: `{"email":"nama@email.com","password":"password123"}`

`POST /auth/register`: `{"username":"andi","umur":23,"email":"nama@email.com","role":"USER","password":"password123"}`

Role yang diketahui dari schema: `USER`; form hanya menyediakan nilai ini sampai enum `UserRole` lengkap tersedia. Username dibatasi maksimal 20 karakter.

Model Prisma bukan kontrak HTTP; payload ini masih perlu sesuai DTO/controller backend. Password dikirim sebagai `password`, lalu backend melakukan hashing ke `passwordHash`. Field `id`, `createdAt`, dan `updatedAt` dikelola backend. Field `name` bersifat opsional dan tidak dikirim.

Respons sukses: HTTP 2xx dengan JSON object opsional, misalnya `{"message":"Login berhasil"}`.
Error: HTTP non-2xx atau `{"success":false,"message":"..."}`.
Pesan string `message`/`error` ditampilkan di form. Timeout: 15 detik.

Repository demo tidak lagi dipakai aplikasi. Endpoint recovery terhubung seperti
dijelaskan pada bagian pembaruan di bawah.
Login membaca `accessToken` dan menyimpannya di memori ApiClient. Registrasi otomatis
memanggil login untuk mendapatkan token, lalu membuka ProfilePage. Token dikirim
sebagai Authorization: Bearer pada request berikutnya. Logout menghapus token.
Sesi belum disimpan ke perangkat: membuka ulang aplikasi memerlukan login lagi.

Profile menggunakan GET /profile/me, POST /profile, PATCH /profile/:id, dan
DELETE /profile/:id. ID untuk perubahan adalah ID profile, bukan ID user.
GET /profile/me mengembalikan {profile: {username, email, profile: {id, bio, phone}}};
profile dalam akun bisa null. Bio dan phone dikirim sebagai string.
Penghapusan membutuhkan konfirmasi di UI dan hanya menghapus profile.

## Pembaruan account recovery dan sesi

Login kini wajib menerima accessToken dan refreshToken. Kedua token disimpan hanya
pada memori. Request terproteksi dengan HTTP 401 memicu satu refresh bersama melalui
POST /auth/refresh {refreshToken}, kemudian satu retry dengan pasangan token baru.
Token refresh tidak valid menghapus sesi; pengguna dapat keluar lalu login ulang.
POST /auth/logout mencabut refresh token sebelum menghapus sesi lokal.
POST /auth/logout-all tersedia dari Profile dengan konfirmasi.

Lupa password membuka form permintaan POST /auth/forgot-password {email}, kemudian
form token untuk POST /auth/reset-password {token,newPassword}. Password baru 8–100
karakter. Profile menyediakan verifikasi: POST /auth/resend-verification {email}
dan POST /auth/verify-email {token}. Token development dari respons tidak ditampilkan
atau dicatat mobile. Input token manual tersedia; belum ada deep link otomatis.

Service backend yang diberikan membuat token recovery tetapi tidak menunjukkan
integrasi pengiriman email. Pengiriman token melalui email perlu disediakan backend.
Registrasi tetap login otomatis karena backend mengizinkan login sebelum verifikasi.

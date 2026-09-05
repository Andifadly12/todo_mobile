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

Repository demo tidak lagi dipakai aplikasi. Endpoint reset password belum
tersedia dan akan menampilkan pesan tersebut tanpa mengirim request.
Integrasi ini mengirim form dan menampilkan hasil; token, persistensi sesi,
dan navigasi setelah login belum diterapkan karena kontrak respons belum tersedia.

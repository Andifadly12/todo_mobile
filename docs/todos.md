# Todo

Fitur berada di `lib/features/todos` dengan domain repository, implementasi API,
Cubit, halaman, dan widget kartu/editor terpisah. Footer reusable berada di core.
Navigasi setelah autentikasi tetap membuka Profile; tab Tugas membuka daftar Todo.

API menggunakan Bearer token sesi yang sudah ada:
- GET /todos?page=1&limit=10&status=TODO: membaca data dan meta pagination.
- GET /todos/:id: tersedia pada repository untuk detail.
- POST /todos: membuat tugas.
- PATCH /todos/:id: memperbarui tugas atau status.
- DELETE /todos/:id: menghapus setelah konfirmasi pengguna.

Status: TODO, IN_PROGRESS, COMPLETED, CANCELLED. Prioritas: LOW, MEDIUM, HIGH.
Judul wajib, maksimal 120 karakter. Tanggal lokal dikirim sebagai ISO 8601 UTC;
tanggal yang dikosongkan dikirim null. completedAt dikelola backend ketika status berubah.
Reminder disimpan ke backend; penjadwalan notifikasi perangkat belum diterapkan.
Pemilih kategori memuat GET /categories setiap form dibuka. categoryId dikirim saat
simpan; pilihan Tanpa kategori mengirim null. Jika daftar gagal dimuat, kategori
saat ini dipertahankan dan pengguna dapat mencoba memuat ulang.

Validasi: flutter analyze, flutter test; CRUD backend memakai akun QA; pemeriksaan
layout dan pembuatan tugas melalui emulator Android.

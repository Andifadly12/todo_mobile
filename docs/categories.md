# Kategori

Feature-first: domain CategoryRepository, data ApiCategoryRepository, CategoryCubit,
halaman kategori, editor, dan pemilih warna reusable.

JWT Bearer dikirim oleh ApiClient. GET /categories mengembalikan array langsung;
GET /categories/:id mengembalikan object. POST /categories dan PATCH /categories/:id
mengirim name dan color. Nama wajib maksimal 50 karakter, warna opsional berupa
hex #RRGGBB atau null. DELETE /categories/:id memerlukan konfirmasi UI.
Keunikan nama per user divalidasi backend; pesan error ditampilkan di form.

Footer berisi Tugas, Kategori, Profile. Tujuan setelah autentikasi tetap Profile.
Form Todo memuat kategori terbaru dan mengirim categoryId atau null.

Verifikasi: seluruh test Flutter, analisis kode, dan CRUD kategori terhadap backend
lokal dengan akun QA. Kategori sementara pengujian API dihapus setelah selesai.

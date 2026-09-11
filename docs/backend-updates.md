# Account security, filters, notifications

Profile > Keamanan akun menyediakan ubah password dan hapus akun. PATCH
/profile/password mengirim currentPassword dan newPassword (8–100 karakter).
DELETE /profile/account mengirim password setelah konfirmasi eksplisit. Kedua
operasi hanya menghapus sesi mobile dan kembali ke login setelah backend sukses.
Penghapusan akun bersifat permanen dan berbeda dari penghapusan data profile.

Todo > Cari & filter mendukung search (maksimal 120), priority, categoryId, completed.
Filter dipertahankan saat pagination/refresh. Memilih status menonaktifkan filter
completed agar tidak bertentangan. Memilih completed menghapus status yang aktif.

Ikon lonceng membuka GET /notifications. Ketuk notifikasi untuk PATCH
/notifications/:id/read, tombol semua dibaca untuk PATCH /notifications/read-all,
dan hapus dengan konfirmasi untuk DELETE /notifications/:id. Tarik untuk refresh.
ReminderService dijalankan backend; mobile hanya membaca notifikasi yang telah
dibuat. Belum ada push notification, polling latar belakang, atau notifikasi OS.

AllExceptionsFilter tetap kompatibel: message string/list dan HTTP status dibaca;
timestamp/path tidak ditampilkan sebagai pesan. Konflik nama kategori 409 tampil
menggunakan pesan backend. Validasi kepemilikan dan completedAt tetap di backend.

Verifikasi dilakukan melalui analisis Flutter dan mock HTTP; tidak menghapus akun
nyata atau mengubah password akun pengguna selama pengujian.

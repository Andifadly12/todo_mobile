# AI Todo

Halaman Tugas menyediakan tombol Bantu dengan AI. Input wajib, maksimum 1.000
karakter. POST /ai/parse-todo mengirim {text} dengan token Bearer sesi pengguna.
Respons {draft} divalidasi dan dipetakan ke form Todo baru. AI tidak menyimpan tugas;
pengguna meninjau judul, catatan, status, prioritas, dan tanggal sebelum Simpan tugas.
Kategori tetap dipilih pengguna. completedAt dari draft diteruskan hanya jika status
akhir COMPLETED. Tanggal ditampilkan lokal lalu disimpan sebagai UTC.

Fitur berada di lib/features/ai (domain, data, presentation Cubit). Kredensial
provider AI hanya berada di backend. Batas waktu mengikuti ApiClient (15 detik).
Kegagalan jaringan/server, draft tidak valid, dan input kosong ditangani di UI.

Pengujian mobile menggunakan mock HTTP untuk JWT, pemetaan draft, tidak melakukan
penyimpanan otomatis, dan penolakan respons invalid. Saat integrasi, endpoint lokal
masih mengembalikan 404; proses backend perlu menjalankan modul AI terbaru sebelum
pengujian menyeluruh dengan provider dapat dilakukan.

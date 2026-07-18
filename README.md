# 🧾 SplitBill - Aplikasi Pembagi Tagihan

SplitBill adalah aplikasi berbasis *mobile* yang dikembangkan menggunakan **Flutter** dan **Firebase** untuk mempermudah pengguna dalam mencatat, menghitung, dan membagi tagihan makan bersama teman-teman secara adil.

Proyek ini dibuat sebagai pemenuhan **Tugas Akhir Mata Kuliah Pemrograman Mobile (UAS)** di Institut Teknologi Garut.

## ✨ Fitur Utama
1. **Autentikasi Pintar (Auto-Login):** Menggunakan PIN sederhana yang akan diingat secara otomatis menggunakan `shared_preferences`.
2. **Manajemen Sesi Tagihan:** Memungkinkan pembuatan sesi baru untuk setiap acara makan/nongkrong.
3. **Dua Mode Pembagian Tagihan:**
   - **Bagi Rata:** Membagi total tagihan sama besar kepada seluruh anggota sesi.
   - **Detail Pesanan:** Menghitung tagihan secara spesifik berdasarkan makanan/minuman yang dipesan masing-masing anggota.
4. **Pelacakan Status Lunas:** Kemudahan melacak siapa saja teman yang sudah membayar (Lunas) dan yang belum.
5. **Real-time Database:** Data tersimpan dengan aman menggunakan *Firebase Cloud Firestore*.

## 🛠️ Teknologi yang Digunakan (Tech Stack)
* **Frontend:** Flutter (Dart)
* **Backend:** Firebase Cloud Firestore (NoSQL)
* **State Management:** Provider
* **Local Storage:** Shared Preferences
* **Ikon Tambahan:** Material Icons & flutter_launcher_icons

## 📱 Struktur Halaman (Screens)
* `LoginScreen`: Halaman masuk dan pembuatan sesi pengguna.
* `ActivityScreen` (Dashboard): Daftar seluruh riwayat sesi makan bersama.
* `InputSesiScreen`: Form untuk membuat sesi baru (Tanggal, Nama Sesi, & Daftar Teman).
* `InputPesananScreen`: Memilih mode perhitungan (Bagi Rata / Detail Pesanan) serta memasukkan harga tiap item makanan.
* `RingkasanTagihanScreen`: Rangkuman total yang harus dibayar tiap orang beserta status lunas.

## 🚀 Cara Menjalankan Proyek Secara Lokal

**Prasyarat:**
- Pastikan Anda telah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Pastikan Anda memiliki emulator Android/iOS atau *smartphone* asli yang tersambung dengan mode *USB Debugging*.

**Langkah Instalasi:**
1. _Clone_ repositori ini:
   ```bash
   git clone [MASUKKAN-LINK-GITHUB-ANDA-DI-SINI]
   ```
2. Masuk ke direktori proyek:
   ```bash
   cd aplikasispiltbill_uas
   ```
3. Unduh semua *packages* yang dibutuhkan:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## 👥 Pengembang (Kelompok)
* **Irham Sugriantha** - 2306048
* **Restu Bagja Maulud** - 2306043
* **Tsani Hisni Amala** - 2306050
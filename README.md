# 📱 SplitBill - Aplikasi Pengelola Tagihan Patungan

SplitBill adalah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah pengelolaan, perhitungan, dan pelacakan tagihan patungan (split bill) secara praktis, adil, dan transparan. Menggunakan pendekatan *Host-Centric*, aplikasi ini memungkinkan satu orang pengguna (Host) mengelola seluruh proses penagihan tanpa mewajibkan anggota lain memiliki akun.

---

## 🚀 Fitur Utama (UAS Target)
1. **Manajemen Otentikasi Pembuat Sesi (Host Auth)**: Keamanan akun untuk Host menggunakan Firebase/Supabase Authentication.
2. **Fleksibilitas Pembuat Sesi (Dual-Mode Bill Creation)**: Pilihan kalkulasi otomatis melalui mode *Bagi Rata* atau mode *Detail Pesanan*.
3. **Dasbor Pemantau Piutang (Real-Time Dashboard)**: Ringkasan akumulasi piutang aktif dan riwayat sesi nongkrong.
4. **Ringkasan Transparansi Tagihan (Smart Tracking)**: UI dinamis menggunakan komponen ekspansi (*dropdown*) untuk merinci pesanan per anggota serta *checkbox* kontrol status kelunasan.

---

## 📂 Struktur Folder Proyek (Arsitektur Model-Controller-Screen)
Proyek ini menerapkan struktur folder yang terorganisir untuk mempermudah kolaborasi tim dan skalabilitas kode:

```text
lib/
├── controllers/    # Logika bisnis, state management, dan pengolahan data
├── models/         # Blueprint/Struktur data object (User, Session, Item, Member)
├── screens/        # Komponen halaman penuh (Login, Dashboard, Ringkasan Tagihan)
├── utils/          # Konstanta global (Warna, tema teks/typography, format rupiah)
├── widgets/        # Komponen UI kecil yang dapat digunakan berulang (Reusable Component)
└── main.dart       # Titik masuk utama (Entry point) aplikasi
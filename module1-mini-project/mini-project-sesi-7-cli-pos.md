# Mini Project: CLI POS System

> **Tipe:** `Mini Project`  
> **Modul / Topik:** Module 1 — Go Fundamental & CLI  
> **Level:** `Intermediate`  
> **Estimasi Waktu:** 4–6 jam  
> **Sesi:** 7 (Ujian Modul 1)

---

## Deskripsi

Ini adalah mini project penutup **Module 1**. Kamu akan membangun sebuah aplikasi **Point of Sale (POS) sederhana berbasis CLI** menggunakan Go. Proyek ini adalah ujian nyata apakah kamu sudah siap melanjutkan ke modul berikutnya.

POS System adalah sistem kasir digital yang digunakan di toko, kafe, maupun restoran untuk mencatat produk, memproses transaksi, dan merekap penjualan. Versi CLI yang kamu bangun ini adalah fondasi dari sistem yang benar-benar dipakai di industri.

---

## Tujuan Pembelajaran

Mini project ini adalah **ujian komprehensif** yang merangkum seluruh materi Module 1. Setelah menyelesaikannya, kamu diharapkan mampu:

- [ ] Menggunakan variabel, tipe data, dan operator secara tepat
- [ ] Menulis function dan method yang terstruktur
- [ ] Menerapkan control flow (if/else, switch, loop) untuk logika bisnis
- [ ] Menggunakan slice dan map untuk menyimpan dan mengelola data
- [ ] Mendefinisikan struct dan method menggunakan pointer receiver
- [ ] Membangun program CLI yang interaktif dan bisa digunakan dari awal hingga akhir

---

## Prasyarat

Seluruh materi Module 1 yang sudah dipelajari:

| Sesi | Topik                                                            |
| ---- | ---------------------------------------------------------------- |
| 1–2  | Basic Syntax, Variable, Data Types, Function, String Format, I/O |
| 3    | Control Flow: If/Else, Switch, Looping                           |
| 4    | Data Structure: Array, Slice, Map                                |
| 5    | Pointer, Struct & Method                                         |

---

## Spesifikasi Tugas

### Konteks / Studi Kasus

Kamu diminta membangun sistem kasir CLI untuk sebuah warung atau kafe kecil. Kasir dapat mendaftarkan produk yang dijual dan melayani transaksi pembelian pelanggan secara langsung melalui terminal.

---

### Menu Utama

Program harus menampilkan menu utama seperti ini dan berjalan dalam loop hingga user memilih keluar:

```
===================================
           MENU UTAMA
===================================
  1. Tambah Produk
  2. Lihat Daftar Produk
  3. Transaksi Baru
  0. Keluar
===================================
Pilih menu:
```

---

### Fitur yang Harus Diimplementasikan

#### 1. Tambah Produk

- User memasukkan nama produk, harga, dan stok awal
- Setiap produk otomatis mendapat ID unik yang bertambah
- Validasi: harga harus > 0, stok tidak boleh negatif
- Tampilkan konfirmasi setelah produk berhasil ditambahkan

#### 2. Lihat Daftar Produk

- Tampilkan semua produk dalam format tabel yang rapi
- Kolom: ID, Nama Produk, Harga, Stok
- Jika belum ada produk, tampilkan pesan yang informatif

#### 3. Transaksi Baru

- Tampilkan daftar produk yang tersedia
- User memilih produk berdasarkan ID dan memasukkan jumlah
- Validasi:
  - Produk harus ada
  - Jumlah tidak boleh melebihi stok yang tersedia
  - Jumlah tidak boleh 0 atau negatif
- Stok produk otomatis berkurang setelah dipilih
- User bisa memilih lebih dari satu produk dalam satu transaksi (loop sampai input 0)
- Di akhir transaksi, tampilkan **struk belanja** berisi daftar item, subtotal masing-masing, dan total keseluruhan
- Setelah total muncul, minta input **nominal pembayaran**
- Validasi pembayaran:
  - Jika pembayaran < total, tampilkan pesan bahwa uang tidak cukup dan minta input ulang
  - Jika pembayaran == total, tampilkan keterangan pembayaran pas
  - Jika pembayaran > total, hitung dan tampilkan nominal **kembalian**

---

### Kriteria Keberhasilan (Acceptance Criteria)

- [ ] Program berjalan dalam loop — tidak langsung berhenti setelah satu aksi
- [ ] Semua 3 menu berfungsi dengan benar
- [ ] Stok produk berkurang dengan tepat saat transaksi terjadi dan tidak pernah menjadi negatif
- [ ] Semua input pengguna divalidasi dengan pesan error yang jelas
- [ ] Struk belanja menampilkan detail yang lengkap dan rapi
- [ ] Alur pembayaran berjalan benar: kurang, pas, dan ada kembalian
- [ ] Program tidak crash untuk input yang tidak valid (angka di luar pilihan menu, stok habis, dll.)
- [ ] Kode menggunakan **minimal 1 struct**, **minimal 1 penggunaan map**, **minimal 1 slice**, dan **pointer receiver pada method**

---

## Panduan Teknis

### Struct yang Disarankan

```go
type Product struct {
    ID    int
    Name  string
    Price float64
    Stock int
}

type CartItem struct {
    // hint: bagaimana cara menyimpan product agar stoknya bisa langsung berkurang?
    Quantity int
    Subtotal float64
}

type Transaction struct {
    ID        int
    Items     []CartItem
    Total     float64
    PaidAmount float64
    Change     float64
}
```

> **Hint:** Untuk `CartItem`, pikirkan apakah kamu perlu menyimpan _copy_ product atau _pointer_ ke product aslinya. Apa bedanya?

### Batasan & Ketentuan Teknis

- **Bahasa:** Go
- **Boleh menggunakan:** `fmt`, `strings`, `time`, `strconv`
- **Tidak boleh menggunakan:** library/framework eksternal, database (semua data in-memory)
- Semua kode boleh dalam **satu file `main.go`**

---

## Bonus (Opsional)

> Tidak wajib. Kerjakan bonus hanya setelah semua fitur wajib selesai dan berjalan dengan baik.

- [ ] **Low Stock Monitor (Concurrency):**  
      Jalankan sebuah goroutine di background yang setiap 10 detik memeriksa produk mana saja yang stoknya di bawah 5, lalu mencetak peringatan ke terminal. Gunakan `sync.Mutex` agar pembacaan stok tidak bertabrakan dengan operasi transaksi.

- [ ] **Seed Data Awal:**  
      Saat program pertama dijalankan, sudah tersedia beberapa produk contoh (minimal 3) agar tidak perlu menambah produk dari awal setiap kali testing.

- [ ] **Nomor transaksi terformat:**  
      Tampilkan nomor transaksi dengan format `#0001`, `#0002`, dst.

---

## Format Pengumpulan

- Kirim link GitHub repository ke grup
- Struktur folder yang diharapkan:

  ```
  cli-pos/
  ├── main.go
  └── README.md
  ```

- `README.md` harus berisi:
  - Cara menjalankan program
  - Fitur-fitur yang tersedia
  - Contoh output (screenshot atau teks)

---

## Referensi & Bahan Bacaan

- [Dasar Pemrograman Golang — Struct](https://dasarpemrogramangolang.novalagung.com/A-struct.html)
- [Dasar Pemrograman Golang — Method](https://dasarpemrogramangolang.novalagung.com/A-method.html)
- [Dasar Pemrograman Golang — Pointer](https://dasarpemrogramangolang.novalagung.com/A-pointer.html)
- [Dasar Pemrograman Golang — Map](https://dasarpemrogramangolang.novalagung.com/A-map.html)
- [Dasar Pemrograman Golang — Slice](https://dasarpemrogramangolang.novalagung.com/A-slice.html)
- [Go by Example: Structs](https://gobyexample.com/structs)
- [Go by Example: Methods](https://gobyexample.com/methods)

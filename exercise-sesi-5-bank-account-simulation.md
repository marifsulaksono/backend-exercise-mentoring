# Bank Account Simulation

> **Tipe:** `Exercise`  
> **Modul / Topik:** Module 1 — Pointer, Struct & Method  
> **Level:** `Intermediate`  
> **Estimasi Waktu:** 2–3 jam  
> **Sesi:** 5

---

## Deskripsi

Kamu diminta membuat simulasi sederhana sistem rekening bank menggunakan Go. Program ini akan mensimulasikan operasi dasar perbankan seperti setor tunai, penarikan, dan pengecekan saldo — semuanya dibangun di atas konsep **struct**, **method**, dan **pointer**.

---

## Tujuan Pembelajaran

Setelah menyelesaikan exercise ini, kamu diharapkan mampu:

- [ ] Mendefinisikan dan menggunakan `struct` untuk merepresentasikan data
- [ ] Membuat **method** yang terikat pada suatu struct
- [ ] Memahami perbedaan **pointer receiver** vs value receiver dan kapan menggunakannya
- [ ] Menggunakan **pointer** agar perubahan data di dalam method benar-benar tersimpan

---

## Prasyarat

Sebelum mengerjakan, pastikan kamu sudah memahami:

- Struct dan cara mendefinisikannya di Go
- Cara membuat dan memanggil sebuah function/method
- Konsep pointer (`*` dan `&`) di Go
- Slice dan cara menambahkan elemen (dari sesi Data Structure)

---

## Spesifikasi Tugas

### Konteks / Studi Kasus

Kamu adalah developer yang diminta membangun modul rekening untuk aplikasi perbankan sederhana. Setiap nasabah memiliki rekening dengan nama pemilik, nomor rekening, dan saldo. Nasabah dapat melakukan setor tunai, menarik uang, dan melihat riwayat transaksi mereka.

---

### Yang Harus Dikerjakan

1. **Buat struct `BankAccount`** dengan field berikut:
   - `AccountNumber` (string) — nomor rekening
   - `OwnerName` (string) — nama pemilik
   - `Balance` (float64) — saldo saat ini
   - `Transactions` ([]string) — riwayat transaksi

2. **Buat method `Deposit(amount float64)`**
   - Menambahkan `amount` ke `Balance`
   - Menyimpan catatan ke `Transactions`, contoh: `"[DEBIT] +50000 | Saldo: 150000"`
   - Cetak konfirmasi ke terminal

3. **Buat method `Withdraw(amount float64)`**
   - Mengurangi `amount` dari `Balance`
   - Tolak penarikan jika saldo tidak cukup, tampilkan pesan error yang informatif
   - Menyimpan catatan ke `Transactions`, contoh: `"[KREDIT] -30000 | Saldo: 120000"`
   - Cetak konfirmasi ke terminal

4. **Buat method `GetBalance()`**
   - Menampilkan saldo saat ini ke terminal

5. **Buat method `PrintStatement()`**
   - Menampilkan semua riwayat transaksi secara berurutan

6. **Di `main()`**, demonstrasikan semua method di atas:
   - Buat minimal 1 akun
   - Lakukan beberapa operasi deposit dan withdraw (termasuk 1 kasus saldo tidak cukup)
   - Tampilkan mutasi rekening di akhir

---

### Kriteria Keberhasilan (Acceptance Criteria)

- [ ] Struct `BankAccount` terdefinisi dengan benar dan semua field terisi saat inisialisasi
- [ ] Method `Deposit` dan `Withdraw` menggunakan **pointer receiver** sehingga perubahan saldo benar-benar tersimpan
- [ ] Penarikan ditolak dengan pesan yang jelas jika saldo tidak mencukupi
- [ ] Setiap transaksi tercatat di slice `Transactions`
- [ ] `PrintStatement` menampilkan semua riwayat transaksi dengan format yang rapi
- [ ] Program berjalan tanpa error

---

## Batasan & Ketentuan Teknis

- **Bahasa:** Go (versi bebas)
- **Boleh menggunakan:**
  - Package `fmt` untuk output
  - `fmt.Sprintf` untuk format string transaksi
- **Tidak boleh menggunakan:**
  - Package/library eksternal
  - Global variable untuk menyimpan state akun

---

## Bonus (Opsional)

> Tidak wajib, tapi akan menjadi nilai tambah.

- [ ] **Transfer antar akun:** Buat method `Transfer(to *BankAccount, amount float64)` yang memindahkan saldo dari satu akun ke akun lain. _(Ini akan melatih penggunaan pointer ke struct lain)_
- [ ] **Buat lebih dari 1 akun** dan simpan dalam sebuah slice, lalu loop untuk menampilkan saldo semua akun
- [ ] Tambahkan timestamp sederhana pada setiap catatan transaksi menggunakan `time.Now().Format(...)`

---

## Format Pengumpulan

- Kirim link GitHub repository atau file langsung ke grup
- Struktur folder yang diharapkan:

  ```
  bank-account/
  ├── main.go
  └── README.md
  ```

- `README.md` cukup berisi cara menjalankan program (`go run main.go`)

---

## Referensi & Bahan Bacaan

- [Go Tour: Structs](https://go.dev/tour/moretypes/2)
- [Go Tour: Pointer Receivers](https://go.dev/tour/methods/4)
- [Dasar Pemrograman Golang — Pointer](https://dasarpemrogramangolang.novalagung.com/A-pointer.html)
- [Dasar Pemrograman Golang — Struct](https://dasarpemrogramangolang.novalagung.com/A-struct.html)
- [Dasar Pemrograman Golang — Method](https://dasarpemrogramangolang.novalagung.com/A-method.html)

---

## Catatan untuk Mentor

> _(Hapus bagian ini sebelum dibagikan ke mentee)_

- **Poin kritis yang sering salah:** mentee sering lupa pakai pointer receiver (`*BankAccount`) di `Deposit` dan `Withdraw`, sehingga saldo tidak berubah. Ini adalah "gotcha" yang bagus untuk dibahas saat review.
- **Pertanyaan diskusi yang bisa diangkat:**
  - "Coba hapus `*` di receiver method Deposit, apa yang terjadi? Kenapa?"
  - "Kapan kita perlu pointer receiver, kapan tidak?"
- **Untuk bonus Transfer:** pastikan mentee paham kenapa parameternya `*BankAccount` bukan `BankAccount`
- Exercise POS sebelumnya (sesi 4) sudah melatih slice dan map — exercise ini adalah kelanjutan alami yang menambah lapisan object/method di atasnya

# Basic Ticket Order Simulation

> **Tipe:** `Exercise`  
> **Modul / Topik:** Module 1 — Go Concurrency  
> **Level:** `Intermediate`  
> **Estimasi Waktu:** 2–3 jam  
> **Sesi:** 6

---

## Deskripsi

Kamu diminta membuat simulasi sistem pemesanan tiket konser secara sederhana. Yang menjadi tantangan: banyak pembeli memesan tiket **pada saat yang bersamaan**. Program ini akan mensimulasikan kondisi tersebut menggunakan **goroutine**, dan memastikan tidak terjadi race condition pada stok tiket menggunakan **Mutex** dan **WaitGroup**.

---

## Tujuan Pembelajaran

Setelah menyelesaikan exercise ini, kamu diharapkan mampu:

- [ ] Memahami konsep **goroutine** dan cara menjalankannya dengan keyword `go`
- [ ] Menggunakan **`sync.WaitGroup`** untuk menunggu semua goroutine selesai
- [ ] Menggunakan **`sync.Mutex`** untuk melindungi shared data dari race condition
- [ ] Memahami mengapa concurrency tanpa proteksi bisa menyebabkan bug yang sulit dideteksi

---

## Prasyarat

Sebelum mengerjakan, pastikan kamu sudah memahami:

- Struct dan method (sesi 5 — Bank Account Simulation)
- Dasar pointer dan cara kerja value vs reference
- Cara membuat dan memanggil function di Go

---

## Spesifikasi Tugas

### Konteks / Studi Kasus

Sebuah konser akan digelar dan tersedia **10 tiket** yang dijual secara online. Ada **15 pembeli** yang mencoba memesan tiket secara bersamaan. Tugasmu adalah memastikan:

- Tidak ada tiket yang terjual melebihi stok
- Tidak ada dua pembeli yang mendapatkan "tiket yang sama"
- Semua proses pemesanan selesai sebelum program berhenti

---

### Yang Harus Dikerjakan

1. **Buat struct `TicketSystem`** dengan field:
   - `TotalTickets` (int) — stok tiket awal
   - `RemainingTickets` (int) — stok tiket yang tersisa
   - `mu` (`sync.Mutex`) — untuk proteksi data

2. **Buat method `BookTicket(buyerName string, wg *sync.WaitGroup)`**
   - Simulasikan jeda waktu pemesanan dengan `time.Sleep` (gunakan durasi acak kecil, misalnya 100–300ms)
   - Cek apakah tiket masih tersedia
   - Jika tersedia: kurangi `RemainingTickets`, cetak konfirmasi pemesanan
   - Jika tidak tersedia: cetak pesan bahwa tiket habis untuk pembeli ini
   - Jangan lupa panggil `wg.Done()` di akhir (gunakan `defer`)

3. **Di `main()`**:
   - Inisialisasi `TicketSystem` dengan 10 tiket
   - Buat daftar 15 nama pembeli
   - Jalankan masing-masing pembeli sebagai **goroutine** menggunakan `go`
   - Gunakan `sync.WaitGroup` untuk menunggu semua goroutine selesai
   - Tampilkan ringkasan di akhir: berapa tiket terjual, berapa yang gagal

---

### Kriteria Keberhasilan (Acceptance Criteria)

- [ ] Semua 15 pembeli berjalan sebagai goroutine (bukan sequential)
- [ ] `RemainingTickets` tidak pernah bernilai negatif
- [ ] Program tidak berhenti sebelum semua goroutine selesai (WaitGroup dipakai dengan benar)
- [ ] Tidak ada race condition — coba jalankan dengan flag `-race`: `go run -race main.go`
- [ ] Output menampilkan siapa yang berhasil dapat tiket dan siapa yang tidak

---

## Batasan & Ketentuan Teknis

- **Bahasa:** Go (versi bebas)
- **Boleh menggunakan:**
  - Package `sync` (Mutex, WaitGroup)
  - Package `time` untuk simulasi jeda
  - Package `fmt` untuk output
  - Package `math/rand` untuk durasi jeda acak (opsional)
- **Tidak boleh menggunakan:**
  - Library concurrency eksternal
  - Channel sebagai pengganti Mutex _(coba dulu dengan Mutex, Channel ada di bonus)_

---

## Bonus (Opsional)

> Tidak wajib, tapi akan menjadi nilai tambah.

- [ ] **Gunakan Channel:** Refactor solusimu agar menggunakan `channel` sebagai pengganti `Mutex` untuk mengontrol akses ke stok tiket. Bandingkan kedua pendekatan — mana yang lebih mudah dipahami?
- [ ] **Tambah batas antrian:** Batasi maksimal goroutine yang berjalan bersamaan menjadi 5 (simulasi kapasitas server), menggunakan **buffered channel** sebagai semaphore
- [ ] Cetak urutan goroutine yang selesai — apakah urutannya selalu sama tiap kali program dijalankan?

---

## Format Pengumpulan

- Kirim link GitHub repository atau file langsung ke grup
- Struktur folder yang diharapkan:

  ```
  ticket-order/
  ├── main.go
  └── README.md
  ```

- `README.md` cukup berisi cara menjalankan, termasuk cara run dengan flag `-race`

---

## Referensi & Bahan Bacaan

- [Dasar Pemrograman Golang — Goroutine](https://dasarpemrogramangolang.novalagung.com/A-goroutine.html)
- [Dasar Pemrograman Golang — Channel](https://dasarpemrogramangolang.novalagung.com/A-channel.html)
- [Dasar Pemrograman Golang — WaitGroup](https://dasarpemrogramangolang.novalagung.com/A-waitgroup.html)
- [Dasar Pemrograman Golang — Mutex](https://dasarpemrogramangolang.novalagung.com/A-mutex.html)
- [Go Tour: Goroutines](https://go.dev/tour/concurrency/1)

---

## Catatan untuk Mentor

> _(Hapus bagian ini sebelum dibagikan ke mentee)_

- **Poin kritis yang sering salah:**
  - Lupa `wg.Add(1)` sebelum goroutine dijalankan (atau menaruhnya di dalam goroutine — ini race condition tersendiri)
  - Lupa `defer wg.Done()` di dalam goroutine sehingga program hang selamanya
  - Tidak pakai Mutex sehingga beberapa pembeli mendapat tiket yang sama atau `RemainingTickets` jadi negatif
- **Demonstrasi yang powerful:** Minta mentee jalankan dulu _tanpa_ Mutex, lalu jalankan dengan `-race` flag — biarkan mereka melihat sendiri output race condition detector dari Go. Ini biasanya jadi "aha moment" yang kuat.
- **Pertanyaan diskusi yang bisa diangkat:**
  - "Kenapa kita perlu `wg.Add(1)` di luar goroutine, bukan di dalam?"
  - "Apa bedanya `Lock()` dan `RLock()`? Kapan pakai mana?"
  - "Kalau semua goroutine pakai Mutex, apakah programnya masih berjalan paralel?"
- **Jembatan ke sesi berikutnya (Mini Project CLI POS):** Concurrency di sini adalah fondasi — nanti saat production, request API juga berjalan concurrent dan butuh proteksi yang sama

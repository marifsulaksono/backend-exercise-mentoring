# Exercise: Refactor CLI User Management — Layered Architecture

> **Tipe:** `Exercise`  
> **Modul / Topik:** Module 2 — Database Integration  
> **Level:** `Intermediate`  
> **Estimasi Waktu:** 3–5 jam  
> **Sesi:** 10

---

## Deskripsi

Di sesi 9 kamu sudah berhasil membangun CLI User Management yang terhubung ke database. Tapi semua kode ada di satu file `main.go` — logika input, logika bisnis, dan query database semuanya bercampur.

Di sesi ini kamu akan melakukan **refactor**: memisahkan kode ke dalam lapisan-lapisan yang punya tanggung jawab masing-masing. Fungsionalitas program tidak berubah sama sekali — yang berubah hanya **cara kode diorganisir**.

Inilah yang disebut **Layered Architecture**, dan ini adalah standar yang dipakai di hampir semua proyek backend profesional.

---

## Tujuan Pembelajaran

Setelah menyelesaikan exercise ini, kamu diharapkan mampu:

- [ ] Memahami tanggung jawab masing-masing layer (handler, service, repository)
- [ ] Memisahkan kode ke dalam package yang berbeda
- [ ] Mendefinisikan sentinel error menggunakan `errors.New`
- [ ] Membungkus error antar layer menggunakan `fmt.Errorf` dengan `%w`
- [ ] Memeriksa jenis error menggunakan `errors.Is`

---

## Prasyarat

- Exercise sesi 9 sudah selesai dan berjalan dengan baik
- Kode sesi 9 akan menjadi titik awal refactor ini

---

## Konsep: Layered Architecture

Sebelum mulai coding, pahami dulu tanggung jawab masing-masing layer:

```
┌─────────────────────────────────────────────┐
│               Handler Layer                 │
│  Berinteraksi dengan user: baca input,      │
│  tampilkan output. Tidak tahu soal database │
└────────────────────┬────────────────────────┘
                     │ memanggil
┌────────────────────▼────────────────────────┐
│               Service Layer                 │
│  Berisi logika bisnis: validasi, kalkulasi. │
│  Tidak tahu cara simpan/ambil data          │
└────────────────────┬────────────────────────┘
                     │ memanggil
┌────────────────────▼────────────────────────┐
│             Repository Layer                │
│  Satu-satunya layer yang boleh menyentuh    │
│  database. Hanya urusan query SQL           │
└─────────────────────────────────────────────┘
```

**Aturan penting:** setiap layer hanya boleh berkomunikasi dengan layer di bawahnya langsung. Handler tidak boleh langsung memanggil repository.

---

## Spesifikasi Tugas

### Struktur Folder yang Diharapkan

```
user-management/
├── main.go
├── handler/
│   └── user_handler.go
├── service/
│   └── user_service.go
├── repository/
│   └── user_repository.go
├── model/
│   └── user.go
└── README.md
```

---

### Yang Harus Dikerjakan

#### 1. Package `model` — Definisi Struct

Pindahkan struct `User` ke package `model`. Struct ini akan dipakai bersama oleh semua layer.

```go
// model/user.go
package model

type User struct {
    ID    int
    Name  string
    Email string
}
```

---

#### 2. Package `repository` — Akses Database

Pindahkan semua kode query dari sesi 9 ke sini. Repository adalah satu-satunya tempat kode GORM (`db.Raw`, `db.Exec`) boleh berada.

```go
// repository/user_repository.go
package repository

import (
    "errors"
    "user-management/model"
    "gorm.io/gorm"
)

// Sentinel error — didefinisikan di layer ini agar bisa dicek oleh layer atas
var ErrNotFound = errors.New("user tidak ditemukan")

type UserRepository struct {
    db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
    return &UserRepository{db: db}
}
```

Setiap method mengembalikan `ErrNotFound` ketika `RowsAffected == 0`, sehingga layer atas tahu persis apa yang terjadi tanpa harus parsing pesan error.

> **Hint:** Gunakan `fmt.Errorf("findByID: %w", ErrNotFound)` untuk membungkus error sekaligus menambahkan konteks dari mana error berasal.

---

#### 3. Package `service` — Logika Bisnis

Pindahkan **logika validasi** dari sesi 9 ke sini. Service tidak boleh berisi kode GORM — ia hanya memanggil repository dan memproses hasilnya.

```go
// service/user_service.go
package service

import (
    "errors"
    "fmt"
    "user-management/repository"
)

// Sentinel error milik service layer — berbeda dari repository.ErrNotFound
var ErrValidation = errors.New("validasi gagal")

type UserService struct {
    repo *repository.UserRepository
}

func NewUserService(repo *repository.UserRepository) *UserService {
    return &UserService{repo: repo}
}
```

Saat repository mengembalikan error, service membungkusnya dengan konteks tambahan:

```go
func (s *UserService) GetUserByID(id int) (*model.User, error) {
    user, err := s.repo.FindByID(id)
    if err != nil {
        // Bungkus dengan %w agar errors.Is tetap bisa mendeteksi ErrNotFound
        return nil, fmt.Errorf("GetUserByID: %w", err)
    }
    return user, nil
}
```

Pindahkan juga validasi input ke service:

- Nama dan email tidak boleh kosong → kembalikan `ErrValidation`
- Cek keberadaan user sebelum update/delete → cek apakah error dari repo adalah `repository.ErrNotFound`

---

#### 4. Package `handler` — Interaksi dengan User

Pindahkan semua logika menu CLI dari `main.go` ke handler. Handler tidak boleh berisi validasi bisnis atau query database — tugasnya hanya membaca input dan menampilkan output.

```go
// handler/user_handler.go
package handler

type UserHandler struct {
    service *service.UserService
}

func NewUserHandler(svc *service.UserService) *UserHandler {
    return &UserHandler{service: svc}
}

func (h *UserHandler) Run() { ... } // main loop menu
```

Di handler, gunakan `errors.Is` untuk menampilkan pesan yang tepat berdasarkan jenis error:

```go
user, err := h.service.GetUserByID(id)
if err != nil {
    if errors.Is(err, repository.ErrNotFound) {
        fmt.Println("[!] User dengan ID tersebut tidak ditemukan.")
    } else if errors.Is(err, service.ErrValidation) {
        fmt.Println("[!] Input tidak valid:", err)
    } else {
        fmt.Println("[!] Terjadi kesalahan:", err)
    }
    return
}
```

> **Kenapa ini penting?** Tanpa `errors.Is`, handler harus membandingkan string pesan error — cara yang rapuh dan mudah salah. `errors.Is` bekerja bahkan ketika error sudah dibungkus berkali-kali dengan `%w`.

---

#### 5. `main.go` — Titik Temu Semua Layer

`main.go` bertugas merakit semua layer dan menjalankan program.

```go
func main() {
    db, err := openDB()
    if err != nil {
        log.Fatal("Gagal konek ke database:", err)
    }

    repo    := repository.NewUserRepository(db)
    svc     := service.NewUserService(repo)
    h       := handler.NewUserHandler(svc)

    h.Run()
}
```

---

### Kriteria Keberhasilan (Acceptance Criteria)

- [ ] Kode terbagi ke dalam package `model`, `repository`, `service`, `handler`
- [ ] `main.go` hanya berisi inisialisasi dan perakitan layer
- [ ] Handler tidak mengandung logika validasi atau query database
- [ ] Service tidak mengandung kode GORM (`db.Raw`, `db.Exec`, dll.)
- [ ] Repository adalah satu-satunya tempat kode GORM berada
- [ ] Setiap layer mendefinisikan sentinel error-nya sendiri (`errors.New`)
- [ ] Error antar layer dibungkus dengan `fmt.Errorf("...: %w", err)`
- [ ] Handler menggunakan `errors.Is` untuk menampilkan pesan yang sesuai
- [ ] Semua fungsionalitas sesi 9 tetap berjalan dengan benar setelah refactor
- [ ] Program bisa di-build tanpa error (`go build ./...`)

---

## Panduan Teknis

### Error Handling Antar Layer

Ketika kode dipisah ke banyak layer, muncul pertanyaan: _"kalau query di repository gagal, bagaimana handler tahu apa yang salah?"_

Jawaban Go: **sentinel error + error wrapping**.

```
repository          service                  handler
──────────          ───────                  ───────
ErrNotFound   →   fmt.Errorf("%w")   →   errors.Is(err, ErrNotFound)
```

**`errors.New`** — mendefinisikan error unik yang bisa dikenali:

```go
var ErrNotFound = errors.New("user tidak ditemukan")
```

**`fmt.Errorf` dengan `%w`** — membungkus error sambil menambahkan konteks:

```go
return nil, fmt.Errorf("FindByID: %w", ErrNotFound)
// hasilnya: "FindByID: user tidak ditemukan"
// tapi errors.Is(err, ErrNotFound) tetap true
```

**`errors.Is`** — memeriksa apakah suatu error (atau yang dibungkus di dalamnya) adalah error tertentu:

```go
if errors.Is(err, repository.ErrNotFound) {
    // tampilkan pesan "tidak ditemukan"
}
```

> **Perbedaan dengan membandingkan string:** `err.Error() == "user tidak ditemukan"` akan gagal begitu error dibungkus. `errors.Is` tidak.

### Cara Membuat Go Module

Pastikan nama module di `go.mod` konsisten dengan import path yang kamu pakai:

```bash
go mod init user-management
```

Lalu setiap import antar package menggunakan prefix module name, contoh:

```go
import "user-management/repository"
```

### Batasan & Ketentuan Teknis

- **Bahasa:** Go
- **Database:** MySQL
- **ORM:** GORM (`gorm.io/gorm`)
- **Utamakan** `db.Raw` dan `db.Exec` di repository layer
- Semua query tetap menggunakan parameterized query (`?`)

---

## Bonus (Opsional)

> Tidak wajib. Kerjakan hanya setelah semua acceptance criteria terpenuhi.

- [ ] **Tambah field `CreatedAt`** pada struct `User` dan kolom database. Isi otomatis saat INSERT menggunakan `NOW()` di query SQL
- [ ] **Cari User:** Tambahkan method `SearchByName(keyword string)` di repository dan service, lalu tambahkan menu baru di handler
- [ ] **Pisahkan koneksi DB:** Pindahkan fungsi `openDB` ke package `config` tersendiri (`config/database.go`)

---

## Format Pengumpulan

- Kirim link GitHub repository ke grup
- Struktur folder harus sesuai spesifikasi di atas
- `README.md` harus berisi:
  - Cara setup database
  - Cara menjalankan program
  - Penjelasan singkat tanggung jawab masing-masing layer (3–4 kalimat)

---

## Referensi & Bahan Bacaan

- [Dasar Pemrograman Golang — Package](https://dasarpemrogramangolang.novalagung.com/A-packages.html)
- [Dasar Pemrograman Golang — Error](https://dasarpemrogramangolang.novalagung.com/A-error.html)
- [Go by Example: Errors](https://gobyexample.com/errors)
- [Go by Example: Error Wrapping](https://gobyexample.com/errors)
- [GORM — Raw SQL & SQL Builder](https://gorm.io/docs/sql_builder.html)

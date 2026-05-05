# Mini Project: CLI POS with Database

> **Tipe:** `Mini Project`  
> **Modul / Topik:** Module 2 — Database Integration  
> **Level:** `Intermediate`  
> **Estimasi Waktu:** 6–8 jam  
> **Sesi:** Mini Project (Ujian Modul 2)

---

## Deskripsi

Di mini project Module 1, kamu membangun CLI POS yang menyimpan data di **memori**. Setiap kali program ditutup, semua data produk dan riwayat transaksi hilang.

Di mini project Module 2 ini, kamu akan **merefactor** project tersebut agar:

1. Semua data tersimpan secara permanen di **MySQL**
2. Kode diorganisir menggunakan **layered architecture**: `model`, `repository`, `service`, `handler`, `config`
3. Ditambah fitur **manajemen customer** dan **status transaksi**
4. Tersedia menu **Laporan** baru yang menggunakan query SQL agregat

---

## Tujuan Pembelajaran

Setelah menyelesaikan mini project ini, kamu diharapkan mampu:

- [ ] Menghubungkan aplikasi Go ke MySQL menggunakan GORM
- [ ] Melakukan operasi CRUD dengan raw SQL (`db.Raw`, `db.Exec`) di repository layer
- [ ] Memisahkan kode ke dalam package yang punya tanggung jawab masing-masing
- [ ] Menulis query SQL dengan `JOIN`, `GROUP BY`, dan fungsi agregat
- [ ] Membungkus dan memeriksa error antar layer menggunakan `fmt.Errorf` dan `errors.Is`

---

## Prasyarat

- Mini project Module 1 sudah selesai (sebagai referensi logika bisnis)
- Exercise sesi 9 & 10 sudah selesai
- MySQL terinstall dan berjalan di lokal
- Go 1.21+
- GORM dan driver MySQL sudah diinstall:
  ```bash
  go get gorm.io/gorm
  go get gorm.io/driver/mysql
  ```

---

## Persiapan Database

### 1. Buat Database dan Tabel

```bash
mysql -u root -p < schema.sql
```

### 2. Isi Seed Data

Seed data menyediakan 7 customer, 10 produk, dan 34 transaksi historis (14 hari terakhir + hari ini) agar fitur laporan bisa langsung diuji.

```bash
mysql -u root -p pos_db < seed.sql
```

> Kedua file (`schema.sql` dan `seed.sql`) tersedia di folder yang sama dengan dokumen ini.

---

## Skema Database

```
┌─────────────┐       ┌──────────────────────┐       ┌─────────────┐
│  customers  │       │     transactions     │       │  products   │
│─────────────│       │──────────────────────│       │─────────────│
│ id          │◄──────│ customer_id (FK, NN) │       │ id          │
│ name        │  N:1  │ total                │       │ name        │
│ phone       │       │ paid_amount          │       │ price       │
│ address     │       │ change_amount        │       │ stock       │
└─────────────┘       │ date (DATETIME)      │       └──────┬──────┘
                      │ status               │              │
                      │ created_at           │              │
                      └──────────┬───────────┘              │
                                 │ 1:N                      │
                      ┌──────────▼───────────┐              │
                      │  transaction_items   │              │
                      │──────────────────────│              │
                      │ transaction_id (FK)  │              │
                      │ product_id (FK) ─────┼──────────────┘
                      │ price  ← denormalisasi│
                      │ quantity             │
                      │ subtotal             │
                      └──────────────────────┘
```

**Catatan penting:**

- `customer_id` **wajib diisi** — setiap transaksi harus terhubung ke customer terdaftar
- `price` di `transaction_items` disimpan langsung (bukan JOIN ke products) agar harga di struk tidak berubah walaupun harga produk diupdate di kemudian hari
- `status` transaksi memiliki 3 nilai: `waiting` → `paid` → `completed`

---

## Struktur Folder yang Diharapkan

```
cli-pos-db/
├── main.go
├── go.mod
├── config/
│   └── database.go
├── model/
│   ├── product.go
│   ├── customer.go
│   └── transaction.go
├── repository/
│   ├── product_repository.go
│   ├── customer_repository.go
│   └── transaction_repository.go
├── service/
│   ├── product_service.go
│   ├── customer_service.go
│   └── transaction_service.go
├── handler/
│   ├── product_handler.go
│   ├── customer_handler.go
│   ├── transaction_handler.go
│   └── report_handler.go
└── README.md
```

---

## Menu Utama

```
===================================
          CLI POS — v2.0
===================================
  1. Kelola Produk
  2. Kelola Customer
  3. Transaksi Baru
  4. Laporan
  0. Keluar
===================================
Pilih menu:
```

### Sub-menu: Kelola Produk

```
=== KELOLA PRODUK ===
  1. Tambah Produk
  2. Lihat Daftar Produk
  3. Update Stok Produk
  4. Hapus Produk
  0. Kembali
```

### Sub-menu: Kelola Customer

```
=== KELOLA CUSTOMER ===
  1. Tambah Customer
  2. Lihat Daftar Customer
  3. Detail Customer
  4. Hapus Customer
  0. Kembali
```

### Sub-menu: Transaksi Baru

Transaksi baru tidak memiliki sub-menu — saat dipilih, program langsung memulai alur transaksi secara berurutan:

```
=== TRANSAKSI BARU ===
[Daftar customer ditampilkan]
Pilih Customer (ID): _

[Daftar produk ditampilkan]
Pilih Produk (ID, 0 = selesai): _
Qty: _

[ulangi sampai user input 0]

=== Ringkasan Pesanan ===
[daftar item + subtotal]
Total        : Rp XX.XXX
Nominal Bayar: _
Kembalian    : Rp XX.XXX
[struk dicetak & transaksi tersimpan]
```

### Sub-menu: Laporan

```
=== LAPORAN PENJUALAN ===
  1. Ringkasan Hari Ini
  2. Produk Terlaris (Top 5)
  3. Riwayat Transaksi
  0. Kembali
```

---

## Spesifikasi Tugas

### Layer 1 — `model`

Package `model` hanya berisi definisi struct. Tidak ada logika di sini.

```go
// model/product.go
package model

type Product struct {
    ID    int
    Name  string
    Price int
    Stock int
}
```

```go
// model/customer.go
package model

type Customer struct {
    ID      int
    Name    string
    Phone   string
    Address string
}
```

```go
// model/transaction.go
package model

import "time"

type TransactionItem struct {
    ID            int
    TransactionID int
    ProductID     int
    Price         int
    Quantity      int
    Subtotal      int
    // diisi saat query JOIN dengan products — tidak ada di tabel transaction_items
    ProductName string
}

type Transaction struct {
    ID           int
    CustomerID   int
    Customer     *Customer
    Items        []TransactionItem
    Total        int
    PaidAmount   int
    ChangeAmount int
    Date         time.Time
    Status       string // "waiting" | "paid" | "completed"
    CreatedAt    time.Time
}
```

> **Catatan:** Field `ProductName` di `TransactionItem` tidak disimpan di database — ia hanya diisi saat membaca data menggunakan query JOIN dengan tabel `products`.

---

### Layer 2 — `repository`

Repository adalah **satu-satunya tempat** kode database (`db.Raw`, `db.Exec`) boleh berada.

```go
// repository/product_repository.go
package repository

import (
    "errors"
    "cli-pos-db/model"
    "gorm.io/gorm"
)

var ErrNotFound = errors.New("data tidak ditemukan")

type ProductRepository struct {
    db *gorm.DB
}

func NewProductRepository(db *gorm.DB) *ProductRepository {
    return &ProductRepository{db: db}
}
```

**Method `ProductRepository`:**

| Method                                     | Hint                               |
| ------------------------------------------ | ---------------------------------- |
| `FindAll() ([]model.Product, error)`       | `SELECT` + `ORDER BY`              |
| `FindByID(id int) (*model.Product, error)` | `SELECT` + `WHERE id = ?`          |
| `Create(p *model.Product) error`           | `INSERT INTO ... VALUES (?, ?, ?)` |
| `UpdateStock(id, newStock int) error`      | `UPDATE ... SET ... WHERE id = ?`  |
| `Delete(id int) error`                     | `DELETE FROM ... WHERE id = ?`     |

Kembalikan `ErrNotFound` jika `RowsAffected == 0` pada UPDATE dan DELETE.

**Method `CustomerRepository`:**

| Method                                      | Hint                               |
| ------------------------------------------- | ---------------------------------- |
| `FindAll() ([]model.Customer, error)`       | `SELECT` + `ORDER BY`              |
| `FindByID(id int) (*model.Customer, error)` | `SELECT` + `WHERE id = ?`          |
| `Create(c *model.Customer) error`           | `INSERT INTO ... VALUES (?, ?, ?)` |
| `Delete(id int) error`                      | `DELETE FROM ... WHERE id = ?`     |

**Method `TransactionRepository`:**

| Method                                               | Keterangan                                                                                       |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `Create(t *model.Transaction) error`                 | `INSERT` ke `transactions`, ambil last insert ID, lalu `INSERT` tiap item ke `transaction_items` |
| `UpdateStatus(id int, status string) error`          | `UPDATE ... SET ... WHERE id = ?`                                                                |
| `FindRecent(limit int) ([]model.Transaction, error)` | `SELECT` + `JOIN customers` + `ORDER BY` + `LIMIT`                                               |

> **Hint menyimpan transaksi:**
>
> ```go
> db.Exec("INSERT INTO transactions (customer_id, total, ...) VALUES (?, ?, ...)", ...)
> var lastID int
> db.Raw("SELECT LAST_INSERT_ID()").Scan(&lastID)
> // gunakan lastID untuk INSERT ke transaction_items
> ```

> **Hint membaca nama produk di items:**
>
> ```sql
> SELECT ti.*, p.name AS product_name
> FROM transaction_items ti
> JOIN products p ON p.id = ti.product_id
> WHERE ti.transaction_id = ?
> ```

---

### Layer 3 — `service`

Service berisi **logika bisnis dan validasi**. Tidak ada kode GORM di sini.

```go
// service/product_service.go
package service

import (
    "errors"
    "fmt"
    "cli-pos-db/repository"
)

var ErrValidation = errors.New("input tidak valid")

type ProductService struct {
    repo *repository.ProductRepository
}

func NewProductService(repo *repository.ProductRepository) *ProductService {
    return &ProductService{repo: repo}
}
```

**Validasi di `ProductService`:**

- `Create`: nama tidak boleh kosong, harga > 0, stok ≥ 0 → kembalikan `ErrValidation`
- `UpdateStock`: stok baru tidak boleh negatif → kembalikan `ErrValidation`
- Bungkus error dari repo: `fmt.Errorf("UpdateStock: %w", err)`

**Validasi di `CustomerService`:**

- `Create`: nama, phone, dan address tidak boleh kosong → kembalikan `ErrValidation`

**Logika di `TransactionService`:**

Method utama: `CreateTransaction(customerID int, items []model.TransactionItem, paid int) (*model.Transaction, error)`

1. Validasi customer ada — panggil `customerRepo.FindByID`
2. Untuk setiap item, ambil data produk dan validasi stok mencukupi
3. Hitung `subtotal` tiap item dan akumulasi `total`
4. Validasi `paid >= total` → `ErrValidation` jika kurang
5. Hitung `change = paid - total`
6. Simpan transaksi dengan status `"completed"` via `transactionRepo.Create`
7. Kurangi stok tiap produk via `productRepo.UpdateStock`
8. Kembalikan struct `Transaction` yang sudah lengkap

---

### Layer 4 — `handler`

Handler bertugas **membaca input dan menampilkan output** saja. Tidak ada validasi bisnis atau kode database.

```go
// handler/product_handler.go
package handler

type ProductHandler struct {
    service *service.ProductService
}

func NewProductHandler(svc *service.ProductService) *ProductHandler {
    return &ProductHandler{service: svc}
}

func (h *ProductHandler) Run() {
    // loop sub-menu Kelola Produk
}
```

Gunakan `errors.Is` untuk menampilkan pesan yang tepat:

```go
err := h.service.UpdateStock(id, newStock)
if err != nil {
    if errors.Is(err, repository.ErrNotFound) {
        fmt.Println("[!] Produk tidak ditemukan.")
    } else if errors.Is(err, service.ErrValidation) {
        fmt.Println("[!] Input tidak valid:", err)
    } else {
        fmt.Println("[!] Terjadi kesalahan:", err)
    }
    return
}
```

**`ReportHandler`** — query laporan diletakkan di `TransactionRepository`, handler hanya menampilkan hasilnya:

| Method                     | Deskripsi                                                           |
| -------------------------- | ------------------------------------------------------------------- |
| `ShowDailySummary()`       | Jumlah transaksi & total pendapatan hari ini (status = `completed`) |
| `ShowTopProducts()`        | 5 produk dengan qty terjual terbanyak (JOIN + GROUP BY)             |
| `ShowRecentTransactions()` | 10 transaksi terakhir beserta nama customer                         |

---

### `config/database.go`

```go
package config

import (
    "fmt"
    "gorm.io/driver/mysql"
    "gorm.io/gorm"
)

func NewDB(user, password, host, port, dbName string) (*gorm.DB, error) {
    dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true",
        user, password, host, port, dbName,
    )
    return gorm.Open(mysql.Open(dsn), &gorm.Config{})
}
```

---

### `main.go` — Perakitan Semua Layer

```go
func main() {
    db, err := config.NewDB("root", "password", "localhost", "3306", "pos_db")
    if err != nil {
        log.Fatal("Gagal koneksi ke database:", err)
    }

    productRepo     := repository.NewProductRepository(db)
    customerRepo    := repository.NewCustomerRepository(db)
    transactionRepo := repository.NewTransactionRepository(db)

    productSvc     := service.NewProductService(productRepo)
    customerSvc    := service.NewCustomerService(customerRepo)
    transactionSvc := service.NewTransactionService(transactionRepo, productRepo, customerRepo)

    productHandler     := handler.NewProductHandler(productSvc)
    customerHandler    := handler.NewCustomerHandler(customerSvc)
    transactionHandler := handler.NewTransactionHandler(transactionSvc, productSvc, customerSvc)
    reportHandler      := handler.NewReportHandler(transactionRepo)

    for {
        // tampilkan menu utama dan arahkan ke handler yang sesuai
    }
}
```

---

## Panduan Teknis

### Hint untuk Fitur Laporan

**Ringkasan Hari Ini** (hanya transaksi `completed`):

- Gunakan `COUNT(*)` dan `SUM(total)` untuk menghitung jumlah transaksi dan total pendapatan
- Filter dengan `DATE(date) = CURDATE()` untuk hari ini dan `status = 'completed'`
- Gunakan `COALESCE(..., 0)` agar hasil tidak `NULL` saat belum ada transaksi

**Produk Terlaris:**

- Gunakan `JOIN` antara `transaction_items` dan `products`
- Gunakan `SUM(quantity)` dan `GROUP BY product_id` untuk menghitung total terjual per produk
- Urutkan dengan `ORDER BY ... DESC` dan batasi dengan `LIMIT 5`

**Riwayat Transaksi Terakhir:**

- Gunakan `JOIN` antara `transactions` dan `customers` untuk mendapatkan nama customer
- Urutkan dengan `ORDER BY date DESC` dan batasi dengan `LIMIT ?`

### Alur Transaksi Baru

```
1. Tampilkan daftar customer → user pilih customer (input ID)
2. Tampilkan daftar produk
3. Loop: user pilih produk berdasarkan ID + masukkan qty (input 0 untuk selesai)
   └── Validasi: produk ada, qty > 0, stok mencukupi
4. Tampilkan ringkasan keranjang + total
5. Minta input nominal bayar
   └── Validasi: bayar ≥ total
6. Simpan ke database (status: "completed")
7. Tampilkan struk: nama produk, qty, subtotal, total, bayar, kembalian
```

### Batasan & Ketentuan Teknis

- **Bahasa:** Go
- **Database:** MySQL
- **ORM:** GORM (`gorm.io/gorm`)
- Gunakan `db.Raw` dan `db.Exec` di repository — **bukan** method ORM bawaan seperti `db.Create`, `db.Find`
- Semua query menggunakan parameterized query (`?`) — **jangan** interpolasi string langsung ke SQL

---

## Kriteria Keberhasilan (Acceptance Criteria)

### Fungsionalitas

- [ ] Tambah / lihat / update stok / hapus **produk** — data tersimpan di database
- [ ] Tambah / lihat / detail / hapus **customer** — data tersimpan di database
- [ ] **Transaksi baru** menyimpan data ke `transactions` dan `transaction_items`
- [ ] Stok produk berkurang di database setelah transaksi selesai
- [ ] Struk belanja ditampilkan dengan nama produk, qty, subtotal, total, bayar, kembalian
- [ ] Menu **Ringkasan Hari Ini** menampilkan jumlah transaksi dan total pendapatan hari ini
- [ ] Menu **Produk Terlaris** menampilkan 5 produk dengan qty terjual terbanyak (menggunakan `GROUP BY`)
- [ ] Menu **Riwayat Transaksi** menampilkan 10 transaksi terakhir dengan nama customer (menggunakan `JOIN`)

### Layered Architecture

- [ ] Kode terbagi ke dalam package: `model`, `repository`, `service`, `handler`, `config`
- [ ] `main.go` hanya berisi inisialisasi dan perakitan layer
- [ ] `repository` adalah satu-satunya tempat `db.Raw` / `db.Exec` berada
- [ ] `service` tidak mengandung kode GORM
- [ ] `handler` tidak mengandung validasi bisnis atau query database
- [ ] Error antar layer dibungkus dengan `fmt.Errorf("context: %w", err)`
- [ ] Handler menggunakan `errors.Is` untuk membedakan jenis error

### Build & Run

- [ ] Program bisa di-build tanpa error: `go build ./...`
- [ ] Program bisa berjalan dan terhubung ke database

---

## Bonus (Opsional)

> Tidak wajib. Kerjakan hanya setelah semua acceptance criteria terpenuhi.

- [ ] **Update status transaksi:** Tambahkan fitur untuk mengubah status transaksi dari `waiting` → `paid` → `completed`
- [ ] **Laporan stok rendah:** Tampilkan produk dengan stok di bawah threshold tertentu (misal stok < 10)
- [ ] **Cari customer:** Tambahkan fitur pencarian customer berdasarkan nama menggunakan `LIKE`
- [ ] **Hapus produk dengan validasi:** Cegah penghapusan produk yang sudah pernah ada di `transaction_items`

---

## Format Pengumpulan

- Kirim link GitHub repository ke grup
- Struktur folder harus sesuai spesifikasi di atas
- `README.md` harus berisi:
  - Cara setup database (jalankan `schema.sql` lalu `seed.sql`)
  - Cara menjalankan program
  - Penjelasan singkat tanggung jawab masing-masing layer (2–3 kalimat per layer)

---

## Referensi & Bahan Bacaan

- [Dasar Pemrograman Golang — Package](https://dasarpemrogramangolang.novalagung.com/A-packages.html)
- [Dasar Pemrograman Golang — Error](https://dasarpemrogramangolang.novalagung.com/A-error.html)
- [GORM — Raw SQL & SQL Builder](https://gorm.io/docs/sql_builder.html)
- [Go by Example: Error Wrapping](https://gobyexample.com/errors)
- [MySQL — GROUP BY dan Agregat](https://dev.mysql.com/doc/refman/8.0/en/group-by-functions.html)
- [MySQL — JOIN](https://dev.mysql.com/doc/refman/8.0/en/join.html)

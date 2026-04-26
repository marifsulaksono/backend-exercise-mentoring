# Exercise: CLI User Management with Database

> **Tipe:** `Exercise`  
> **Modul / Topik:** Module 2 — Database Integration  
> **Level:** `Intermediate`  
> **Estimasi Waktu:** 3–5 jam  
> **Sesi:** 9

---

## Deskripsi

Kamu akan membangun aplikasi **CLI User Management** yang terhubung langsung ke database MySQL. Berbeda dengan mini project sebelumnya yang menyimpan data di memory, kali ini semua data tersimpan secara permanen — data tidak hilang saat program ditutup.

Ini adalah pola CRUD yang paling fundamental di dunia backend, dan hampir setiap aplikasi nyata memilikinya.

---

## Tujuan Pembelajaran

Setelah menyelesaikan exercise ini, kamu diharapkan mampu:

- [ ] Membuka koneksi ke database menggunakan GORM
- [ ] Menjalankan raw SQL query (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) menggunakan `db.Raw` dan `db.Exec`
- [ ] Membaca hasil query ke dalam struct menggunakan `.Scan`
- [ ] Memahami kapan pakai `db.Raw` vs method bawaan GORM
- [ ] Menangani error dari operasi database dengan benar

---

## Prasyarat

Sebelum mengerjakan, pastikan kamu sudah memahami dan menyiapkan:

- Materi sesi sebelumnya (struct, method, control flow, I/O)
- MySQL terinstall dan berjalan di lokal
- Mengetahui cara membuat database dan tabel di MySQL
- GORM dan driver MySQL sudah diinstall:
  ```bash
  go get gorm.io/gorm
  go get gorm.io/driver/mysql
  ```

---

## Persiapan Database

Sebelum menjalankan program, buat database dan tabel berikut di MySQL:

```sql
CREATE DATABASE mentoring_db;

USE mentoring_db;

CREATE TABLE users (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);
```

---

## Spesifikasi Tugas

### Konteks / Studi Kasus

Kamu adalah backend developer yang diminta membangun modul manajemen pengguna untuk sebuah aplikasi internal. Admin dapat melihat daftar user, melihat detail satu user, menambah user baru, memperbarui data user, dan menghapus user — semuanya melalui terminal dan tersimpan ke database.

---

### Menu Utama

Program harus menampilkan menu utama seperti ini dan berjalan dalam loop hingga user memilih keluar:

```
===================================
        USER MANAGEMENT
===================================
  1. Lihat Daftar User
  2. Detail User
  3. Tambah User
  4. Update User
  5. Hapus User
  0. Keluar
===================================
Pilih menu:
```

---

### Fitur yang Harus Diimplementasikan

#### 1. Lihat Daftar User
- Ambil semua user dari database (`SELECT`)
- Tampilkan dalam format tabel: ID, Nama, Email
- Jika belum ada user, tampilkan pesan informatif

#### 2. Detail User
- Minta input ID user
- Ambil satu user berdasarkan ID (`SELECT ... WHERE id = ?`)
- Tampilkan seluruh data user tersebut
- Jika ID tidak ditemukan, tampilkan pesan yang jelas

#### 3. Tambah User
- Minta input nama dan email
- Validasi: nama dan email tidak boleh kosong
- Simpan ke database (`INSERT`)
- Tampilkan konfirmasi dengan ID yang baru dibuat

#### 4. Update User
- Minta input ID user yang ingin diubah
- Pastikan user dengan ID tersebut ada — jika tidak, tampilkan error
- Minta input nama dan email baru
- Perbarui data di database (`UPDATE ... WHERE id = ?`)
- Tampilkan konfirmasi perubahan

#### 5. Hapus User
- Minta input ID user yang ingin dihapus
- Pastikan user dengan ID tersebut ada — jika tidak, tampilkan error
- Hapus dari database (`DELETE ... WHERE id = ?`)
- Tampilkan konfirmasi penghapusan

---

### Kriteria Keberhasilan (Acceptance Criteria)

- [ ] Program berhasil terhubung ke database saat dijalankan
- [ ] Program berjalan dalam loop — tidak langsung berhenti setelah satu aksi
- [ ] Semua 5 menu berfungsi dengan benar dan data tersimpan di database
- [ ] Data tetap ada saat program ditutup dan dijalankan ulang
- [ ] ID yang tidak ditemukan ditangani dengan pesan error yang jelas (bukan panic/crash)
- [ ] Semua input divalidasi: tidak boleh kosong, tipe data harus sesuai
- [ ] Menggunakan **parameterized query** (`?`) — tidak boleh menyisipkan input user langsung ke string SQL
- [ ] Program tidak crash untuk input yang tidak valid

---

## Panduan Teknis

### Struct yang Disarankan

```go
type User struct {
    ID    int
    Name  string
    Email string
}
```

> GORM biasanya menggunakan tag `gorm:"..."` pada struct, tapi untuk exercise ini kamu **tidak perlu tag apapun** karena kita akan menulis semua query secara manual.

### Pola Koneksi Database

```go
import (
    "gorm.io/driver/mysql"
    "gorm.io/gorm"
)

func openDB() (*gorm.DB, error) {
    dsn := "root:password@tcp(127.0.0.1:3306)/mentoring_db?charset=utf8mb4&parseTime=True&loc=Local"
    db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
    if err != nil {
        return nil, err
    }
    return db, nil
}
```

### Kapan Pakai Apa?

| Fungsi | Kapan dipakai |
|---|---|
| `db.Raw("SELECT ...").Scan(&result)` | SELECT — tulis query sendiri, hasil di-scan ke struct atau slice |
| `db.Exec("INSERT/UPDATE/DELETE ...")` | Operasi tulis — tidak mengembalikan baris data |

> **Catatan:** GORM punya method seperti `.Find()`, `.First()`, `.Create()` yang bisa melakukan hal yang sama secara otomatis. Tapi di exercise ini, **utamakan `db.Raw` dan `db.Exec`** agar kamu benar-benar memahami SQL yang berjalan di baliknya.

### Cara Menggunakan `db.Raw` dan `db.Exec`

```go
// SELECT banyak baris → scan ke slice
var users []User
result := db.Raw("SELECT id, name, email FROM users").Scan(&users)
if result.Error != nil {
    // tangani error
}

// SELECT satu baris → scan ke struct
var user User
result := db.Raw("SELECT id, name, email FROM users WHERE id = ?", id).Scan(&user)
if result.Error != nil {
    // tangani error
}
if result.RowsAffected == 0 {
    // user tidak ditemukan
}

// INSERT / UPDATE / DELETE
result := db.Exec("INSERT INTO users (name, email) VALUES (?, ?)", name, email)
if result.Error != nil {
    // tangani error
}
```

> **Hint:** Berbeda dengan `database/sql` yang menggunakan `sql.ErrNoRows`, GORM menggunakan `result.RowsAffected == 0` untuk mendeteksi baris yang tidak ditemukan saat menggunakan `db.Raw`.

### Batasan & Ketentuan Teknis

- **Bahasa:** Go
- **Database:** MySQL
- **ORM:** GORM (`gorm.io/gorm`)
- **Boleh menggunakan:** `gorm.io/gorm`, `gorm.io/driver/mysql`, `fmt`, `strings`
- **Utamakan:** `db.Raw` dan `db.Exec` untuk semua operasi query
- **Boleh menggunakan method GORM** (`.Find`, `.First`, dll.) hanya untuk bagian yang benar-benar tidak memerlukan custom SQL
- **Wajib:** Semua query menggunakan parameterized query (`?`), bukan string concatenation

---

## Bonus (Opsional)

> Tidak wajib. Kerjakan bonus hanya setelah semua fitur wajib selesai.

- [ ] **Validasi format email:** Pastikan input email mengandung karakter `@` dan `.`
- [ ] **Tangani duplicate email:** Jika email sudah terdaftar saat INSERT atau UPDATE, tampilkan pesan error yang informatif (bukan pesan error mentah dari MySQL)
- [ ] **Pencarian user:** Tambahkan menu "Cari User" berdasarkan nama menggunakan `LIKE ?`

---

## Format Pengumpulan

- Kirim link GitHub repository ke grup
- Struktur folder yang diharapkan:

  ```
  user-management/
  ├── main.go
  └── README.md
  ```

- `README.md` harus berisi:
  - Cara setup database (perintah SQL untuk buat tabel)
  - Cara menjalankan program
  - Contoh output

---

## Referensi & Bahan Bacaan

- [Dasar Pemrograman Golang — SQL](https://dasarpemrogramangolang.novalagung.com/A-sql.html)
- [GORM — Raw SQL & SQL Builder](https://gorm.io/docs/sql_builder.html)
- [GORM — Connecting to a Database](https://gorm.io/docs/connecting_to_the_database.html)
- [MySQL Tutorial — Sample Database](https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/)

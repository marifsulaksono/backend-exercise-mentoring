-- =============================================================
--  CLI POS — Module 2 Seed Data
--  Jalankan dengan: mysql -u root -p pos_db < seed.sql
--  Pastikan database & tabel sudah dibuat terlebih dahulu.
-- =============================================================

USE pos_db;

-- Kosongkan tabel dulu (urutan penting karena ada foreign key)
TRUNCATE transaction_items;
TRUNCATE transactions;
TRUNCATE customers;
TRUNCATE products;

-- =============================================================
--  CUSTOMERS
-- =============================================================

INSERT INTO customers (name, phone, address) VALUES
    ('Budi Santoso',   '081234567890', 'Jl. Merdeka No. 1, Jakarta'),
    ('Siti Rahayu',    '082345678901', 'Jl. Sudirman No. 5, Bandung'),
    ('Agus Wijaya',    '083456789012', 'Jl. Diponegoro No. 12, Surabaya'),
    ('Dewi Lestari',   '084567890123', 'Jl. Gatot Subroto No. 8, Semarang'),
    ('Rizky Pratama',  '085678901234', 'Jl. Ahmad Yani No. 3, Yogyakarta'),
    ('Fitri Handayani','086789012345', 'Jl. Pahlawan No. 7, Malang'),
    ('Hendra Kurnia',  '087890123456', 'Jl. Veteran No. 15, Medan');

-- =============================================================
--  PRODUK
--  Stok yang tersimpan sudah memperhitungkan penjualan historis
--  dari 34 transaksi seed di bawah.
-- =============================================================

INSERT INTO products (name, price, stock) VALUES
    ('Kopi Hitam',    8000,  30),  -- terjual 20 dari stok awal 50
    ('Kopi Susu',    15000,  25),  -- terjual 15 dari stok awal 40
    ('Es Teh Manis',  7000,  39),  -- terjual 21 dari stok awal 60
    ('Mie Goreng',   20000,  17),  -- terjual 8  dari stok awal 25
    ('Nasi Goreng',  25000,  16),  -- terjual 14 dari stok awal 30
    ('Bakso',        18000,  12),  -- terjual 8  dari stok awal 20
    ('Pisang Goreng',10000,   4),  -- terjual 6  dari stok awal 10 (stok rendah!)
    ('Roti Bakar',   12000,   2),  -- terjual 6  dari stok awal 8  (stok rendah!)
    ('Jus Alpukat',  18000,   4),  -- terjual 6  dari stok awal 10 (stok rendah!)
    ('Air Mineral',   5000,  87);  -- terjual 13 dari stok awal 100

-- =============================================================
--  TRANSAKSI HISTORIS (34 transaksi, 14 hari terakhir + hari ini)
-- =============================================================

INSERT INTO transactions (customer_id, total, paid_amount, change_amount, date, status, created_at) VALUES
    -- 6 hari lalu
    (1, 44000, 50000,  6000, DATE_SUB(NOW(), INTERVAL 6 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 6 DAY)),  -- T1  Budi
    (2, 36000, 40000,  4000, DATE_SUB(NOW(), INTERVAL 6 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 6 DAY)),  -- T2  Siti
    -- 5 hari lalu
    (3, 57000, 60000,  3000, DATE_SUB(NOW(), INTERVAL 5 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 5 DAY)),  -- T3  Agus
    (4, 26000, 30000,  4000, DATE_SUB(NOW(), INTERVAL 5 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 5 DAY)),  -- T4  Dewi
    -- 4 hari lalu
    (5, 45000, 50000,  5000, DATE_SUB(NOW(), INTERVAL 4 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 4 DAY)),  -- T5  Rizky
    -- 3 hari lalu
    (6, 86000, 90000,  4000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 3 DAY)),  -- T6  Fitri
    (7, 34000, 35000,  1000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 3 DAY)),  -- T7  Hendra
    -- 2 hari lalu
    (1, 55000, 60000,  5000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 2 DAY)),  -- T8  Budi
    -- 1 hari lalu
    (2, 57000, 60000,  3000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 1 DAY)),  -- T9  Siti
    (3, 41000, 50000,  9000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 1 DAY)),  -- T10 Agus
    -- 7 hari lalu
    (4, 34000, 35000,  1000, DATE_SUB(NOW(), INTERVAL 7 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 7 DAY)),  -- T11 Dewi
    (5, 50000, 50000,     0, DATE_SUB(NOW(), INTERVAL 7 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 7 DAY)),  -- T12 Rizky
    (6, 45000, 50000,  5000, DATE_SUB(NOW(), INTERVAL 7 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 7 DAY)),  -- T13 Fitri
    -- 8 hari lalu
    (7, 42000, 50000,  8000, DATE_SUB(NOW(), INTERVAL 8 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 8 DAY)),  -- T14 Hendra
    (1, 33000, 35000,  2000, DATE_SUB(NOW(), INTERVAL 8 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 8 DAY)),  -- T15 Budi
    (2, 39000, 40000,  1000, DATE_SUB(NOW(), INTERVAL 8 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 8 DAY)),  -- T16 Siti
    -- 9 hari lalu
    (3, 65000, 70000,  5000, DATE_SUB(NOW(), INTERVAL 9 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 9 DAY)),  -- T17 Agus
    (4, 34000, 35000,  1000, DATE_SUB(NOW(), INTERVAL 9 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 9 DAY)),  -- T18 Dewi
    -- 10 hari lalu
    (5, 52000, 60000,  8000, DATE_SUB(NOW(), INTERVAL 10 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 10 DAY)), -- T19 Rizky
    (6, 30000, 30000,     0, DATE_SUB(NOW(), INTERVAL 10 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 10 DAY)), -- T20 Fitri
    -- 11 hari lalu
    (7, 55000, 60000,  5000, DATE_SUB(NOW(), INTERVAL 11 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 11 DAY)), -- T21 Hendra
    (1, 45000, 50000,  5000, DATE_SUB(NOW(), INTERVAL 11 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 11 DAY)), -- T22 Budi
    -- 12 hari lalu
    (2, 44000, 50000,  6000, DATE_SUB(NOW(), INTERVAL 12 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 12 DAY)), -- T23 Siti
    (3, 43000, 50000,  7000, DATE_SUB(NOW(), INTERVAL 12 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 12 DAY)), -- T24 Agus
    -- 13 hari lalu
    (4, 51000, 60000,  9000, DATE_SUB(NOW(), INTERVAL 13 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 13 DAY)), -- T25 Dewi
    (5, 55000, 60000,  5000, DATE_SUB(NOW(), INTERVAL 13 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 13 DAY)), -- T26 Rizky
    -- 14 hari lalu
    (6, 46000, 50000,  4000, DATE_SUB(NOW(), INTERVAL 14 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 14 DAY)), -- T27 Fitri
    (7, 68000, 70000,  2000, DATE_SUB(NOW(), INTERVAL 14 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 14 DAY)), -- T28 Hendra
    -- 2 hari lalu (tambahan)
    (1, 58000, 60000,  2000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 2 DAY)),   -- T29 Budi
    -- 1 hari lalu (tambahan)
    (2, 51000, 60000,  9000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'completed', DATE_SUB(NOW(), INTERVAL 1 DAY)),   -- T30 Siti
    -- Hari ini
    (3, 31000, 35000,  4000, NOW(), 'completed', NOW()),   -- T31 Agus
    (4, 39000, 40000,  1000, NOW(), 'paid',      NOW()),   -- T32 Dewi (sudah bayar, belum selesai)
    (5, 25000,     0,     0, NOW(), 'waiting',   NOW()),   -- T33 Rizky (belum bayar)
    (6, 47000,     0,     0, NOW(), 'waiting',   NOW());   -- T34 Fitri (belum bayar)

-- =============================================================
--  ITEM TRANSAKSI
-- =============================================================

INSERT INTO transaction_items
    (transaction_id, product_id, price, quantity, subtotal)
VALUES
    -- T1 (44.000): Kopi Susu x2 + Es Teh Manis x2
    (1,  2, 15000, 2, 30000),
    (1,  3,  7000, 2, 14000),

    -- T2 (36.000): Kopi Hitam x2 + Mie Goreng x1
    (2,  1,  8000, 2, 16000),
    (2,  4, 20000, 1, 20000),

    -- T3 (57.000): Nasi Goreng x2 + Es Teh Manis x1
    (3,  5, 25000, 2, 50000),
    (3,  3,  7000, 1,  7000),

    -- T4 (26.000): Bakso x1 + Kopi Hitam x1
    (4,  6, 18000, 1, 18000),
    (4,  1,  8000, 1,  8000),

    -- T5 (45.000): Pisang Goreng x3 + Kopi Susu x1
    (5,  7, 10000, 3, 30000),
    (5,  2, 15000, 1, 15000),

    -- T6 (86.000): Nasi Goreng x2 + Jus Alpukat x2
    (6,  5, 25000, 2, 50000),
    (6,  9, 18000, 2, 36000),

    -- T7 (34.000): Roti Bakar x2 + Air Mineral x2
    (7,  8, 12000, 2, 24000),
    (7, 10,  5000, 2, 10000),

    -- T8 (55.000): Mie Goreng x2 + Kopi Susu x1
    (8,  4, 20000, 2, 40000),
    (8,  2, 15000, 1, 15000),

    -- T9 (57.000): Bakso x2 + Es Teh Manis x3
    (9,  6, 18000, 2, 36000),
    (9,  3,  7000, 3, 21000),

    -- T10 (41.000): Nasi Goreng x1 + Kopi Hitam x2
    (10,  5, 25000, 1, 25000),
    (10,  1,  8000, 2, 16000),

    -- T11 (34.000): Kopi Hitam x3 + Air Mineral x2
    (11,  1,  8000, 3, 24000),
    (11, 10,  5000, 2, 10000),

    -- T12 (50.000): Nasi Goreng x1 + Bakso x1 + Es Teh Manis x1
    (12,  5, 25000, 1, 25000),
    (12,  6, 18000, 1, 18000),
    (12,  3,  7000, 1,  7000),

    -- T13 (45.000): Pisang Goreng x1 + Kopi Susu x2 + Air Mineral x1
    (13,  7, 10000, 1, 10000),
    (13,  2, 15000, 2, 30000),
    (13, 10,  5000, 1,  5000),

    -- T14 (42.000): Kopi Susu x2 + Roti Bakar x1
    (14,  2, 15000, 2, 30000),
    (14,  8, 12000, 1, 12000),

    -- T15 (33.000): Mie Goreng x1 + Kopi Hitam x1 + Air Mineral x1
    (15,  4, 20000, 1, 20000),
    (15,  1,  8000, 1,  8000),
    (15, 10,  5000, 1,  5000),

    -- T16 (39.000): Roti Bakar x2 + Kopi Hitam x1 + Es Teh Manis x1
    (16,  8, 12000, 2, 24000),
    (16,  1,  8000, 1,  8000),
    (16,  3,  7000, 1,  7000),

    -- T17 (65.000): Nasi Goreng x2 + Kopi Susu x1
    (17,  5, 25000, 2, 50000),
    (17,  2, 15000, 1, 15000),

    -- T18 (34.000): Pisang Goreng x2 + Es Teh Manis x2
    (18,  7, 10000, 2, 20000),
    (18,  3,  7000, 2, 14000),

    -- T19 (52.000): Bakso x2 + Kopi Hitam x2
    (19,  6, 18000, 2, 36000),
    (19,  1,  8000, 2, 16000),

    -- T20 (30.000): Jus Alpukat x1 + Roti Bakar x1
    (20,  9, 18000, 1, 18000),
    (20,  8, 12000, 1, 12000),

    -- T21 (55.000): Nasi Goreng x1 + Mie Goreng x1 + Air Mineral x2
    (21,  5, 25000, 1, 25000),
    (21,  4, 20000, 1, 20000),
    (21, 10,  5000, 2, 10000),

    -- T22 (45.000): Kopi Susu x3
    (22,  2, 15000, 3, 45000),

    -- T23 (44.000): Es Teh Manis x4 + Kopi Hitam x2
    (23,  3,  7000, 4, 28000),
    (23,  1,  8000, 2, 16000),

    -- T24 (43.000): Bakso x1 + Nasi Goreng x1
    (24,  6, 18000, 1, 18000),
    (24,  5, 25000, 1, 25000),

    -- T25 (51.000): Jus Alpukat x2 + Kopi Susu x1
    (25,  9, 18000, 2, 36000),
    (25,  2, 15000, 1, 15000),

    -- T26 (55.000): Mie Goreng x2 + Air Mineral x3
    (26,  4, 20000, 2, 40000),
    (26, 10,  5000, 3, 15000),

    -- T27 (46.000): Kopi Hitam x4 + Es Teh Manis x2
    (27,  1,  8000, 4, 32000),
    (27,  3,  7000, 2, 14000),

    -- T28 (68.000): Nasi Goreng x2 + Bakso x1
    (28,  5, 25000, 2, 50000),
    (28,  6, 18000, 1, 18000),

    -- T29 (58.000): Nasi Goreng x1 + Jus Alpukat x1 + Kopi Susu x1
    (29,  5, 25000, 1, 25000),
    (29,  9, 18000, 1, 18000),
    (29,  2, 15000, 1, 15000),

    -- T30 (51.000): Es Teh Manis x3 + Mie Goreng x1 + Air Mineral x2
    (30,  3,  7000, 3, 21000),
    (30,  4, 20000, 1, 20000),
    (30, 10,  5000, 2, 10000),

    -- T31 (31.000): Kopi Hitam x2 + Kopi Susu x1  [hari ini]
    (31,  1,  8000, 2, 16000),
    (31,  2, 15000, 1, 15000),

    -- T32 (39.000): Nasi Goreng x1 + Es Teh Manis x2  [hari ini, paid]
    (32,  5, 25000, 1, 25000),
    (32,  3,  7000, 2, 14000),

    -- T33 (25.000): Kopi Susu x1 + Air Mineral x2  [hari ini, waiting]
    (33,  2, 15000, 1, 15000),
    (33, 10,  5000, 2, 10000),

    -- T34 (47.000): Bakso x1 + Nasi Goreng x1  [hari ini, waiting]
    (34,  6, 18000, 1, 18000),
    (34,  5, 25000, 1, 25000),
    (34,  3,  7000, 2, 14000);

-- =============================================================
--  VERIFIKASI (jalankan query ini untuk memastikan seed berhasil)
-- =============================================================
-- SELECT 'products'     AS tabel, COUNT(*) AS jumlah FROM products
-- UNION ALL
-- SELECT 'transactions'      , COUNT(*)             FROM transactions
-- UNION ALL
-- SELECT 'transaction_items'  , COUNT(*)             FROM transaction_items;
--
-- Expected:
--   products          → 10
--   transactions      → 34
--   transaction_items → 74
--
-- Preview laporan produk terlaris dari data seed:
-- SELECT p.name, SUM(ti.quantity) AS total_terjual
-- FROM transaction_items ti JOIN products p ON p.id = ti.product_id
-- GROUP BY ti.product_id, p.name
-- ORDER BY total_terjual DESC
-- LIMIT 5;
--
-- Preview ringkasan hari ini (T31-T34, status = completed/paid/waiting):
-- SELECT status, COUNT(*) AS jumlah, SUM(total) AS total_omzet
-- FROM transactions WHERE DATE(date) = CURDATE()
-- GROUP BY status;

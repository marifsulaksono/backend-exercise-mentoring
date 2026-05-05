-- =============================================================
--  CLI POS — Module 2 DDL
--  Jalankan dengan: mysql -u root -p < schema.sql
--  Aman dijalankan berulang kali (IF NOT EXISTS).
-- =============================================================

CREATE DATABASE IF NOT EXISTS pos_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pos_db;

-- -------------------------------------------------------------
--  PRODUCTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id    INT          NOT NULL AUTO_INCREMENT,
    name  VARCHAR(100) NOT NULL,
    price INT          NOT NULL,
    stock INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
);

-- -------------------------------------------------------------
--  CUSTOMERS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    id      INT          NOT NULL AUTO_INCREMENT,
    name    VARCHAR(100) NOT NULL,
    phone   VARCHAR(20)  NOT NULL,
    address VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

-- -------------------------------------------------------------
--  TRANSACTIONS
--  customer_id nullable: transaksi walk-in tidak wajib punya
--  customer terdaftar.
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transactions (
    id            INT       NOT NULL AUTO_INCREMENT,
    customer_id   INT           NULL DEFAULT NULL,
    total         INT       NOT NULL,
    paid_amount   INT       NOT NULL,
    change_amount INT       NOT NULL,
    date          DATETIME  NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'waiting', -- enum('waiting','paid','completed)
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_tr_customer FOREIGN KEY (customer_id)
        REFERENCES customers (id)
);

-- -------------------------------------------------------------
--  TRANSACTION ITEMS
--  product_name & price disimpan langsung (denormalisasi) agar
--  riwayat struk tetap akurat walau produk diubah/dihapus.
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transaction_items (
    id             INT NOT NULL AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    product_id     INT NOT NULL,
    price          INT NOT NULL,
    quantity       INT NOT NULL,
    subtotal       INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ti_transaction FOREIGN KEY (transaction_id)
        REFERENCES transactions (id),
    CONSTRAINT fk_ti_product FOREIGN KEY (product_id)
        REFERENCES products (id)
);

-- -------------------------------------------------------------
--  INDEXES
-- -------------------------------------------------------------
CREATE INDEX idx_tr_customer_id ON transactions (customer_id);
CREATE INDEX idx_ti_transaction_id ON transaction_items (transaction_id);
CREATE INDEX idx_ti_product_id ON transaction_items (product_id);
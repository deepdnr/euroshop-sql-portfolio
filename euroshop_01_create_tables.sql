-- =============================================
-- Zalando Practice Database
-- File 01: Create all tables
-- =============================================
-- Run this file first, before inserting any data.
-- Tables must be created in this exact order
-- because each table references the one above it.
-- =============================================

-- Categories first — products will reference this table
CREATE TABLE IF NOT EXISTS categories (
    category_id     INT          PRIMARY KEY,
    category_name   VARCHAR(50)  NOT NULL,
    parent_category VARCHAR(50)
);

-- Products second — references categories
CREATE TABLE IF NOT EXISTS products (
    product_id    INT           PRIMARY KEY,
    category_id   INT           REFERENCES categories(category_id),
    product_name  VARCHAR(100)  NOT NULL,
    brand         VARCHAR(50),
    price         DECIMAL(10,2) NOT NULL,
    stock_qty     INT,
    gender        VARCHAR(10)
);

-- Customers third — orders will reference this table
CREATE TABLE IF NOT EXISTS customers (
    customer_id   INT          PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    city          VARCHAR(50),
    country       CHAR(2),
    registered_at DATE
);

-- Orders fourth — references customers
CREATE TABLE IF NOT EXISTS orders (
    order_id       INT           PRIMARY KEY,
    customer_id    INT           REFERENCES customers(customer_id),
    order_date     DATE          NOT NULL,
    status         VARCHAR(20),
    total_amount   DECIMAL(10,2),
    payment_method VARCHAR(20)
);

-- Order items last — references both orders AND products
-- This is the junction table for the many-to-many
-- relationship between orders and products
CREATE TABLE IF NOT EXISTS order_items (
    item_id     INT           PRIMARY KEY,
    order_id    INT           REFERENCES orders(order_id),
    product_id  INT           REFERENCES products(product_id),
    quantity    INT           NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    size        VARCHAR(10)
);

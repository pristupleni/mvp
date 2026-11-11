-- ==============================================================================
-- DATABASE SCHEMA: PostgreSQL / Supabase
-- Target Market: Sewing Workshops & Textile Wholesalers (Dordoi / Madina, Bishkek)
-- ==============================================================================

-- 1. ENUM TYPES
CREATE TYPE user_role AS ENUM ('workshop', 'wholesaler');
CREATE TYPE stock_unit AS ENUM ('meters', 'rolls', 'pieces', 'kg');
CREATE TYPE transaction_type AS ENUM ('in', 'out');
CREATE TYPE debt_type AS ENUM ('receivable', 'payable');
CREATE TYPE order_status AS ENUM ('draft', 'sent', 'confirmed', 'completed');

-- 2. USERS TABLE (Профили пользователей)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'workshop',
    market_location VARCHAR(150), -- e.g. "Дордой, Проход 15, Контейнер 1042"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. WAREHOUSES TABLE (Склады)
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- e.g. "Основной склад цеха #1"
    address VARCHAR(200),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. PRODUCTS TABLE (Сырье и материалы)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL, -- e.g. "Ткань Бифлекс Черный"
    category VARCHAR(50) NOT NULL, -- "Ткани", "Нитки", "Фурнитура"
    unit stock_unit NOT NULL DEFAULT 'meters',
    current_stock NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    min_threshold NUMERIC(12, 2) NOT NULL DEFAULT 10.00, -- Минимальный порог безопасности
    daily_burn_rate NUMERIC(12, 2) NOT NULL DEFAULT 1.00, -- Средний расход в день
    price_kgs NUMERIC(12, 2) NOT NULL DEFAULT 0.00, -- Цена в сомах (KGS)
    default_supplier_name VARCHAR(100),
    default_supplier_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. STOCK TRANSACTIONS TABLE (История приходов и списаний)
CREATE TABLE stock_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type transaction_type NOT NULL, -- 'in' (+) или 'out' (-)
    quantity NUMERIC(12, 2) NOT NULL,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. DEBTS TABLE (Долги и Взаиморасчеты в KGS)
CREATE TABLE debts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    counterparty_name VARCHAR(100) NOT NULL, -- ФИО / Цех / Контейнер
    counterparty_phone VARCHAR(20) NOT NULL,
    type debt_type NOT NULL, -- 'receivable' (мне должны) или 'payable' (я должен)
    amount_kgs NUMERIC(12, 2) NOT NULL, -- Сумма в сомах
    due_date DATE NOT NULL, -- Дата обещанного платежа
    note TEXT,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. PURCHASE ORDERS TABLE (Заявки на авто-закупку на Дордой/Мадину)
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_phone VARCHAR(20) NOT NULL,
    status order_status NOT NULL DEFAULT 'draft',
    total_amount_kgs NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    items_json JSONB NOT NULL, -- Детализация позиций заявки
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- INDEXES FOR PERFORMANCE
CREATE INDEX idx_products_warehouse ON products(warehouse_id);
CREATE INDEX idx_transactions_product ON stock_transactions(product_id);
CREATE INDEX idx_debts_user_type ON debts(user_id, type, is_paid);

-- ROW LEVEL SECURITY (RLS) FOR SUPABASE
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can read own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "User can access own debts" ON debts FOR ALL USING (auth.uid() = user_id);

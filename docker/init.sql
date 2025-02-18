DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status') THEN
        CREATE TYPE status AS ENUM ('pending', 'accepted', 'rejected', 'resolved');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    contact VARCHAR(255) NOT NULL,
    status status DEFAULT 'pending',
    last_updated_by VARCHAR(255) NOT NULL DEFAULT 'system',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
   RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_tickets_updated_at 
BEFORE UPDATE ON tickets
FOR EACH ROW 
EXECUTE PROCEDURE update_updated_at_column();

-- Insert sample data
INSERT INTO tickets (title, description, contact) VALUES
('ระบบล็อกอินมีปัญหา', 'ไม่สามารถล็อกอินเข้าสู่ระบบได้ รบกวนช่วยตรวจสอบ', 'somchai@example.com'),
('ฟีเจอร์ค้นหาไม่ทำงาน', 'ค้นหาสินค้าแล้วไม่พบผลลัพธ์ที่ควรจะมี', 'somchai@example.com'),
('ข้อผิดพลาดในการชำระเงิน', 'ชำระเงินผ่านบัตรเครดิตไม่ได้', 'chokchai@example.com'),
('หน้าโปรไฟล์โหลดช้า', 'โหลดข้อมูลโปรไฟล์ช้ามากกว่า 10 วินาที', 'kamol@example.com');

COMMIT;

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'role') THEN
        CREATE TYPE role AS ENUM ('admin', 'user');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    email VARCHAR(255)  NOT NULL UNIQUE,
    role role DEFAULT 'user'
);

-- Insert user data
INSERT INTO users (firstname, lastname, email, role) VALUES 
('สมชัย', 'ใจดี', 'somchai@example.com', 'admin'),
('โชคชัย', 'มีโชค', 'chokchai@example.com', 'user'),
('กมล', 'สุขสันต์', 'kamol@example.com', 'user')
;

COMMIT;
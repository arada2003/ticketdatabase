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

-- สร้างตารางเก็บประวัติของตั๋ว
CREATE TABLE IF NOT EXISTS tickets_history (
    id SERIAL PRIMARY KEY,
    ticket_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    contact VARCHAR(255) NOT NULL,
    status status NOT NULL,
    last_updated_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- สร้างฟังก์ชันเมื่อมีการอัปเดตข้อมูลในตาราง Tickets
CREATE OR REPLACE FUNCTION log_ticket_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO tickets_history (ticket_id, title, description, contact, status, last_updated_by, created_at, updated_at)
    VALUES (OLD.id, OLD.title, OLD.description, OLD.contact, OLD.status, OLD.last_updated_by, OLD.created_at, OLD.updated_at);
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- สร้าง Trigger เรียกใช้ฟังก์ชันเมื่อมีการเปลี่ยนแปลงข้อมูลในตาราง Tickets
CREATE TRIGGER log_tickets_changes
AFTER UPDATE ON tickets
FOR EACH ROW
EXECUTE PROCEDURE log_ticket_changes();

-- Insert ข้อมูลของตั๋วสนัสนุน
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

-- สร้างตารางผู้ใช้
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    email VARCHAR(255)  NOT NULL UNIQUE,
    role role DEFAULT 'user'
);

-- Insert ข้อมูลของผู้ใช้
INSERT INTO users (firstname, lastname, email, role) VALUES 
('สมชัย', 'ใจดี', 'somchai@example.com', 'admin'),
('โชคชัย', 'มีโชค', 'chokchai@example.com', 'user'),
('กมล', 'สุขสันต์', 'kamol@example.com', 'user')
;

COMMIT;
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status') THEN
        CREATE TYPE status AS ENUM ('panding', 'accept', 'reject', 'resolved');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    contact VARCHAR(255) NOT NULL,
    status status DEFAULT 'panding',
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
INSERT INTO tickets (title, description, contact, status) VALUES
('ระบบล็อกอินมีปัญหา', 'ไม่สามารถล็อกอินเข้าสู่ระบบได้ รบกวนช่วยตรวจสอบ', 'user1@example.com', 'panding'),
('ฟีเจอร์ค้นหาไม่ทำงาน', 'ค้นหาสินค้าแล้วไม่พบผลลัพธ์ที่ควรจะมี', 'user2@example.com', 'accept'),
('ข้อผิดพลาดในการชำระเงิน', 'ชำระเงินผ่านบัตรเครดิตไม่ได้', 'user3@example.com', 'reject'),
('หน้าโปรไฟล์โหลดช้า', 'โหลดข้อมูลโปรไฟล์ช้ามากกว่า 10 วินาที', 'user4@example.com', 'resolved');

COMMIT;

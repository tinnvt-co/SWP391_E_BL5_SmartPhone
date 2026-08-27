-- =====================================================
-- Cleanup: Xóa COMPLAINT permissions và data liên quan
-- =====================================================
-- Chạy sau khi đã deploy code mới (đã xóa complaint flow)

-- 1. Xóa Role_Permission entries cho COMPLAINT
DELETE FROM Role_Permission WHERE PermissionID IN (
    SELECT ID FROM Permission WHERE Name LIKE 'COMPLAINT%'
);

-- 2. Xóa Permission entries
DELETE FROM Permission WHERE Name LIKE 'COMPLAINT%';

-- 3. (Tùy chọn) Xóa bảng Complaint + ComplaintMessage
-- Uncomment dòng dưới nếu muốn xóa hẳn data complaint
-- DROP TABLE IF EXISTS ComplaintMessage;
-- DROP TABLE IF EXISTS Complaint;

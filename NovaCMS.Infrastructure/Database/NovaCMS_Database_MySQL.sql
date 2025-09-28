DROP DATABASE IF EXISTS NovaCMS;
CREATE DATABASE NovaCMS;
USE NovaCMS;
-- Database schema for NovaCMS - Equipment Rental and Sales Management System
-- READ this before using: version 1.0.0
-- This script only for MySQL/MariaDB in local development and testing purpose.


CREATE TABLE `Roles` (
  `RoleId` INT PRIMARY KEY AUTO_INCREMENT,
  `RoleName` VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE `Users` (
  `UserId` INT PRIMARY KEY AUTO_INCREMENT,
  `FullName` VARCHAR(255) NOT NULL,
  `Email` VARCHAR(255) UNIQUE,
  `PasswordHash` VARCHAR(255),
  `PhoneNumber` VARCHAR(20) UNIQUE,
  `LoyaltyPoints` INT NOT NULL DEFAULT 0,
  `GoogleId` VARCHAR(255) UNIQUE,
  `AvatarUrl` TEXT,
  `Address` VARCHAR(255),
  `CreatedAt` DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `UpdatedAt` DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP) ON UPDATE CURRENT_TIMESTAMP,
  `Status` ENUM ('Active', 'Inactive') DEFAULT 'Active',
  `RoleId` INT DEFAULT 1
);

CREATE TABLE `BlogPosts` (
  `PostId` INT PRIMARY KEY AUTO_INCREMENT,
  `Title` VARCHAR(255) NOT NULL,
  `Content` TEXT NOT NULL,
  `AuthorId` INT NOT NULL,
  `Location` VARCHAR(255),
  `PricePerDay` DECIMAL(10,2) NOT NULL,
  `CreatedAt` DATETIME DEFAULT (CURRENT_TIMESTAMP),
  `UpdatedAt` DATETIME DEFAULT (CURRENT_TIMESTAMP) ON UPDATE CURRENT_TIMESTAMP,
  `Status` ENUM('Draft', 'Published', 'Archived') DEFAULT 'Draft'
);

CREATE TABLE `BlogPostImages` (
  `ImageId` INT PRIMARY KEY AUTO_INCREMENT,
  `PostId` INT NOT NULL,
  `ImageUrl` VARCHAR(500) NOT NULL,
  `IsPrimary` BOOLEAN DEFAULT false,
  `SortOrder` INT DEFAULT 0
);

CREATE TABLE `Categories` (
  `CategoryId` INT PRIMARY KEY AUTO_INCREMENT,
  `CategoryName` VARCHAR(100) UNIQUE NOT NULL,
  `Description` TEXT
);

CREATE TABLE `Equipments` (
  `EquipmentId` INT PRIMARY KEY AUTO_INCREMENT,
  `CategoryId` INT,
  `Name` VARCHAR(255) NOT NULL,
  `Brand` VARCHAR(100),
  `Description` TEXT,
  `ConditionNote` VARCHAR(255),
  `PricePerDay` DECIMAL(10,2) NOT NULL,
  `DepositFee` DECIMAL(10,2) DEFAULT 0,
  `Status` ENUM ('Active', 'Inactive') DEFAULT 'Active',
  `Stock` INT DEFAULT 1
 -- `MainImageUrl` VARCHAR(500)
);

CREATE TABLE `EquipmentItems` (
  `ItemId` INT PRIMARY KEY AUTO_INCREMENT,
  `EquipmentId` INT NOT NULL,
  `SerialNumber` VARCHAR(100) UNIQUE NOT NULL,
  `ConditionNote` VARCHAR(255),
  `Status` ENUM('Available','Held','Rented','Maintenance','Lost') DEFAULT 'Available',
  FOREIGN KEY (`EquipmentId`) REFERENCES `Equipments` (`EquipmentId`)
);

CREATE TABLE `EquipmentImages` (
  `ImageId` INT PRIMARY KEY AUTO_INCREMENT,
  `EquipmentId` INT NOT NULL,
  `ImageUrl` VARCHAR(500) NOT NULL,
  `IsPrimary` BOOLEAN DEFAULT false,
  `SortOrder` INT DEFAULT 0 -- để phân biệt thứ tự hiển thị ảnh
);

CREATE TABLE `RentalOrders` (
  `OrderId` INT PRIMARY KEY AUTO_INCREMENT,
  `UserId` INT NOT NULL,
  `OrderDate` DATETIME DEFAULT (CURRENT_TIMESTAMP),
  `ReferenceNo` VARCHAR(100),
  `Note` VARCHAR(500),
  `TotalAmount` DECIMAL(10,2) NOT NULL, -- là số tiền tạm tính khi khách thuê, chưa bao gồm phí phát sinh (nếu có)
  `Status` ENUM ('Pending', 'Confirmed','Rented', 'Cancelled', 'Completed') DEFAULT 'Pending'
);

CREATE TABLE `RentalOrderDetails` (
  `OrderDetailId` INT PRIMARY KEY AUTO_INCREMENT,
  `OrderId` INT NOT NULL,
  `EquipmentId` INT NOT NULL,
  `EquipmentItemId` INT ,	-- Khi khách đặt cọc giữ máy thì chưa có ItemId, chỉ khi nào nhân viên giao máy mới gán ItemId vào
  `RentalStartDate` DATETIME NOT NULL,
  `RentalEndDate` DATETIME NOT NULL,
  `OverdueFee` DECIMAL(10,2) DEFAULT 0,
  `OverdueDays` INT DEFAULT 0, -- số ngày quá hạn (nếu có)
  `ReturnDate` DATETIME, -- take away date - ngày trả máy
  `PricePerDay` DECIMAL(10,2) NOT NULL,
  `DepositFee` DECIMAL(10,2) DEFAULT 0 -- phí đặt cọc (nếu có)
   --`Quantity` INT NOT NULL,
   --vì quản lý theo từng item nên bỏ quantity
);

-- Bảng hóa đơn chi đc tạo 1 lần duy nhất sau khi khách hàng trả máy và hoàn tất  các thanh toán
CREATE TABLE `Invoices` (
  `InvoiceId` INT PRIMARY KEY AUTO_INCREMENT,
  `OrderId` INT NOT NULL,
  `InvoiceDate` DATETIME DEFAULT (CURRENT_TIMESTAMP),
  `Amount` DECIMAL(10,2) NOT NULL, -- số tiền cuối cùng khách phải thanh toán, bao gồm phí phát sinh (nếu có)
  `CreatedByStaffId` INT,
  `DueDate` DATETIME,
  `PaymentMethod` ENUM ('Cash', 'BankTransfer', 'Momo', 'ZaloPay') DEFAULT 'Cash',
  `PaymentStatus` ENUM ('Unpaid', 'Paid', 'Refunded') DEFAULT 'Unpaid',
  --`TransactionCode` VARCHAR(100)
);

ALTER TABLE `Users` ADD FOREIGN KEY (`RoleId`) REFERENCES `Roles` (`RoleId`);

ALTER TABLE `BlogPosts` ADD FOREIGN KEY (`AuthorId`) REFERENCES `Users` (`UserId`);

ALTER TABLE `BlogPostImages` ADD FOREIGN KEY (`PostId`) REFERENCES `BlogPosts` (`PostId`);

ALTER TABLE `Equipments` ADD FOREIGN KEY (`CategoryId`) REFERENCES `Categories` (`CategoryId`);

ALTER TABLE `EquipmentImages` ADD FOREIGN KEY (`EquipmentId`) REFERENCES `Equipments` (`EquipmentId`);

ALTER TABLE `RentalOrders` ADD FOREIGN KEY (`UserId`) REFERENCES `Users` (`UserId`);

ALTER TABLE `RentalOrderDetails` ADD FOREIGN KEY (`OrderId`) REFERENCES `RentalOrders` (`OrderId`);

ALTER TABLE `RentalOrderDetails` ADD FOREIGN KEY (`EquipmentItemId`) REFERENCES `EquipmentItems` (`ItemId`);

ALTER TABLE `RentalOrderDetails` ADD FOREIGN KEY (`EquipmentId`) REFERENCES `Equipments` (`EquipmentId`);

ALTER TABLE `Invoices` ADD FOREIGN KEY (`OrderId`) REFERENCES `RentalOrders` (`OrderId`);

ALTER TABLE `Invoices` ADD FOREIGN KEY (`CreatedByStaffId`) REFERENCES `Users`(`UserId`);

-- INSERT
-- Roles
INSERT INTO Roles (RoleName) VALUES 
('Admin'), 
('Staff'), 
('Customer');

-- Users
INSERT INTO Users (FullName, Email, PasswordHash, PhoneNumber, RoleId) VALUES
('Nguyen Van A', 'a@example.com', 'hashpass1', '0901234567', 3), -- Customer
('Tran Thi B', 'b@example.com', 'hashpass2', '0912345678', 2), -- Staff
('Admin User', 'admin@example.com', 'hashpass3', '0987654321', 1); -- Admin

-- Categories
INSERT INTO Categories (CategoryName, Description) VALUES
('Camera', 'Máy ảnh và phụ kiện'),
('Lens', 'Ống kính'),
('Tripod', 'Chân máy');

-- Equipments (loại thiết bị)
INSERT INTO Equipments (CategoryId, Name, Brand, Description, PricePerDay, DepositFee, Stock) VALUES
(1, 'Canon EOS R6', 'Canon', 'Full-frame mirrorless camera', 500000, 5000000, 2),
(2, 'Sony FE 24-70mm f/2.8 GM', 'Sony', 'Lens zoom cao cấp', 300000, 3000000, 1),
(3, 'Manfrotto Tripod 190X', 'Manfrotto', 'Chân máy ảnh cao cấp', 100000, 500000, 3);

-- EquipmentItems (máy cụ thể, theo serial)
INSERT INTO EquipmentItems (EquipmentId, SerialNumber, ConditionNote, Status) VALUES
(1, 'CANON-R6-001', 'Máy mới 99%', 'Available'),
(1, 'CANON-R6-002', 'Máy có trầy nhẹ', 'Available'),
(2, 'SONY-LENS-001', 'Ống kính mới', 'Available'),
(3, 'TRIPOD-001', 'Chân máy còn tốt', 'Available'),
(3, 'TRIPOD-002', 'Chân máy hơi cũ', 'Available'),
(3, 'TRIPOD-003', 'Chân máy còn tốt', 'Maintenance');

-- EquipmentImages
INSERT INTO EquipmentImages (EquipmentId, ImageUrl, IsPrimary, SortOrder) VALUES
(1, 'canon_r6_front.jpg', true, 1),
(1, 'canon_r6_back.jpg', false, 2),
(2, 'sony_24_70.jpg', true, 1),
(3, 'tripod_190x.jpg', true, 1);

-- RentalOrders (khách đặt thuê)
INSERT INTO RentalOrders (UserId, ReferenceNo, Note, TotalAmount, Status) VALUES
(1, 'ORD-2025-0001', 'Thuê Canon R6 trong 3 ngày', 1500000, 'Pending'),
(1, 'ORD-2025-0002', 'Thuê Tripod 2 ngày', 200000, 'Confirmed');

-- RentalOrderDetails (chi tiết thuê)
INSERT INTO RentalOrderDetails 
(OrderId, EquipmentId, EquipmentItemId, RentalStartDate, RentalEndDate, PricePerDay, DepositFee) VALUES
(1, 1, NULL, '2025-09-13', '2025-09-15', 500000, 5000000), -- Canon R6, chưa gán ItemId (chờ giao máy)
(2, 3, 4, '2025-09-10', '2025-09-11', 100000, 500000); -- Tripod, đã gán Item cụ thể

-- Invoices (chỉ tạo khi khách trả máy xong)
INSERT INTO Invoices (OrderId, Amount, CreatedByStaffId, PaymentMethod, PaymentStatus) VALUES
(2, 200000, 2, 'Cash', 'Paid');

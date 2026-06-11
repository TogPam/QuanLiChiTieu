CREATE DATABASE ManageMoneyDB
GO

USE ManageMoneyDB
GO

DROP DATABASE ManageMoney


-- 1. BẢNG NGƯỜI DÙNG (Users Table)
CREATE TABLE Users (
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL, 
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 2. BẢNG DANH MỤC (Categories Table)
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL, 
    CategoryType BIT NOT NULL, -- 1: Income (Thu), 0: Expense (Chi)
    IconUrl VARCHAR(255) NULL
);

-- 3. BẢNG HŨ CHI TIÊU (Jars / Money Jars Table)
CREATE TABLE Jars (
    JarId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    JarName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    Budget DECIMAL(18, 2) DEFAULT 0, 
    JarType TINYINT DEFAULT 1, -- 1: Personal, 2: Shared/Group
    CreatedByUserId UNIQUEIDENTIFIER NOT NULL, 
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Jars_Users FOREIGN KEY (CreatedByUserId) REFERENCES Users(UserId)
);

-- 4. BẢNG THÀNH VIÊN HŨ (Jar Members Table - Quan hệ N-N)
CREATE TABLE JarMembers (
    JarId UNIQUEIDENTIFIER NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL,
    Role VARCHAR(20) DEFAULT 'Member', -- 'Owner', 'Co-owner', 'Member'
    JoinedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (JarId, UserId),
    CONSTRAINT FK_JarMembers_Jars FOREIGN KEY (JarId) REFERENCES Jars(JarId),
    CONSTRAINT FK_JarMembers_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- 5. BẢNG GIAO DỊCH (Transactions Table)
CREATE TABLE Transactions (
    TransactionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    JarId UNIQUEIDENTIFIER NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL, -- Ai là người quẹt camera / tạo giao dịch
    CategoryId INT NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL,
    Description NVARCHAR(500) NULL,
    ReceiptImageUrl VARCHAR(500) NULL, -- QUAN TRỌNG: Lưu link ảnh chụp hóa đơn
    TransactionType BIT NOT NULL, -- 1: Income, 0: Expense
    TransactionDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Transactions_Jars FOREIGN KEY (JarId) REFERENCES Jars(JarId),
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);

SELECT * FROM Users
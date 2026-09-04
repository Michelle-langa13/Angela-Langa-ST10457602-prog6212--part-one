CREATE DATABASE RaceDayDB

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO


-- ============================================================
-- 2. USE DATABASE
-- ============================================================

USE RaceDayDB;
GO


-- ============================================================
-- 3. DROP EXISTING TABLES
-- Drop child tables before parent tables because of FKs
-- ============================================================

IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL
    DROP TABLE dbo.Results;

IF OBJECT_ID('dbo.Participate', 'U') IS NOT NULL
    DROP TABLE dbo.Participate;

IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL
    DROP TABLE dbo.Events;

IF OBJECT_ID('dbo.Admin', 'U') IS NOT NULL
    DROP TABLE dbo.Admin;

IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL
    DROP TABLE dbo.Categories;

IF OBJECT_ID('dbo.Venues', 'U') IS NOT NULL
    DROP TABLE dbo.Venues;

IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL
    DROP TABLE dbo.Roles;
GO


-- ============================================================
-- 4. CREATE ROLES TABLE
-- ============================================================

CREATE TABLE dbo.Roles
(
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);
GO


-- ============================================================
-- 5. CREATE VENUES TABLE
-- ============================================================

CREATE TABLE dbo.Venues
(
    venue_id INT IDENTITY(1,1) PRIMARY KEY,
    venue_name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,

    CONSTRAINT CK_Venues_Capacity
        CHECK (capacity > 0)
);
GO


-- ============================================================
-- 6. CREATE CATEGORIES TABLE
-- ============================================================

CREATE TABLE dbo.Categories
(
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    age_group VARCHAR(30) NOT NULL,
    distance DECIMAL(5,2) NOT NULL,

    CONSTRAINT CK_Categories_Distance
        CHECK (distance > 0)
);
GO


-- ============================================================
-- 7. CREATE ADMIN TABLE
-- ============================================================

CREATE TABLE dbo.Admin
(
    admin_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,

    CONSTRAINT FK_Admin_Role
        FOREIGN KEY (role_id)
        REFERENCES dbo.Roles(role_id)
);
GO


-- ============================================================
-- 8. CREATE EVENTS TABLE
-- ============================================================

CREATE TABLE dbo.Events
(
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATETIME NOT NULL,
    description VARCHAR(255) NULL,
    venue_id INT NOT NULL,
    category_id INT NOT NULL,

    CONSTRAINT FK_Events_Venue
        FOREIGN KEY (venue_id)
        REFERENCES dbo.Venues(venue_id),

    CONSTRAINT FK_Events_Category
        FOREIGN KEY (category_id)
        REFERENCES dbo.Categories(category_id)
);
GO


-- ============================================================
-- 9. CREATE PARTICIPATE TABLE
-- ============================================================

CREATE TABLE dbo.Participate
(
    participate_id INT IDENTITY(1,1) PRIMARY KEY,
    participant_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    event_id INT NOT NULL,

    registration_date DATETIME NOT NULL
        CONSTRAINT DF_Participate_RegistrationDate
        DEFAULT GETDATE(),

    status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Participate_Status
        DEFAULT 'Registered',

    CONSTRAINT CK_Participate_Status
        CHECK (status IN
        ('Registered', 'Confirmed', 'Cancelled', 'Completed')),

    CONSTRAINT FK_Participate_Event
        FOREIGN KEY (event_id)
        REFERENCES dbo.Events(event_id)
);
GO


-- ============================================================
-- 10. CREATE RESULTS TABLE
-- ============================================================

CREATE TABLE dbo.Results
(
    results_id INT IDENTITY(1,1) PRIMARY KEY,
    participate_id INT NOT NULL UNIQUE,
    finish_time TIME NOT NULL,
    position INT NOT NULL,
    points_earned INT NOT NULL
        CONSTRAINT DF_Results_Points
        DEFAULT 0,

    CONSTRAINT CK_Results_Position
        CHECK (position > 0),

    CONSTRAINT FK_Results_Participate
        FOREIGN KEY (participate_id)
        REFERENCES dbo.Participate(participate_id)
        ON DELETE CASCADE
);
GO


-- ============================================================
-- 11. INSERT DATA INTO ROLES
-- ============================================================

INSERT INTO dbo.Roles (role_name)
VALUES
('Organiser'),
('Official');
GO


-- ============================================================
-- 12. DISPLAY ROLES DATA
-- ============================================================

SELECT *
FROM dbo.Roles;
GO


-- ============================================================
-- 13. INSERT DATA INTO VENUES
-- ============================================================

INSERT INTO dbo.Venues
    (venue_name, address, city, capacity)
VALUES
    ('Loftus Versfeld Stadium',
     'Kirkness Street, Arcadia',
     'Pretoria',
     50000),

    ('Wanderers Stadium',
     'Corlett Drive, Illovo',
     'Johannesburg',
     30000);
GO


-- ============================================================
-- 14. DISPLAY VENUES DATA
-- ============================================================

SELECT *
FROM dbo.Venues;
GO


-- ============================================================
-- 15. INSERT DATA INTO CATEGORIES
-- ============================================================

INSERT INTO dbo.Categories
    (category_name, age_group, distance)
VALUES
    ('5KM Sprint', 'Open', 5.00),

    ('10KM Challenge', 'U23', 10.00),

    ('21KM Half Marathon', 'Senior', 21.10);
GO


-- ============================================================
-- 16. DISPLAY CATEGORIES DATA
-- ============================================================

SELECT *
FROM dbo.Categories;
GO


-- ============================================================
-- 17. INSERT DATA INTO ADMIN
-- ============================================================

INSERT INTO dbo.Admin
    (first_name, last_name, email, password_hash, role_id)
VALUES
    ('Thabo',
     'Mbeki',
     'thabo.organiser@raceday.co.za',
     'hashed_pwd_123',
     1),

    ('Lerato',
     'Dlamini',
     'lerato.organiser@raceday.co.za',
     'hashed_pwd_456',
     1);
GO


-- ============================================================
-- 18. DISPLAY ADMIN DATA
-- ============================================================

SELECT *
FROM dbo.Admin;
GO


-- ============================================================
-- 19. INSERT DATA INTO EVENTS
-- ============================================================

INSERT INTO dbo.Events
    (event_name, event_date, description, venue_id, category_id)
VALUES
    ('Pretoria Morning Sprint',
     '2026-09-20 07:00:00',
     'Fast 5KM morning sprint',
     1,
     1),

    ('Jozi Family Fun Run',
     '2026-09-21 08:00:00',
     '10KM fun run for U23',
     2,
     2),

    ('Gauteng Marathon Challenge',
     '2026-09-27 06:00:00',
     '21KM Championship',
     1,
     3);
GO


-- ============================================================
-- 20. DISPLAY EVENTS DATA
-- ============================================================

SELECT *
FROM dbo.Events;
GO


-- ============================================================
-- 21. INSERT DATA INTO PARTICIPATE
-- ============================================================

INSERT INTO dbo.Participate
    (participant_name, email, phone, event_id, status)
VALUES
    ('Sipho Nkosi',
     'sipho.nkosi@gmail.com',
     '0821234567',
     1,
     'Confirmed'),

    ('Aisha Patel',
     'aisha.patel@gmail.com',
     '0839876543',
     1,
     'Confirmed'),

    ('James Smith',
     'james.smith@gmail.com',
     '0714567890',
     2,
     'Registered'),

    ('Nomsa Khumalo',
     'nomsa.k@gmail.com',
     '0791112233',
     3,
     'Confirmed');
GO


-- ============================================================
-- 22. DISPLAY PARTICIPATE DATA
-- ============================================================

SELECT *
FROM dbo.Participate;
GO


-- ============================================================
-- 23. INSERT DATA INTO RESULTS
-- ============================================================

INSERT INTO dbo.Results
    (participate_id, finish_time, position, points_earned)
VALUES
    (1, '00:18:45', 1, 100),

    (2, '00:19:12', 2, 80),

    (4, '01:32:10', 1, 100);
GO


-- ============================================================
-- 24. DISPLAY RESULTS DATA
-- ============================================================

SELECT *
FROM dbo.Results;
GO


-- ============================================================
-- 25. VERIFICATION - COUNT RECORDS
-- ============================================================

SELECT 'Roles' AS Entity, COUNT(*) AS [Count]
FROM dbo.Roles

UNION ALL

SELECT 'Venues', COUNT(*)
FROM dbo.Venues

UNION ALL

SELECT 'Categories', COUNT(*)
FROM dbo.Categories

UNION ALL

SELECT 'Admin (Organisers)', COUNT(*)
FROM dbo.Admin

UNION ALL

SELECT 'Events', COUNT(*)
FROM dbo.Events

UNION ALL

SELECT 'Participate (Enrolments)', COUNT(*)
FROM dbo.Participate

UNION ALL

SELECT 'Results', COUNT(*)
FROM dbo.Results;
GO
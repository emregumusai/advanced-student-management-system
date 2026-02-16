/*******************************************************************************
 * File: 01_CreateTables.sql
 * Purpose: Creates all database tables for Student Management System
 * Amaç: Öğrenci Yönetim Sistemi için tüm veritabanı tablolarını oluşturur
 * 
 * Author / Yazar: Yunus Emre Gümüş, Alperen Aktaş, Mehmet Miraç Özmen
 * Date Created / Oluşturulma Tarihi: February 16, 2026
 * Last Modified / Son Değişiklik: February 16, 2026
 * 
 * Description:
 *   Creates 17 tables for managing students, teachers, courses, grades,
 *   attendance, exams, and related entities. Includes primary keys, foreign 
 *   keys, and basic constraints for data integrity.
 * 
 * Açıklama:
 *   Öğrenciler, öğretmenler, dersler, notlar, devamsızlık, sınavlar ve
 *   ilgili varlıkları yönetmek için 17 tablo oluşturur. Veri bütünlüğü
 *   için birincil anahtarlar, yabancı anahtarlar ve temel kısıtlamalar içerir.
 *
 * Dependencies / Bağımlılıklar: 
 *   - Requires database StudentManagementDB to exist
 *   - StudentManagementDB veritabanının mevcut olması gerekir
 * 
 * Execution / Çalıştırma: 
 *   Run once during initial setup (idempotent - can be re-run safely)
 *   İlk kurulum sırasında bir kez çalıştırın (güvenle yeniden çalıştırılabilir)
 *
 * Tables Created / Oluşturulan Tablolar:
 *   - Departments, Roles, Teachers, Students, Admins
 *   - RolePermissions, Courses, Classes, Days, Timetables
 *   - Attendances, Exams, Grades, Logs
 *   - StudentAttendances, CourseDepartments, CourseTeachers
 ******************************************************************************/

USE StudentManagementDB;
GO

-- ============================================================================
-- DROP EXISTING TABLES (Reverse Order for FK Dependencies)
-- MEVCUT TABLOLARI SİL (Yabancı Anahtar Bağımlılıkları için Ters Sırada)
-- ============================================================================

-- Drop relationship tables first / Önce ilişki tablolarını sil
DROP TABLE IF EXISTS dbo.CourseTeachers;
DROP TABLE IF EXISTS dbo.CourseDepartments;
DROP TABLE IF EXISTS dbo.StudentAttendances;

-- Drop dependent tables / Bağımlı tabloları sil
DROP TABLE IF EXISTS dbo.Logs;
DROP TABLE IF EXISTS dbo.Grades;
DROP TABLE IF EXISTS dbo.Exams;
DROP TABLE IF EXISTS dbo.Attendances;
DROP TABLE IF EXISTS dbo.Timetables;
DROP TABLE IF EXISTS dbo.Days;
DROP TABLE IF EXISTS dbo.Classes;
DROP TABLE IF EXISTS dbo.Courses;
DROP TABLE IF EXISTS dbo.RolePermissions;
DROP TABLE IF EXISTS dbo.Admins;
DROP TABLE IF EXISTS dbo.Students;
DROP TABLE IF EXISTS dbo.Teachers;
DROP TABLE IF EXISTS dbo.Roles;
DROP TABLE IF EXISTS dbo.Departments;
GO

-- ============================================================================
-- CORE ENTITY TABLES / ANA VARLİK TABLOLARI
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: Departments
-- Purpose: Stores academic departments (e.g., Computer Engineering, Mathematics)
-- Tablo: Departments (Bölümler)
-- Amaç: Akademik bölümleri saklar (örn: Bilgisayar Mühendisliği, Matematik)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Departments (
    ID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(255) NOT NULL
);
GO

-- ----------------------------------------------------------------------------
-- Table: Roles
-- Purpose: Defines system roles (Student, Teacher, Admin)
-- Tablo: Roles (Roller)
-- Amaç: Sistem rollerini tanımlar (Öğrenci, Öğretmen, Yönetici)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Roles (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Role NVARCHAR(255) NOT NULL
);
GO

-- ----------------------------------------------------------------------------
-- Table: Teachers
-- Purpose: Stores teacher information with department and role assignments
-- Tablo: Teachers (Öğretmenler)
-- Amaç: Öğretmen bilgilerini bölüm ve rol atamaları ile saklar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Teachers (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(255) NOT NULL,
    Surname NVARCHAR(255) NOT NULL,
    DepartmentID INT NOT NULL,
    RoleID INT NOT NULL,
    CONSTRAINT FK_Teachers_Department FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(ID),
    CONSTRAINT FK_Teachers_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(ID)
);
GO

-- ----------------------------------------------------------------------------
-- Table: Students
-- Purpose: Stores student information including student number, advisor, and department
-- Tablo: Students (Öğrenciler)
-- Amaç: Öğrenci numarası, danışman ve bölüm bilgilerini içeren öğrenci verilerini saklar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Students (
    ID INT PRIMARY KEY IDENTITY(1,1),
    StudentNo NVARCHAR(50) NOT NULL UNIQUE,  -- Unique identifier for each student / Her öğrenci için benzersiz tanımlayıcı
    Name NVARCHAR(255) NOT NULL,
    Surname NVARCHAR(255) NOT NULL,
    DepartmentID INT NOT NULL,
    AdvisorID INT,  -- Optional: References a teacher acting as academic advisor / İsteğe bağlı: Akademik danışman öğretmeni
    RoleID INT NOT NULL,
    CONSTRAINT FK_Students_Department FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(ID),
    CONSTRAINT FK_Students_Advisor FOREIGN KEY (AdvisorID) REFERENCES dbo.Teachers(ID),
    CONSTRAINT FK_Students_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(ID)
);
GO

-- ----------------------------------------------------------------------------
-- Table: Admins
-- Purpose: Stores system administrator accounts
-- Tablo: Admins (Yöneticiler)
-- Amaç: Sistem yöneticisi hesaplarını saklar
-- NOTE: Fixed naming inconsistency - now uses PascalCase Name/Surname
-- NOT: İsimlendirme tutarsızlığı düzeltildi - artık PascalCase Name/Surname kullanıyor
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Admins (
    ID INT PRIMARY KEY IDENTITY(1,1),
    RoleID INT NOT NULL,
    Name NVARCHAR(255) NOT NULL,     -- Fixed: Previously lowercase 'name' / Düzeltildi: Önceden küçük harf 'name'
    Surname NVARCHAR(255) NOT NULL,  -- Fixed: Previously lowercase 'surname' / Düzeltildi: Önceden küçük harf 'surname'
    CONSTRAINT FK_Admins_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(ID)
);
GO

-- ============================================================================
-- SECURITY AND PERMISSIONS / GÜVENLİK VE YETKİLENDİRMELER
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: RolePermissions
-- Purpose: Defines granular CRUD permissions for each role on each table
-- Tablo: RolePermissions (Rol Yetkileri)
-- Amaç: Her rol için her tablo üzerinde ayrıntılı CRUD yetkilerini tanımlar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.RolePermissions (
    ID INT PRIMARY KEY IDENTITY(1,1),
    RoleID INT NOT NULL,
    TableName NVARCHAR(255) NOT NULL,
    CanRead BIT DEFAULT 0,    -- SELECT permission / SELECT yetkisi
    CanWrite BIT DEFAULT 0,   -- INSERT permission / INSERT yetkisi
    CanUpdate BIT DEFAULT 0,  -- UPDATE permission / UPDATE yetkisi
    CanDelete BIT DEFAULT 0,  -- DELETE permission / DELETE yetkisi
    CONSTRAINT FK_RolePermissions_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(ID)
);
GO

-- ============================================================================
-- COURSE MANAGEMENT / DERS YÖNETİMİ
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: Courses
-- Purpose: Stores course catalog with grade level information
-- Tablo: Courses (Dersler)
-- Amaç: Ders kataloğunu sınıf seviyesi bilgisi ile saklar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Courses (
    ID INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(255) NOT NULL,
    GradeLevel INT  -- Academic year/grade the course is offered in / Dersin verildiği akademik yıl/sınıf
);
GO

-- ----------------------------------------------------------------------------
-- Table: Classes
-- Purpose: Stores classroom/section information
-- Tablo: Classes (Sınıflar/Şubeler)
-- Amaç: Sınıf/şube bilgilerini saklar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Classes (
    ID INT PRIMARY KEY IDENTITY(1,1),
    ClassName NVARCHAR(255)  -- e.g., "A Section", "Lab 1" / örn: "A Şubesi", "Lab 1"
);
GO

-- ----------------------------------------------------------------------------
-- Table: Days
-- Purpose: Stores day names for weekly scheduling
-- Tablo: Days (Günler)
-- Amaç: Haftalık programlama için gün isimlerini saklar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Days (
    ID INT PRIMARY KEY IDENTITY(1,1),
    DayName NVARCHAR(255)  -- e.g., "Monday", "Tuesday" / örn: "Pazartesi", "Salı"
);
GO

-- ----------------------------------------------------------------------------
-- Table: Timetables
-- Purpose: Schedules courses to specific classes, days, and time slots
-- Tablo: Timetables (Ders Programları)
-- Amaç: Dersleri belirli sınıflar, günler ve zaman dilimlerine programlar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Timetables (
    ID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    ClassID INT NOT NULL,
    DayID INT NOT NULL,
    StartTime DATETIME NOT NULL,  -- Course start time / Ders başlama saati
    EndTime DATETIME NOT NULL,    -- Course end time / Ders bitiş saati
    CONSTRAINT FK_Timetables_Course FOREIGN KEY (CourseID) REFERENCES dbo.Courses(ID),
    CONSTRAINT FK_Timetables_Class FOREIGN KEY (ClassID) REFERENCES dbo.Classes(ID),
    CONSTRAINT FK_Timetables_Day FOREIGN KEY (DayID) REFERENCES dbo.Days(ID)
);
GO

-- ============================================================================
-- ATTENDANCE AND ASSESSMENT / DEVAMSIZLIK VE DEĞERLENDİRME
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: Attendances
-- Purpose: Records attendance status for each date
-- Tablo: Attendances (Devamsızlık Kayıtları)
-- Amaç: Her tarih için devamsızlık durumunu kaydeder
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Attendances (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL,
    Status NVARCHAR(50) NOT NULL  -- e.g., "Present", "Absent", "Late" / örn: "Katıldı", "Katılmadı", "Geç Kaldı"
);
GO

-- ----------------------------------------------------------------------------
-- Table: Exams
-- Purpose: Defines exams for courses with type and date
-- Tablo: Exams (Sınavlar)
-- Amaç: Dersler için tür ve tarih ile sınavları tanımlar
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Exams (
    ID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    Date DATE NOT NULL,
    ExamType NVARCHAR(50) NOT NULL,  -- e.g., "Midterm", "Final", "Quiz" / örn: "Ara Sınav", "Final", "Quiz"
    CONSTRAINT FK_Exams_Course FOREIGN KEY (CourseID) REFERENCES dbo.Courses(ID)
);
GO

-- ----------------------------------------------------------------------------
-- Table: Grades
-- Purpose: Records student scores for specific exams
-- Tablo: Grades (Notlar)
-- Amaç: Öğrencilerin belirli sınavlar için aldığı notları kaydeder
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Grades (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Score FLOAT NOT NULL,     -- Numeric grade (typically 0-100) / Sayısal not (genellikle 0-100)
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    CONSTRAINT FK_Grades_Student FOREIGN KEY (StudentID) REFERENCES dbo.Students(ID),
    CONSTRAINT FK_Grades_Exam FOREIGN KEY (ExamID) REFERENCES dbo.Exams(ID)
);
GO

-- ============================================================================
-- AUDIT AND LOGGING / DENETİM VE GÜNLÜKLEME
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: Logs
-- Purpose: Audit trail for user actions and system events
-- Tablo: Logs (Günlükler)
-- Amaç: Kullanıcı işlemleri ve sistem olayları için denetim kaydı
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Logs (
    ID INT PRIMARY KEY IDENTITY(1,1),
    UserType NVARCHAR(50),         -- User role type / Kullanıcı rol türü (e.g., "Student", "Teacher", "Admin")
    UserID INT,                     -- Related user ID / İlgili kullanıcı ID'si
    Action NVARCHAR(50) NOT NULL,   -- Action performed / Gerçekleştirilen işlem (e.g., "INSERT", "UPDATE", "DELETE")
    Description NVARCHAR(255),      -- Human-readable description / Okunabilir açıklama
    Timestamp DATETIME DEFAULT GETDATE()  -- Automatic timestamp / Otomatik zaman damgası
);
GO

-- ============================================================================
-- RELATIONSHIP TABLES (Many-to-Many) / İLİŞKİ TABLOLARI (Çoka-Çok)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: StudentAttendances
-- Purpose: Links students to their attendance records (many-to-many)
-- Tablo: StudentAttendances (Öğrenci Devamsızlıkları)
-- Amaç: Öğrencileri devamsızlık kayıtlarına bağlar (çoka-çok)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.StudentAttendances (
    StudentID INT NOT NULL,
    AttendanceID INT NOT NULL,
    PRIMARY KEY (StudentID, AttendanceID),  -- Composite primary key / Bileşik birincil anahtar
    CONSTRAINT FK_StudentAttendances_Student FOREIGN KEY (StudentID) REFERENCES dbo.Students(ID),
    CONSTRAINT FK_StudentAttendances_Attendance FOREIGN KEY (AttendanceID) REFERENCES dbo.Attendances(ID)
);
GO

-- ----------------------------------------------------------------------------
-- Table: CourseDepartments
-- Purpose: Links courses to departments (many-to-many)
-- Tablo: CourseDepartments (Ders Bölümleri)
-- Amaç: Dersleri bölümlere bağlar (çoka-çok)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.CourseDepartments (
    CourseID INT NOT NULL,
    DepartmentID INT NOT NULL,
    PRIMARY KEY (CourseID, DepartmentID),  -- Composite primary key / Bileşik birincil anahtar
    CONSTRAINT FK_CourseDepartments_Course FOREIGN KEY (CourseID) REFERENCES dbo.Courses(ID),
    CONSTRAINT FK_CourseDepartments_Department FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(ID)
);
GO

-- ----------------------------------------------------------------------------
-- Table: CourseTeachers
-- Purpose: Links courses to teachers (many-to-many, a course can have multiple teachers)
-- Tablo: CourseTeachers (Ders Öğretmenleri)
-- Amaç: Dersleri öğretmenlere bağlar (çoka-çok, bir dersin birden fazla öğretmeni olabilir)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.CourseTeachers (
    CourseID INT NOT NULL,
    TeacherID INT NOT NULL,
    PRIMARY KEY (CourseID, TeacherID),  -- Composite primary key / Bileşik birincil anahtar
    CONSTRAINT FK_CourseTeachers_Course FOREIGN KEY (CourseID) REFERENCES dbo.Courses(ID),
    CONSTRAINT FK_CourseTeachers_Teacher FOREIGN KEY (TeacherID) REFERENCES dbo.Teachers(ID)
);
GO

-- ============================================================================
-- TABLE CREATION COMPLETED SUCCESSFULLY
-- TABLO OLUŞTURMA BAŞARIYLA TAMAMLANDI
-- ============================================================================

PRINT 'All tables created successfully.';
PRINT 'Total tables: 17';
GO

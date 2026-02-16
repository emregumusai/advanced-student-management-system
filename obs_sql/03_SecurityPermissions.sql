/*******************************************************************************
 * File: 03_SecurityPermissions.sql
 * Purpose: Creates database roles, logins, users, and assigns permissions
 * Amaç: Veritabanı rolleri, oturum açma bilgileri, kullanıcılar oluşturur ve izinler atar
 * 
 * Author / Yazar: Yunus Emre Gümüş, Alperen Aktaş, Mehmet Miraç Özmen
 * Date Created / Oluşturulma Tarihi: February 16, 2026
 * Last Modified / Son Değişiklik: February 16, 2026
 * 
 * Description:
 *   Implements role-based access control (RBAC) for the Student Management System.
 *   Creates three primary roles (Student, Teacher, Admin) with appropriate
 *   permissions for each role on relevant database tables.
 * 
 * Açıklama:
 *   Öğrenci Yönetim Sistemi için rol tabanlı erişim kontrolü (RBAC) uygular.
 *   Her rol için ilgili veritabanı tablolarında uygun izinlerle üç temel rol
 *   (Öğrenci, Öğretmen, Yönetici) oluşturur.
 *
 * SECURITY WARNING / GÜVENLİK UYARISI:
 *   Replace [SECURE_PASSWORD_HERE] placeholders with strong passwords before deployment!
 *   Passwords should meet complexity requirements:
 *   - Minimum 8 characters / En az 8 karakter
 *   - Mix of uppercase, lowercase, numbers, and symbols / Büyük harf, küçük harf, sayı ve sembol karışımı
 *   - Never use default passwords in production / Üretim ortamında asla varsayılan şifreler kullanmayın
 *
 * Dependencies / Bağımlılıklar:
 *   - Requires 01_CreateTables.sql to be executed first
 *   - 01_CreateTables.sql'in önce çalıştırılması gerekir
 *   - Requires sysadmin privileges to create logins
 *   - Oturum açma bilgileri oluşturmak için sysadmin yetkileri gerekir
 * 
 * Execution / Çalıştırma:
 *   Run once during initial setup (idempotent - can be re-run safely)
 *   İlk kurulum sırasında bir kez çalıştırın (güvenle yeniden çalıştırılabilir)
 ******************************************************************************/

USE master;
GO

-- ============================================================================
-- 1. CREATE DATABASE ROLES / VERİTABANI ROLLERİ OLUŞTUR
-- ============================================================================

USE StudentManagementDB;
GO

-- Remove users from roles before dropping / Rolleri silmeden önce kullanıcıları çıkar
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StudentRole' AND type = 'R')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    SELECT @sql = @sql + 'ALTER ROLE StudentRole DROP MEMBER ' + QUOTENAME(dp.name) + ';'
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    WHERE drm.role_principal_id = DATABASE_PRINCIPAL_ID('StudentRole');
    IF @sql <> '' EXEC sp_executesql @sql;
END
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TeacherRole' AND type = 'R')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    SELECT @sql = @sql + 'ALTER ROLE TeacherRole DROP MEMBER ' + QUOTENAME(dp.name) + ';'
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    WHERE drm.role_principal_id = DATABASE_PRINCIPAL_ID('TeacherRole');
    IF @sql <> '' EXEC sp_executesql @sql;
END
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminRole' AND type = 'R')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    SELECT @sql = @sql + 'ALTER ROLE AdminRole DROP MEMBER ' + QUOTENAME(dp.name) + ';'
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    WHERE drm.role_principal_id = DATABASE_PRINCIPAL_ID('AdminRole');
    IF @sql <> '' EXEC sp_executesql @sql;
END
GO

-- Drop existing roles if they exist / Mevcut roller varsa sil
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StudentRole' AND type = 'R')
    DROP ROLE StudentRole;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TeacherRole' AND type = 'R')
    DROP ROLE TeacherRole;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminRole' AND type = 'R')
    DROP ROLE AdminRole;
GO

-- Create roles / Rolleri oluştur
CREATE ROLE StudentRole;
CREATE ROLE TeacherRole;
CREATE ROLE AdminRole;
GO

PRINT 'Database roles created successfully.';
GO

-- ============================================================================
-- 2. CREATE SERVER LOGINS / SUNUCU OTURUM AÇMA BİLGİLERİ OLUŞTUR
-- ============================================================================

USE master;
GO

-- Drop existing logins if they exist / Mevcut oturum açma bilgileri varsa sil
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'student1')
    DROP LOGIN student1;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'teacher1')
    DROP LOGIN teacher1;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'admin1')
    DROP LOGIN admin1;
GO

/*
 * SECURITY CRITICAL / GÜVENLİK KRİTİK:
 * Replace [SECURE_PASSWORD_HERE] with actual strong passwords!
 * [GÜVENLİ_ŞİFRE_BURAYA] ifadesini gerçek güçlü şifrelerle değiştirin!
 * 
 * Example strong password / Örnek güçlü şifre: "St@rongP@ssw0rd2026!"
 * 
 * For production, consider using:
 * Üretim için şunları kullanmayı düşünün:
 * - Windows Authentication instead of SQL Authentication
 * - Windows Kimlik Doğrulaması, SQL Kimlik Doğrulaması yerine
 * - Password policies with CHECK_POLICY = ON
 * - CHECK_POLICY = ON ile şifre politikaları
 * - Password expiration with MUST_CHANGE and CHECK_EXPIRATION = ON
 * - MUST_CHANGE ve CHECK_EXPIRATION = ON ile şifre sona erme
 */

-- Create logins for sample users / Örnek kullanıcılar için oturum açma bilgileri oluştur
CREATE LOGIN student1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]';
CREATE LOGIN teacher1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]';
CREATE LOGIN admin1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]';
GO

-- TODO: For production, uncomment and configure password policies:
-- TODO: Üretim için, şifre politikalarını açın ve yapılandırın:
/*
CREATE LOGIN student1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]'
    MUST_CHANGE,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;

CREATE LOGIN teacher1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]'
    MUST_CHANGE,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;

CREATE LOGIN admin1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]'
    MUST_CHANGE,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
*/

PRINT 'Server logins created successfully.';
GO

-- ============================================================================
-- 3. CREATE DATABASE USERS / VERİTABANI KULLANICILARI OLUŞTUR
-- ============================================================================

USE StudentManagementDB;
GO

-- Drop existing users if they exist / Mevcut kullanıcılar varsa sil
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'student1' AND type = 'S')
    DROP USER student1;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'teacher1' AND type = 'S')
    DROP USER teacher1;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin1' AND type = 'S')
    DROP USER admin1;
GO

-- Create database users from logins / Oturum açma bilgilerinden veritabanı kullanıcıları oluştur
CREATE USER student1 FOR LOGIN student1;
CREATE USER teacher1 FOR LOGIN teacher1;
CREATE USER admin1 FOR LOGIN admin1;
GO

PRINT 'Database users created successfully.';
GO

-- ============================================================================
-- 4. ASSIGN USERS TO ROLES / KULLANICILARI ROLLERE ATA
-- ============================================================================

-- Add users to their respective roles / Kullanıcıları ilgili rollerine ekle
ALTER ROLE StudentRole ADD MEMBER student1;
ALTER ROLE TeacherRole ADD MEMBER teacher1;
ALTER ROLE AdminRole ADD MEMBER admin1;
GO

PRINT 'Users assigned to roles successfully.';
GO

-- ============================================================================
-- 5. GRANT PERMISSIONS TO STUDENT ROLE / ÖĞRENCİ ROLÜNE İZİNLER VER
-- ============================================================================

/*
 * Students can view their own information, schedules, grades, and attendance
 * Öğrenciler kendi bilgilerini, programlarını, notlarını ve devamsızlıklarını görüntüleyebilir
 * 
 * Permissions: SELECT only (read-only access)
 * İzinler: Sadece SELECT (salt okunur erişim)
 */

GRANT SELECT ON dbo.Students TO StudentRole;
GRANT SELECT ON dbo.Timetables TO StudentRole;
GRANT SELECT ON dbo.Exams TO StudentRole;
GRANT SELECT ON dbo.Attendances TO StudentRole;
GRANT SELECT ON dbo.Grades TO StudentRole;
GRANT SELECT ON dbo.RolePermissions TO StudentRole;
GRANT SELECT ON dbo.Courses TO StudentRole;
GRANT SELECT ON dbo.Departments TO StudentRole;
GRANT SELECT ON dbo.Teachers TO StudentRole;
GO

PRINT 'Student role permissions granted.';
GO

-- ============================================================================
-- 6. GRANT PERMISSIONS TO TEACHER ROLE / ÖĞRETMEN ROLÜNE İZİNLER VER
-- ============================================================================

/*
 * Teachers can view student information and manage courses, attendance, and grades
 * Öğretmenler öğrenci bilgilerini görüntüleyebilir ve dersleri, devamsızlıkları ve notları yönetebilir
 * 
 * Permissions: SELECT on student data, SELECT/INSERT/UPDATE on course-related tables
 * İzinler: Öğrenci verilerinde SELECT, ders ile ilgili tablolarda SELECT/INSERT/UPDATE
 */

-- Read access to student information / Öğrenci bilgilerine okuma erişimi
GRANT SELECT ON dbo.Students TO TeacherRole;
GRANT SELECT ON dbo.Departments TO TeacherRole;
GRANT SELECT ON dbo.RolePermissions TO TeacherRole;
GRANT SELECT ON dbo.Timetables TO TeacherRole;
GRANT SELECT ON dbo.Exams TO TeacherRole;

-- Manage courses, attendance, and grades / Dersleri, devamsızlıkları ve notları yönet
GRANT SELECT, INSERT, UPDATE ON dbo.Courses TO TeacherRole;
GRANT SELECT, INSERT, UPDATE ON dbo.Attendances TO TeacherRole;
GRANT SELECT, INSERT, UPDATE ON dbo.Grades TO TeacherRole;
GRANT SELECT, INSERT, UPDATE ON dbo.StudentAttendances TO TeacherRole;
GO

PRINT 'Teacher role permissions granted.';
GO

-- ============================================================================
-- 7. GRANT PERMISSIONS TO ADMIN ROLE / YÖNETİCİ ROLÜNE İZİNLER VER
-- ============================================================================

/*
 * Administrators have full control over all tables
 * Yöneticiler tüm tablolar üzerinde tam kontrole sahiptir
 * 
 * Permissions: SELECT, INSERT, UPDATE, DELETE, ALTER on all tables
 * İzinler: Tüm tablolarda SELECT, INSERT, UPDATE, DELETE, ALTER
 */

-- Core entity tables / Ana varlık tabloları
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Departments TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Roles TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Teachers TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Students TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Admins TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.RolePermissions TO AdminRole;

-- Course management tables / Ders yönetim tabloları
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Courses TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Classes TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Days TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Timetables TO AdminRole;

-- Assessment and attendance tables / Değerlendirme ve devamsızlık tabloları
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Attendances TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Exams TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Grades TO AdminRole;

-- Audit and relationship tables / Denetim ve ilişki tabloları
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.Logs TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.StudentAttendances TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.CourseDepartments TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.CourseTeachers TO AdminRole;
GO

PRINT 'Admin role permissions granted.';
GO

-- ============================================================================
-- SUMMARY / ÖZET
-- ============================================================================

PRINT '';
PRINT '========================================================================';
PRINT 'Security configuration completed successfully!';
PRINT '========================================================================';
PRINT '';
PRINT 'Roles Created:';
PRINT '  - StudentRole (Read-only access)';
PRINT '  - TeacherRole (Manage courses, grades, attendance)';
PRINT '  - AdminRole (Full system access)';
PRINT '';
PRINT 'Sample Users Created:';
PRINT '  - student1 (StudentRole)';
PRINT '  - teacher1 (TeacherRole)';
PRINT '  - admin1 (AdminRole)';
PRINT '';
PRINT 'WARNING:';
PRINT '  Remember to change [SECURE_PASSWORD_HERE] placeholders to strong passwords!';
PRINT '========================================================================';
GO

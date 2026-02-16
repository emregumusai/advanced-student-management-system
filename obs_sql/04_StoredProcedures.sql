/*******************************************************************************
 * File: 04_StoredProcedures.sql
 * Purpose: Creates stored procedures for business logic operations
 * Amaç: İş mantığı operasyonları için saklı yordamlar oluşturur
 * 
 * Author / Yazar: Yunus Emre Gümüş, Alperen Aktaş, Mehmet Miraç Özmen
 * Date Created / Oluşturulma Tarihi: February 16, 2026
 * Last Modified / Son Değişiklik: February 16, 2026
 * 
 * Description:
 *   Contains stored procedures for common database operations.
 *   Currently includes student registration with validation logic.
 * 
 * Açıklama:
 *   Yaygın veritabanı işlemleri için saklı yordamlar içerir.
 *   Şu anda doğrulama mantığı ile öğrenci kaydını içermektedir.
 *
 * Dependencies / Bağımlılıklar:
 *   - Requires 01_CreateTables.sql to be executed first
 *   - 01_CreateTables.sql'in önce çalıştırılması gerekir
 * 
 * Execution / Çalıştırma:
 *   Run once during initial setup (idempotent - can be re-run safely)
 *   İlk kurulum sırasında bir kez çalıştırın (güvenle yeniden çalıştırılabilir)
 ******************************************************************************/

USE StudentManagementDB;
GO

-- ============================================================================
-- STORED PROCEDURE: RegisterStudent
-- SAKLI YORDAM: RegisterStudent (Öğrenci Kaydet)
-- ============================================================================

/*==============================================================================
 * Stored Procedure: RegisterStudent
 * Purpose: Registers a new student in the system with comprehensive validation
 * 
 * Saklı Yordam: RegisterStudent
 * Amaç: Kapsamlı doğrulama ile sisteme yeni bir öğrenci kaydeder
 * 
 * Parameters / Parametreler:
 *   @StudentNo    NVARCHAR(50)  - Unique student identification number
 *                                 Benzersiz öğrenci kimlik numarası
 *   @Name         NVARCHAR(255) - Student's first name
 *                                 Öğrencinin adı
 *   @Surname      NVARCHAR(255) - Student's last name
 *                                 Öğrencinin soyadı
 *   @DepartmentID INT           - Valid department ID (must exist in Departments table)
 *                                 Geçerli bölüm ID'si (Departments tablosunda mevcut olmalı)
 *   @AdvisorID    INT           - Valid teacher ID to serve as academic advisor
 *                                 Akademik danışman olarak görev yapacak geçerli öğretmen ID'si
 *
 * Returns / Dönüş Değeri:
 *   0  - Success (student registered)
 *        Başarılı (öğrenci kaydedildi)
 *   -1 - Invalid DepartmentID (department does not exist)
 *        Geçersiz DepartmentID (bölüm mevcut değil)
 *   -2 - Invalid AdvisorID (teacher does not exist)
 *        Geçersiz AdvisorID (öğretmen mevcut değil)
 *   -3 - Duplicate StudentNo (student number already exists)
 *        Yinelenen StudentNo (öğrenci numarası zaten mevcut)
 *   -99 - Unexpected error occurred
 *         Beklenmeyen hata oluştu
 *
 * Example Usage / Kullanım Örneği:
 *   DECLARE @Result INT;
 *   EXEC @Result = RegisterStudent 
 *       @StudentNo = '220260999', 
 *       @Name = 'Ahmet', 
 *       @Surname = 'Yılmaz', 
 *       @DepartmentID = 1, 
 *       @AdvisorID = 5;
 *   
 *   IF @Result = 0
 *       PRINT 'Student registered successfully.';
 *   ELSE
 *       PRINT 'Student registration failed with error code: ' + CAST(@Result AS NVARCHAR);
 *
 * Error Conditions / Hata Durumları:
 *   - Returns -1 if DepartmentID does not exist in Departments table
 *     DepartmentID Departments tablosunda mevcut değilse -1 döner
 *   - Returns -2 if AdvisorID does not exist in Teachers table
 *     AdvisorID Teachers tablosunda mevcut değilse -2 döner
 *   - Returns -3 if StudentNo is already registered
 *     StudentNo zaten kayıtlıysa -3 döner
 *   - Returns -99 for any other unexpected errors
 *     Diğer beklenmeyen hatalar için -99 döner
 *
 * Notes / Notlar:
 *   - RoleID is automatically set to 3 (StudentRole) for all new students
 *     RoleID tüm yeni öğrenciler için otomatik olarak 3'e (StudentRole) ayarlanır
 *   - StudentNo must be unique across all students
 *     StudentNo tüm öğrenciler arasında benzersiz olmalıdır
 *   - DepartmentID and AdvisorID are validated before insertion
 *     DepartmentID ve AdvisorID ekleme işleminden önce doğrulanır
 *
 * Change History / Değişiklik Geçmişi:
 *   February 16, 2026 - Initial creation with bilingual documentation
 *                       İki dilli dokümantasyon ile ilk oluşturma
 *============================================================================*/

-- Drop procedure if it exists / Yordam mevcutsa sil
IF OBJECT_ID('dbo.RegisterStudent', 'P') IS NOT NULL
    DROP PROCEDURE dbo.RegisterStudent;
GO

CREATE PROCEDURE dbo.RegisterStudent
    @StudentNo NVARCHAR(50),
    @Name NVARCHAR(255),
    @Surname NVARCHAR(255),
    @DepartmentID INT,
    @AdvisorID INT
AS
BEGIN
    -- Prevent result set count messages for cleaner output
    -- Daha temiz çıktı için sonuç kümesi sayısı mesajlarını engelle
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- ====================================================================
        -- VALIDATION 1: Check if Department exists
        -- DOĞRULAMA 1: Bölümün mevcut olup olmadığını kontrol et
        -- ====================================================================
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.Departments 
            WHERE ID = @DepartmentID
        )
        BEGIN
            PRINT 'Error: Invalid department ID. Student registration cannot proceed.';
            RETURN -1;  -- Return error code -1 / Hata kodu -1 döndür
        END

        -- ====================================================================
        -- VALIDATION 2: Check if Advisor (Teacher) exists
        -- DOĞRULAMA 2: Danışmanın (Öğretmen) mevcut olup olmadığını kontrol et
        -- ====================================================================
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.Teachers 
            WHERE ID = @AdvisorID
        )
        BEGIN
            PRINT 'Error: Invalid advisor ID. Student registration cannot proceed.';
            RETURN -2;  -- Return error code -2 / Hata kodu -2 döndür
        END

        -- ====================================================================
        -- VALIDATION 3: Check if StudentNo is unique
        -- DOĞRULAMA 3: StudentNo'nun benzersiz olup olmadığını kontrol et
        -- ====================================================================
        IF EXISTS (
            SELECT 1 
            FROM dbo.Students 
            WHERE StudentNo = @StudentNo
        )
        BEGIN
            PRINT 'Error: This student number is already registered.';
            RETURN -3;  -- Return error code -3 / Hata kodu -3 döndür
        END

        -- ====================================================================
        -- INSERT: Register the new student
        -- EKLEME: Yeni öğrenciyi kaydet
        -- ====================================================================
        -- Note: RoleID is hardcoded to 3 (StudentRole) for all students
        -- Not: RoleID tüm öğrenciler için 3'e (StudentRole) sabit kodlanmıştır
        INSERT INTO dbo.Students (StudentNo, Name, Surname, DepartmentID, AdvisorID, RoleID)
        VALUES (@StudentNo, @Name, @Surname, @DepartmentID, @AdvisorID, 3);

        -- Success message / Başarı mesajı
        PRINT 'Success: Student registered successfully.';
        PRINT 'Student Number: ' + @StudentNo;
        PRINT 'Full Name: ' + @Name + ' ' + @Surname;
        
        RETURN 0;  -- Return success code 0 / Başarı kodu 0 döndür
        
    END TRY
    BEGIN CATCH
        -- ====================================================================
        -- ERROR HANDLING: Catch any unexpected errors
        -- HATA YÖNETİMİ: Beklenmeyen hataları yakala
        -- ====================================================================
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        DECLARE @ErrorNumber INT;
        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorNumber = ERROR_NUMBER();
        
        -- Log error details / Hata detaylarını günlükle
        PRINT 'Error: An unexpected error occurred during student registration.';
        PRINT 'Error Number: ' + CAST(@ErrorNumber AS NVARCHAR);
        PRINT 'Error Message: ' + @ErrorMessage;
        
        -- Re-throw the error for caller to handle / Arayan tarafın işlemesi için hatayı yeniden fırlat
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        
        RETURN -99;  -- Return generic error code / Genel hata kodu döndür
        
    END CATCH
END;
GO

-- ============================================================================
-- VERIFICATION: Test if procedure was created successfully
-- DOĞRULAMA: Yordamın başarıyla oluşturulup oluşturulmadığını test et
-- ============================================================================

IF OBJECT_ID('dbo.RegisterStudent', 'P') IS NOT NULL
BEGIN
    PRINT '';
    PRINT '========================================================================';
    PRINT 'Stored procedure created successfully!';
    PRINT '========================================================================';
    PRINT 'Procedure Name: RegisterStudent';
    PRINT 'Status: Active';
    PRINT '';
    PRINT 'Usage Example:';
    PRINT '  EXEC RegisterStudent ''220260999'', ''John'', ''Smith'', 1, 5;';
    PRINT '========================================================================';
END
ELSE
BEGIN
    PRINT 'ERROR: Stored procedure creation failed!';
END
GO

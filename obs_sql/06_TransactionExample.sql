/*******************************************************************************
 * File: 06_TransactionExample.sql
 * Purpose: Demonstrates transaction management and error handling best practices
 * Amaç: İşlem yönetimi ve hata işleme en iyi uygulamalarını gösterir
 * 
 * Author / Yazar: Yunus Emre Gümüş, Alperen Aktaş, Mehmet Miraç Özmen
 * Date Created / Oluşturulma Tarihi: February 16, 2026
 * Last Modified / Son Değişiklik: February 16, 2026
 * 
 * Description:
 *   This script demonstrates proper transaction management using TRY/CATCH blocks.
 *   It shows how to ensure data integrity by rolling back all changes if any
 *   operation fails within a transaction. The example creates a new course,
 *   links it to departments and teachers, creates an exam, and adds a grade.
 * 
 * Açıklama:
 *   Bu betik TRY/CATCH blokları kullanarak uygun işlem yönetimini gösterir.
 *   İşlem içinde herhangi bir operasyon başarısız olursa tüm değişiklikleri
 *   geri alarak veri bütünlüğünün nasıl sağlanacağını gösterir. Örnek, yeni bir
 *   ders oluşturur, bunu bölümler ve öğretmenlerle ilişkilendirir, bir sınav
 *   oluşturur ve bir not ekler.
 *
 * Key Concepts Demonstrated / Gösterilen Temel Kavramlar:
 *   - BEGIN TRANSACTION / COMMIT TRANSACTION
 *   - TRY/CATCH error handling / TRY/CATCH hata yönetimi
 *   - ROLLBACK on error / Hata durumunda ROLLBACK
 *   - SCOPE_IDENTITY() for retrieving inserted IDs / Eklenen ID'leri almak için SCOPE_IDENTITY()
 *   - Data validation before insertion / Ekleme öncesi veri doğrulama
 *   - RAISERROR and THROW for error signaling / Hata bildirimi için RAISERROR ve THROW
 *
 * Dependencies / Bağımlılıklar:
 *   - Requires 01_CreateTables.sql and 02_InsertData.sql to be executed
 *   - 01_CreateTables.sql ve 02_InsertData.sql'in çalıştırılması gerekir
 *   - Requires existing data in Departments and Teachers tables
 *   - Departments ve Teachers tablolarında mevcut veri gerekir
 * 
 * Execution / Çalıştırma:
 *   Can be run multiple times for testing (creates new records each time)
 *   Test için birden fazla kez çalıştırılabilir (her seferinde yeni kayıtlar oluşturur)
 *
 * NOTE / NOT:
 *   This is a DEMONSTRATION script with intentional validation logic.
 *   Modify @Score variable to test different scenarios (valid/invalid values).
 *   Bu, kasıtlı doğrulama mantığına sahip bir GÖSTERIM betiğidir.
 *   Farklı senaryoları test etmek için @Score değişkenini değiştirin (geçerli/geçersiz değerler).
 ******************************************************************************/

USE StudentManagementDB;
GO

-- ============================================================================
-- TRANSACTION EXAMPLE: Multi-Step Operation with Error Handling
-- İŞLEM ÖRNEĞİ: Hata Yönetimi ile Çok Adımlı Operasyon
-- ============================================================================

PRINT '';
PRINT '========================================================================';
PRINT 'Starting Transaction Example';
PRINT '========================================================================';
PRINT '';

-- Begin the transaction / İşlemi başlat
BEGIN TRANSACTION;

BEGIN TRY
    -- ========================================================================
    -- STEP 1: Insert a new course / ADIM 1: Yeni bir ders ekle
    -- ========================================================================
    PRINT 'Step 1: Inserting new course...';
    
    INSERT INTO dbo.Courses (CourseName, GradeLevel)
    VALUES ('Advanced Database Systems', 3);  -- Example course / Örnek ders
    
    -- Retrieve the ID of the newly inserted course
    -- Yeni eklenen dersin ID'sini al
    DECLARE @NewCourseID INT;
    SET @NewCourseID = SCOPE_IDENTITY();
    
    PRINT 'Success: Course created with ID = ' + CAST(@NewCourseID AS NVARCHAR);
    PRINT '';

    -- ========================================================================
    -- STEP 2: Link course to a department / ADIM 2: Dersi bir bölüme bağla
    -- ========================================================================
    PRINT 'Step 2: Linking course to department...';
    
    INSERT INTO dbo.CourseDepartments (CourseID, DepartmentID)
    VALUES (@NewCourseID, 1);  -- Example: DepartmentID = 1 (Computer Engineering)
                               -- Örnek: DepartmentID = 1 (Bilgisayar Mühendisliği)
    
    PRINT 'Success: Course linked to Department ID = 1';
    PRINT '';

    -- ========================================================================
    -- STEP 3: Assign a teacher to the course / ADIM 3: Derse öğretmen ata
    -- ========================================================================
    PRINT 'Step 3: Assigning teacher to course...';
    
    INSERT INTO dbo.CourseTeachers (CourseID, TeacherID)
    VALUES (@NewCourseID, 1);  -- Example: TeacherID = 1
                               -- Örnek: TeacherID = 1
    
    PRINT 'Success: Teacher ID = 1 assigned to course';
    PRINT '';

    -- ========================================================================
    -- STEP 4: Create an exam for the course / ADIM 4: Ders için sınav oluştur
    -- ========================================================================
    PRINT 'Step 4: Creating exam for course...';
    
    INSERT INTO dbo.Exams (CourseID, Date, ExamType)
    VALUES (@NewCourseID, '2026-03-15', 'Midterm');  -- Example exam date and type
                                                      -- Örnek sınav tarihi ve türü
    
    -- Retrieve the ID of the newly inserted exam
    -- Yeni eklenen sınavın ID'sini al
    DECLARE @NewExamID INT;
    SET @NewExamID = SCOPE_IDENTITY();
    
    PRINT 'Success: Exam created with ID = ' + CAST(@NewExamID AS NVARCHAR);
    PRINT '';

    -- ========================================================================
    -- STEP 5: Validate and insert a grade / ADIM 5: Notu doğrula ve ekle
    -- ========================================================================
    PRINT 'Step 5: Validating and inserting grade...';
    
    -- Define a test score (MODIFY THIS VALUE TO TEST DIFFERENT SCENARIOS)
    -- Test notu tanımla (FARKLI SENARYOLARI TEST ETMEK İÇİN BU DEĞERİ DEĞİŞTİRİN)
    DECLARE @Score FLOAT;
    SET @Score = 85.5;  -- Valid score: between 0 and 100
                        -- Geçerli not: 0 ile 100 arasında
    -- SET @Score = 105;  -- Uncomment to test INVALID score (will cause rollback)
                          -- Geçersiz notu test etmek için yorum satırını kaldırın (geri alma yapacak)
    
    -- Validate score is within acceptable range (0-100)
    -- Notun kabul edilebilir aralıkta olduğunu doğrula (0-100)
    IF @Score < 0 OR @Score > 100
    BEGIN
        -- Score is invalid - raise an error to trigger rollback
        -- Not geçersiz - geri almayı tetiklemek için hata oluştur
        PRINT 'ERROR: Invalid score detected!';
        PRINT 'Score must be between 0 and 100. Provided: ' + CAST(@Score AS NVARCHAR);
        PRINT '';
        
        -- Use RAISERROR to signal the error
        -- Hatayı bildirmek için RAISERROR kullan
        RAISERROR('Exam score must be between 0 and 100.', 16, 1);
        
        -- THROW also works (more modern approach)
        -- THROW da çalışır (daha modern yaklaşım)
        -- THROW 50000, 'Exam score must be between 0 and 100.', 1;
    END
    
    -- Score is valid - proceed with insertion
    -- Not geçerli - eklemeye devam et
    INSERT INTO dbo.Grades (Score, StudentID, ExamID)
    VALUES (@Score, 1, @NewExamID);  -- Example: StudentID = 1
                                     -- Örnek: StudentID = 1
    
    PRINT 'Success: Grade inserted (Score = ' + CAST(@Score AS NVARCHAR) + ')';
    PRINT '';

    -- ========================================================================
    -- COMMIT: All operations successful - save changes
    -- COMMIT: Tüm işlemler başarılı - değişiklikleri kaydet
    -- ========================================================================
    COMMIT TRANSACTION;
    
    PRINT '========================================================================';
    PRINT 'SUCCESS: Transaction completed successfully!';
    PRINT '========================================================================';
    PRINT 'All changes have been saved to the database.';
    PRINT '';
    PRINT 'Summary:';
    PRINT '  - New Course ID: ' + CAST(@NewCourseID AS NVARCHAR);
    PRINT '  - New Exam ID: ' + CAST(@NewExamID AS NVARCHAR);
    PRINT '  - Grade Score: ' + CAST(@Score AS NVARCHAR);
    PRINT '========================================================================';

END TRY

BEGIN CATCH
    -- ========================================================================
    -- ERROR HANDLING: Rollback transaction if any error occurred
    -- HATA YÖNETİMİ: Herhangi bir hata oluştuysa işlemi geri al
    -- ========================================================================
    
    -- Check if there's an active transaction to rollback
    -- Geri alınacak aktif bir işlem olup olmadığını kontrol et
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT '';
        PRINT '!!! ROLLBACK EXECUTED !!!';
        PRINT 'All changes have been reverted.';
        PRINT '';
    END
    
    -- Capture error details / Hata detaylarını yakala
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorLine INT;
    
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE(),
        @ErrorNumber = ERROR_NUMBER(),
        @ErrorLine = ERROR_LINE();
    
    -- Display detailed error information / Detaylı hata bilgilerini göster
    PRINT '========================================================================';
    PRINT 'ERROR: Transaction failed and was rolled back!';
    PRINT '========================================================================';
    PRINT 'Error Details:';
    PRINT '  Error Number: ' + CAST(@ErrorNumber AS NVARCHAR);
    PRINT '  Error Line: ' + CAST(@ErrorLine AS NVARCHAR);
    PRINT '  Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR);
    PRINT '  Error State: ' + CAST(@ErrorState AS NVARCHAR);
    PRINT '  Error Message: ' + @ErrorMessage;
    PRINT '========================================================================';
    PRINT '';
    PRINT 'Troubleshooting Tips:';
    PRINT '  - Check if the score value is between 0 and 100';
    PRINT '  - Verify that StudentID and TeacherID exist in their respective tables';
    PRINT '  - Ensure DepartmentID is valid';
    PRINT '========================================================================';
    
    -- Re-raise the error to the caller (optional)
    -- Hatayı arayan koda yeniden bildirme (isteğe bağlı)
    -- RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    
END CATCH;

-- ============================================================================
-- EXAMPLE COMPLETE / ÖRNEK TAMAMLANDI
-- ============================================================================

PRINT '';
PRINT 'Transaction example script finished.';
PRINT '';
GO

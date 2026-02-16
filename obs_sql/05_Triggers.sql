/*******************************************************************************
 * File: 05_Triggers.sql
 * Purpose: Creates database triggers for audit logging and business rules
 * Amaç: Denetim günlüğü ve iş kuralları için veritabanı tetikleyicileri oluşturur
 * 
 * Author / Yazar: Yunus Emre Gümüş, Alperen Aktaş, Mehmet Miraç Özmen
 * Date Created / Oluşturulma Tarihi: February 16, 2026
 * Last Modified / Son Değişiklik: February 16, 2026
 * 
 * Description:
 *   Contains triggers that automatically execute in response to database events.
 *   Currently includes audit trail trigger for student deletions.
 * 
 * Açıklama:
 *   Veritabanı olaylarına yanıt olarak otomatik olarak çalışan tetikleyiciler içerir.
 *   Şu anda öğrenci silme işlemleri için denetim kaydı tetikleyicisi içermektedir.
 *
 * Dependencies / Bağımlılıklar:
 *   - Requires 01_CreateTables.sql to be executed first
 *   - 01_CreateTables.sql'in önce çalıştırılması gerekir
 *   - Requires Logs table for audit trail functionality
 *   - Denetim kaydı işlevselliği için Logs tablosu gerekir
 * 
 * Execution / Çalıştırma:
 *   Run once during initial setup (idempotent - can be re-run safely)
 *   İlk kurulum sırasında bir kez çalıştırın (güvenle yeniden çalıştırılabilir)
 ******************************************************************************/

USE StudentManagementDB;
GO

-- ============================================================================
-- TRIGGER: trg_Student_Delete
-- TETİKLEYİCİ: trg_Student_Delete (Öğrenci Silme Tetikleyicisi)
-- ============================================================================

/*==============================================================================
 * Trigger: trg_Student_Delete
 * Purpose: Automatically logs student deletion events to the audit trail
 * 
 * Tetikleyici: trg_Student_Delete
 * Amaç: Öğrenci silme olaylarını otomatik olarak denetim kaydına günlükler
 * 
 * Table: Students
 * Trigger Type: AFTER DELETE
 * Tablo: Students (Öğrenciler)
 * Tetikleyici Türü: AFTER DELETE (Silme Sonrası)
 * 
 * Description:
 *   This trigger fires automatically after a student record is deleted.
 *   It captures information from the DELETED virtual table and logs it
 *   to the Logs table for audit trail purposes.
 * 
 * Açıklama:
 *   Bu tetikleyici bir öğrenci kaydı silindikten sonra otomatik olarak tetiklenir.
 *   DELETED sanal tablosundan bilgileri yakalar ve denetim kaydı amacıyla
 *   Logs tablosuna kaydeder.
 * 
 * Logged Information / Günlüklenen Bilgiler:
 *   - UserType: Always "Student" for this trigger
 *               Bu tetikleyici için her zaman "Student"
 *   - UserID: The ID of the deleted student
 *             Silinen öğrencinin ID'si
 *   - Action: Always "DELETE"
 *             Her zaman "DELETE"
 *   - Description: Full name of the deleted student
 *                  Silinen öğrencinin tam adı
 *   - Timestamp: Automatic timestamp of the deletion
 *                Silme işleminin otomatik zaman damgası
 * 
 * Example Log Entry / Örnek Günlük Kaydı:
 *   UserType: Student
 *   UserID: 123
 *   Action: DELETE
 *   Description: Student deleted: Ahmet Yılmaz
 *   Timestamp: 2026-02-16 14:30:00
 * 
 * Notes / Notlar:
 *   - DELETED is a special virtual table available in DELETE triggers
 *     DELETED, DELETE tetikleyicilerinde kullanılabilen özel bir sanal tablodur
 *   - Contains the rows that were deleted from the Students table
 *     Students tablosundan silinen satırları içerir
 *   - Trigger executes once per DELETE statement, not per row
 *     Tetikleyici her satır için değil, DELETE ifadesi başına bir kez çalışır
 *   - If multiple students are deleted, multiple log entries are created
 *     Birden fazla öğrenci silinirse, birden fazla günlük kaydı oluşturulur
 * 
 * Error Handling / Hata Yönetimi:
 *   - Wrapped in TRY/CATCH to prevent deletion from failing if logging fails
 *     Günlükleme başarısız olursa silme işleminin başarısız olmasını önlemek için TRY/CATCH içine alınmıştır
 *   - Errors are logged but do not rollback the deletion
 *     Hatalar günlüklenirü ama silme işlemini geri almaz
 * 
 * Change History / Değişiklik Geçmişi:
 *   February 16, 2026 - Enhanced with bilingual documentation and error handling
 *                       İki dilli dokümantasyon ve hata yönetimi ile geliştirildi
 *============================================================================*/

-- Drop trigger if it exists / Tetikleyici mevcutsa sil
IF OBJECT_ID('dbo.trg_Student_Delete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Student_Delete;
GO

CREATE TRIGGER dbo.trg_Student_Delete
ON dbo.Students
AFTER DELETE
AS
BEGIN
    -- Prevent result set count messages for cleaner output
    -- Daha temiz çıktı için sonuç kümesi sayısı mesajlarını engelle
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- ====================================================================
        -- LOG DELETION: Insert audit trail record for each deleted student
        -- SİLMEYİ GÜNLÜKLE: Silinen her öğrenci için denetim kaydı ekle
        -- ====================================================================
        INSERT INTO dbo.Logs (UserType, UserID, Action, Description, Timestamp)
        SELECT 
            'Student' AS UserType,           -- User type / Kullanıcı türü
            ID AS UserID,                    -- Deleted student's ID / Silinen öğrencinin ID'si
            'DELETE' AS Action,              -- Action type / İşlem türü
            CONCAT(                          -- Build description / Açıklama oluştur
                'Student deleted: ',         -- English prefix / İngilizce önek
                Name, 
                ' ', 
                Surname,
                ' (Student No: ',           -- Add student number / Öğrenci numarasını ekle
                StudentNo,
                ')'
            ) AS Description,
            GETDATE() AS Timestamp           -- Current timestamp / Mevcut zaman damgası
        FROM 
            DELETED;  -- DELETED is a virtual table containing deleted rows
                      -- DELETED, silinen satırları içeren sanal bir tablodur
        
        -- Optional: Print confirmation message (useful for debugging)
        -- İsteğe bağlı: Onay mesajı yazdır (hata ayıklama için yararlıdır)
        DECLARE @RowCount INT = @@ROWCOUNT;
        IF @RowCount > 0
        BEGIN
            PRINT 'Audit log: ' + CAST(@RowCount AS NVARCHAR) + ' student deletion(s) logged successfully.';
        END
        
    END TRY
    BEGIN CATCH
        -- ====================================================================
        -- ERROR HANDLING: Log errors but don't prevent deletion
        -- HATA YÖNETİMİ: Hataları günlükle ama silme işlemini engelleme
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
        
        -- Print error information for debugging
        -- Hata ayıklama için hata bilgilerini yazdır
        PRINT 'Warning: Error occurred in trg_Student_Delete trigger.';
        PRINT 'Error Number: ' + CAST(@ErrorNumber AS NVARCHAR);
        PRINT 'Error Message: ' + @ErrorMessage;
        
        -- Note: We don't THROW here because we don't want logging failures
        -- to prevent the deletion from completing
        -- Not: Burada THROW kullanmıyoruz çünkü günlükleme hatalarının
        -- silme işleminin tamamlanmasını engellemesini istemiyoruz
        
    END CATCH
END;
GO

-- ============================================================================
-- VERIFICATION: Test if trigger was created successfully
-- DOĞRULAMA: Tetikleyicinin başarıyla oluşturulup oluşturulmadığını test et
-- ============================================================================

IF OBJECT_ID('dbo.trg_Student_Delete', 'TR') IS NOT NULL
BEGIN
    PRINT '';
    PRINT '========================================================================';
    PRINT 'Trigger created successfully!';
    PRINT '========================================================================';
    PRINT 'Trigger Name: trg_Student_Delete';
    PRINT 'Table: Students';
    PRINT 'Event: AFTER DELETE';
    PRINT 'Status: Active';
    PRINT '';
    PRINT 'Purpose:';
    PRINT '  Automatically logs all student deletions to the Logs table';
    PRINT '';
    PRINT 'Test Example:';
    PRINT '  -- Delete a test student (will be logged)';
    PRINT '  DELETE FROM Students WHERE StudentNo = ''TEST123'';';
    PRINT '  ';
    PRINT '  -- View the log entry';
    PRINT '  SELECT * FROM Logs WHERE Action = ''DELETE'' AND UserType = ''Student'';';
    PRINT '========================================================================';
END
ELSE
BEGIN
    PRINT 'ERROR: Trigger creation failed!';
END
GO

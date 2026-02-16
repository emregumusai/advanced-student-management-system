# BMÜ329 Veri Tabanı Sistemleri Dersi Dönem Projesi Gereksinimleri ve E-R Diyagramı

## Proje Başlığı: Gelişmiş ve Yenilikçi Öğrenci Bilgi Sistemi (OBS)

**Proje Ekibindeki Kişiler:**
- **220260028** - Yunus Emre Gümüş
- **220260018** - Alperen Aktaş
- **220260006** - Mehmet Miraç Özmen

---

## 📋 Professional Code Revision (Profesyonel Kod Revizyonu)

**Last Updated / Son Güncelleme:** February 16, 2026

This project has been professionally revised with international coding standards, bilingual documentation, and improved maintainability.

Bu proje uluslararası kodlama standartları, iki dilli dokümantasyon ve geliştirilmiş bakım kolaylığı ile profesyonel olarak revize edilmiştir.

### ✨ Key Improvements / Temel İyileştirmeler

#### 1. **File Organization / Dosya Organizasyonu**
SQL files have been renamed with English names and numeric prefixes for better portability across systems:

SQL dosyaları sistemler arası daha iyi taşınabilirlik için İngilizce adlar ve sayısal öneklerle yeniden adlandırıldı:

| Old Name / Eski Ad | New Name / Yeni Ad | Purpose / Amaç |
|-------------------|-------------------|---------------|
| `1. Tabloları_Oluştur.sql` | `01_CreateTables.sql` | Creates all database tables / Tüm veritabanı tablolarını oluşturur |
| `2. Verileri_Yaz.sql` | `02_InsertData.sql` | Inserts sample data / Örnek veri ekler |
| `3. Kısıtlar_Yetkilendirmeler.sql` | `03_SecurityPermissions.sql` | Sets up roles and permissions / Rol ve izinleri ayarlar |
| `4. Saklı_Yordam.sql` | `04_StoredProcedures.sql` | Creates stored procedures / Saklı yordamlar oluşturur |
| `5. Tetikleyici.sql` | `05_Triggers.sql` | Creates audit triggers / Denetim tetikleyicileri oluşturur |
| `6.transaction.sql` | `06_TransactionExample.sql` | Demonstrates transactions / İşlem yönetimini gösterir |

#### 2. **Bilingual Documentation / İki Dilli Dokümantasyon**
All SQL files now include comprehensive bilingual documentation (English + Turkish):

Tüm SQL dosyaları artık kapsamlı iki dilli dokümantasyon içeriyor (İngilizce + Türkçe):

- ✅ Professional file headers with metadata / Meta veri ile profesyonel dosya başlıkları
- ✅ Inline comments explaining logic / Mantığı açıklayan satır içi yorumlar
- ✅ Parameter and return value documentation / Parametre ve dönüş değeri dokümantasyonu
- ✅ Usage examples / Kullanım örnekleri
- ✅ Error handling documentation / Hata yönetimi dokümantasyonu

#### 3. **Naming Convention Fix / İsimlendirme Kuralı Düzeltmesi**
- ✅ **Fixed critical inconsistency**: `Admins` table now uses `Name` and `Surname` (PascalCase) instead of lowercase `name`, `surname`
- ✅ **Kritik tutarsızlık düzeltildi**: `Admins` tablosu artık küçük harf `name`, `surname` yerine `Name` ve `Surname` (PascalCase) kullanıyor
- ✅ All database objects follow consistent PascalCase naming / Tüm veritabanı nesneleri tutarlı PascalCase isimlendirme izliyor

#### 4. **Security Improvements / Güvenlik İyileştirmeleri**
- ✅ Hardcoded passwords replaced with `[SECURE_PASSWORD_HERE]` placeholders
- ✅ Sabit kodlanmış şifreler `[SECURE_PASSWORD_HERE]` yer tutucuları ile değiştirildi
- ✅ Security warnings and password policy documentation added
- ✅ Güvenlik uyarıları ve şifre politikası dokümantasyonu eklendi
- ✅ Production-ready security recommendations included
- ✅ Üretim ortamına hazır güvenlik önerileri dahil edildi

#### 5. **Error Handling & Transactions / Hata Yönetimi ve İşlemler**
- ✅ All data insertion wrapped in transactions with TRY/CATCH blocks
- ✅ Tüm veri eklemeleri TRY/CATCH blokları ile işlemler içine alındı
- ✅ Automatic rollback on errors / Hatalarda otomatik geri alma
- ✅ Comprehensive error logging / Kapsamlı hata günlüğü
- ✅ Proper return codes in stored procedures / Saklı yordamlarda uygun dönüş kodları

#### 6. **Idempotency / Tekrar Çalıştırılabilirlik**
All scripts can now be safely re-run without errors:

Tüm betikler artık hatasız olarak güvenle yeniden çalıştırılabilir:

- ✅ `DROP TABLE IF EXISTS` statements / İfadeleri
- ✅ `DROP TRIGGER/PROCEDURE IF EXISTS` statements / İfadeleri
- ✅ `CREATE OR ALTER` for procedures / Yordamlar için
- ✅ Safe idempotent operations / Güvenli tekrar çalıştırılabilir işlemler

#### 7. **Code Quality / Kod Kalitesi**
- ✅ Schema qualification (`dbo.`) on all objects / Tüm nesnelerde şema nitelemesi
- ✅ Named constraints for better maintainability / Daha iyi bakım için isimlendirilmiş kısıtlar
- ✅ Clear section organization with headers / Başlıklar ile net bölüm organizasyonu
- ✅ Professional commenting standards / Profesyonel yorum standartları
- ✅ Consistent formatting and indentation / Tutarlı biçimlendirme ve girintileme

### 🚀 Quick Start / Hızlı Başlangıç

**Automated Setup / Otomatik Kurulum:**
```powershell
.\run_sql_scripts.ps1
```

**Manual Execution / Manuel Çalıştırma:**
1. `01_CreateTables.sql` - Create database schema / Veritabanı şemasını oluştur
2. `02_InsertData.sql` - Insert sample data / Örnek veri ekle
3. `03_SecurityPermissions.sql` - Configure security (update passwords first!) / Güvenliği yapılandır (önce şifreleri güncelleyin!)
4. `04_StoredProcedures.sql` - Create stored procedures / Saklı yordamlar oluştur
5. `05_Triggers.sql` - Create triggers / Tetikleyiciler oluştur
6. `06_TransactionExample.sql` - (Optional) Test transactions / (İsteğe bağlı) İşlemleri test et

### 📊 Data Statistics / Veri İstatistikleri
- 30 Academic Departments / Akademik Bölüm
- 210 Teachers / Öğretmen
- 401 Students / Öğrenci
- 238 Courses / Ders
- 50 Exams / Sınav
- Plus relationship mappings / Artı ilişki eşlemeleri

### ⚠️ Important Notes / Önemli Notlar
1. **Security**: Replace `[SECURE_PASSWORD_HERE]` with strong passwords before deployment
2. **Güvenlik**: Dağıtımdan önce `[SECURE_PASSWORD_HERE]` ifadesini güçlü şifrelerle değiştirin
3. **Compatibility**: Files now work on all operating systems (no Turkish characters in filenames)
4. **Uyumluluk**: Dosyalar artık tüm işletim sistemlerinde çalışıyor (dosya adlarında Türkçe karakter yok)
5. **Idempotency**: Scripts can be re-run safely without manual cleanup
6. **Tekrar Çalıştırılabilirlik**: Betikler manuel temizlik olmadan güvenle yeniden çalıştırılabilir

---

## Gelişmiş Öğrenci Bilgi Sistemi Veri Tabanı Gereksinimleri

### 1. Proje Kullanıcıları Gereksinimleri ve Yetkileri

Gelişmiş Öğrenci Bilgi Sistemi’nde üç ana kullanıcı türü bulunur: Öğrenciler, Öğretmenler ve Yöneticiler. Her kullanıcı türü, veritabanındaki verilere farklı düzeylerde erişim ve müdahale yetkisine sahiptir.

#### 1.1 Öğrenciler:
- Sadece kendi bilgilerini görüntüleyebilir.
- Devamsızlık kayıtlarını ve sınav sonuçlarını görebilir.
- Ders programına ve sınav takvimine erişebilir.
- Yalnızca okuma yetkisine sahiptir, veri girişi yapamaz.

#### 1.2 Öğretmenler:
- Kendi verdikleri derslerin öğrenci listelerine, devamsızlık kayıtlarına ve sınav sonuçlarına erişebilirler.
- Dersleri için sınav oluşturabilir ve sınav sonuçlarını güncelleyebilirler.
- Öğrencilerin ders içindeki performans durumunu görebilirler.
- Hem okuma hem yazma yetkisine sahiptir.

#### 1.3 Yöneticiler:
- Tüm öğrenci ve öğretmen kayıtlarını yönetme yetkisine sahiptir.
- Yeni dersler oluşturabilir, ders programlarını ve sınavları düzenleyebilir.
- Öğrencilerin ve öğretmenlerin bilgilerini güncelleyebilir veya sistemden çıkarabilirler.
- Veritabanındaki tüm verilere tam erişim (okuma, yazma, güncelleme ve silme) yetkisine sahiptir.

---

### 2. Tablolar ve Varlıkların Özellikleri

Her tablo, veritabanındaki bir varlık grubunu temsil eder. Bu varlıkların özellikleri (nitelikler), varlıklar arasındaki ilişkiler ve her ilişkideki sayısal kısıtlamalar aşağıda açıklanmıştır:

#### 2.1 Students (Öğrenciler)
- `id`: Birincil anahtar (PK), benzersiz öğrenci kimliği.
- `name`: Öğrenci adı, zorunlu bir metin alanı.
- `surname`: Öğrenci soyadı, zorunlu bir metin alanı.
- `student_number`: Benzersiz öğrenci numarası, her öğrenci için tekil ve zorunlu.
- `department_id`: Öğrencinin bağlı olduğu bölüm (FK, Departments tablosuna bağlı).
- `advisor_id`: Öğrencinin bağlı olduğu danışman.

**İlişkiler:** 
- Bir öğrenci yalnızca bir bölüme (Departments tablosundaki bir satıra) aittir.
- Bir öğrenci birden fazla derse katılabilir ve her derste ayrı devamsızlık kaydı bulunabilir.

#### 2.2 Teachers (Öğretmenler)
- `id`: Birincil anahtar (PK), benzersiz öğretmen kimliği.
- `name`: Öğretmen adı, zorunlu bir metin alanı.
- `surname`: Öğretmen soyadı, zorunlu bir metin alanı.
- `department_id`: Öğretmenin bağlı olduğu bölüm (FK, Departments tablosuna bağlı).

**İlişkiler:**
- Her öğretmen birden fazla derse girebilir ve birden fazla öğrenciye ders verebilir.
- Her öğretmen yalnızca bir bölüme bağlı olabilir.

#### 2.3 Courses (Dersler)
- `id`: Birincil anahtar (PK), benzersiz ders kimliği.
- `course_name`: Dersin adı, örneğin "Matematik", "Fizik" gibi.
- `teacher_id`: Dersi veren öğretmen (FK, Teachers tablosuna bağlı).
- `department_id`: Dersi veren bölüm (FK, Departments tablosuna bağlı).

**İlişkiler:**
- Her ders bir öğretmen tarafından verilir, ancak birden fazla öğrenci katılabilir.
- Bir ders, birden fazla bölüme atanabilir.

#### 2.4 AttendanceRecords (Devamsızlık Kayıtları)
- `id`: Birincil anahtar (PK), benzersiz devamsızlık kaydı kimliği.
- `student_id`: Devamsızlık yapan öğrenci (FK, Students tablosuna bağlı).
- `course_id`: Devamsızlık yapılan ders (FK, Courses tablosuna bağlı).
- `date`: Devamsızlık yapılan tarih.
- `status`: Devamsızlık durumu ("Present", "Absent", "Late", "Excused" gibi değerler alabilir).

**İlişkiler:**
- Her öğrenci, her ders için birden fazla devamsızlık kaydına sahip olabilir.
- Bir öğrenci birçok derste devamsızlık yapabilir ve her ders için devamsızlık kaydı bulunabilir.

#### 2.5 Departments (Bölümler)
- `id`: Birincil anahtar (PK), benzersiz bölüm kimliği.
- `department_name`: Bölüm adı, örneğin "Matematik", "Fizik" gibi.

**İlişkiler:**
- Her bölümde birden fazla öğretmen ve birden fazla ders bulunabilir.

#### 2.6 Exams (Sınavlar)
- `id`: Birincil anahtar (PK), benzersiz sınav kimliği.
- `course_id`: Sınavın yapıldığı ders (FK, Courses tablosuna bağlı).
- `exam_date`: Sınav tarihi.
- `exam_type`: Sınav türü, örneğin "Midterm", "Final", "Quiz".

**İlişkiler:**
- Her ders için birden fazla sınav yapılabilir.
- Her sınav yalnızca bir derse bağlıdır.

#### 2.7 Grades (Sınav Notları)
- `id`: Birincil anahtar (PK), benzersiz sınav sonucu kimliği.
- `student_id`: Sınava giren öğrenci (FK, Students tablosuna bağlı).
- `exam_id`: Sınav kimliği (FK, Exams tablosuna bağlı).
- `score`: Sınav puanı (numerik değer).

**İlişkiler:**
- Her öğrenci, her sınavdan bir sonuç alabilir.
- Bir sınav, birden fazla öğrenci tarafından alınabilir ve her öğrenci bir sınavdan sadece bir sonuç alır.

#### 2.8 Timetable (Ders Programı)
- `id`: Birincil anahtar (PK), benzersiz ders programı kimliği.
- `course_id`: Programda yer alan ders (FK, Courses tablosuna bağlı).
- `day`: Gün, örneğin "Pazartesi".
- `start_time`: Dersin başlangıç saati.
- `end_time`: Dersin bitiş saati.
- `class`: Dersin yapıldığı sınıf.

**İlişkiler:**
- Ders programı, birden fazla ders için düzenlenebilir.
- Her ders programı kaydı belirli bir gün ve saatte yapılır.

---

### 3. İlişkiler ve Sayısal Kısıtlamalar

- **Students → Departments**: Her öğrenci yalnızca bir bölüme atanır (1:1).
- **Students → AttendanceRecords**: Her öğrenci, her ders için devamsızlık kaydı tutabilir (N:M).
- **Courses → Teachers**: Her ders birden fazla öğretmen tarafından verilebilir, her öğretmen birden fazla derse sahip olabilir (N:M).
- **Courses → Departments**: Her ders yalnızca bir bölüme atanır, ancak bir bölümde birden fazla ders olabilir (1:N).
- **Exams → Courses**: Her ders için birden fazla sınav yapılabilir, ancak her sınav yalnızca bir derse bağlıdır (1:N).
- **ExamResults → Students → Exams**: Her öğrenci her sınavdan bir sonuç alabilir, bu nedenle öğrenciler ve sınavlar arasındaki ilişki N:N'dir.

## E-R DİYAGRAMI

![OBS](https://github.com/user-attachments/assets/c02193dd-483a-4295-9d6c-e7c1b7227248)


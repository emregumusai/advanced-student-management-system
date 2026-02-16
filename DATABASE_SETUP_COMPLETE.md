# ✅ Student Management Database - Setup Complete

## 📊 Database Overview

**Database Name:** `StudentManagementDB`  
**Server Instance:** `localhost\SQLEXPRESS`  
**SQL Server Version:** SQL Server 2022 Express

---

## 🎯 What Was Created

### Tables (17 total):
- ✅ **Departments** - University departments (30 departments)
- ✅ **Roles** - User roles (Student, Teacher, Admin)
- ✅ **Teachers** - Teacher information (210 teachers)
- ✅ **Students** - Student information (401 students including test)
- ✅ **Admins** - Administrator information
- ✅ **RolePermissions** - Permission management for roles
- ✅ **Courses** - Course catalog (238 courses)
- ✅ **Classes** - Classroom information
- ✅ **Days** - Day scheduling
- ✅ **Timetables** - Course schedules
- ✅ **Attendances** - Attendance records
- ✅ **Exams** - Exam information
- ✅ **Grades** - Student grades
- ✅ **Logs** - System activity logs
- ✅ **StudentAttendances** - Student-Attendance relationships
- ✅ **CourseDepartments** - Course-Department relationships
- ✅ **CourseTeachers** - Course-Teacher relationships

### Database Objects:
- ✅ **Stored Procedure:** `RegisterStudent` - Registers new students with validation
- ✅ **Trigger:** `trg_Student_Delete` - Logs student deletions automatically
- ✅ **Roles & Permissions:** Student, Teacher, and Admin roles with appropriate permissions
- ✅ **Sample Users:** 
  - `student1` (password: student)
  - `teacher1` (password: teacher)
  - `admin1` (password: admin)

---

## 🔌 Connection Information

### Connection String:
```
Server=localhost\SQLEXPRESS;Database=StudentManagementDB;Integrated Security=true;TrustServerCertificate=true;
```

### SQL Server Management Studio (SSMS):
- **Server name:** `localhost\SQLEXPRESS`
- **Authentication:** Windows Authentication
- **Database:** StudentManagementDB

### Using PowerShell:
```powershell
$conn = New-Object System.Data.SqlClient.SqlConnection(
    "Server=localhost\SQLEXPRESS;Database=StudentManagementDB;Integrated Security=true;TrustServerCertificate=true;"
)
$conn.Open()
# Your queries here...
$conn.Close()
```

---

## 📈 Database Statistics

| Entity | Count |
|--------|-------|
| Students | 401 |
| Teachers | 210 |
| Courses | 238 |
| Departments | 30 |

---

## 🔧 Available Operations

### 1. Register a New Student (Using Stored Procedure):
```sql
EXEC RegisterStudent 
    @StudentNo='220260999', 
    @Name='Ahmet', 
    @Surname='Yılmaz', 
    @DepartmentID=1, 
    @AdvisorID=1;
```

### 2. View All Students:
```sql
SELECT * FROM Students;
```

### 3. View Student with Department and Advisor:
```sql
SELECT 
    s.StudentNo,
    s.Name,
    s.Surname,
    d.DepartmentName,
    t.Name + ' ' + t.Surname AS AdvisorName
FROM Students s
INNER JOIN Departments d ON s.DepartmentID = d.ID
LEFT JOIN Teachers t ON s.AdvisorID = t.ID;
```

### 4. View Course Schedule:
```sql
SELECT 
    c.CourseName,
    t.Name + ' ' + t.Surname AS TeacherName,
    d.DepartmentName,
    dy.DayNames,
    tt.StartTime,
    tt.EndTime,
    cl.ClassName
FROM Timetables tt
INNER JOIN Courses c ON tt.CourseID = c.ID
INNER JOIN Days dy ON tt.DayID = dy.ID
INNER JOIN Classes cl ON tt.ClassID = cl.ID
INNER JOIN CourseDepartments cd ON c.ID = cd.CourseID
INNER JOIN Departments d ON cd.DepartmentID = d.ID
INNER JOIN CourseTeachers ct ON c.ID = ct.CourseID
INNER JOIN Teachers t ON ct.TeacherID = t.ID;
```

### 5. View Student Grades:
```sql
SELECT 
    s.StudentNo,
    s.Name + ' ' + s.Surname AS StudentName,
    c.CourseName,
    e.ExamType,
    g.Score
FROM Grades g
INNER JOIN Students s ON g.StudentID = s.ID
INNER JOIN Exams e ON g.ExamID = e.ID
INNER JOIN Courses c ON e.CourseID = c.ID
ORDER BY s.StudentNo, c.CourseName;
```

---

## 🛠️ Useful Scripts

### Re-run All Scripts:
```powershell
cd C:\Users\emreg\Downloads\OBS-main
.\run_sql_scripts.ps1
```

### Check Database Status:
```powershell
Get-Service MSSQL$SQLEXPRESS
```

### Start SQL Server (if stopped):
```powershell
Start-Service MSSQL$SQLEXPRESS
```

### Stop SQL Server:
```powershell
Stop-Service MSSQL$SQLEXPRESS
```

---

## 📚 Role-Based Access Control

### StudentRole Permissions:
- ✅ SELECT on: Students, Timetables, Exams, Attendances, Grades

### TeacherRole Permissions:
- ✅ SELECT, INSERT, UPDATE on: Courses, Attendances, Grades
- ✅ SELECT on: Students

### AdminRole Permissions:
- ✅ Full access (SELECT, INSERT, UPDATE, DELETE, ALTER) on all tables

---

## 🚨 Note on Transaction Script

The transaction script (`6.transaction.sql`) intentionally fails to demonstrate **ROLLBACK** functionality. It tries to insert an invalid grade (105/100) to show error handling. This is expected behavior for educational purposes.

---

## 📖 Additional Resources

### Install SQL Server Management Studio (SSMS):
Download from: https://aka.ms/ssmsfullsetup

### SQL Server Documentation:
https://learn.microsoft.com/en-us/sql/

---

## ✨ Next Steps

1. **Install SSMS** (optional but recommended for GUI management)
2. **Connect to database** using the connection info above
3. **Explore the data** using the sample queries provided
4. **Test the stored procedures** and triggers
5. **Develop your application** using the database

---

**Database created on:** ${Get-Date}
**Status:** ✅ Ready for use

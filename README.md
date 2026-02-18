<div align="center">

# Advanced Student Management System

</div>

<div align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

**Enterprise-grade database system with Role-Based Access Control, bilingual documentation, and professional SQL design patterns.**

[Features](#-features) • [Quick Start](#-quick-start) • [Architecture](#-architecture) • [Documentation](#-documentation)

</div>

---

## 🌟 Overview

A comprehensive Student Information System (SIS) built with SQL Server, featuring advanced database design patterns, transaction management, and enterprise-level security implementations. This system demonstrates professional-grade SQL development with bilingual documentation for international teams.

### 🎯 Key Highlights

- **Role-Based Access Control (RBAC)** - Three-tier security model (Student, Teacher, Admin)
- **Bilingual Documentation** - Complete English/Turkish inline comments
- **Transaction Safety** - ACID-compliant with comprehensive error handling
- **Idempotent Scripts** - Safe re-execution without data corruption
- **Rich Sample Data** - 400+ students, 210+ teachers, realistic relationships
- **Security Best Practices** - Password policies, parameterized queries, audit logging
- **Automated Deployment** - One-command PowerShell setup scripts

---

## ✨ Features

### Core Functionality

| Feature | Description |
|---------|-------------|
| **Student Management** | Comprehensive student records with department assignments and advisor relationships |
| **Course Management** | Complex course structures with teacher assignments and scheduling |
| **Attendance Tracking** | Detailed attendance records with multiple status types (Present, Absent, Late, Excused) |
| **Grade Management** | Exam creation, grading system with validation (0-100 range) |
| **Audit Logging** | Automatic trigger-based audit trail for critical operations |
| **User Authentication** | SQL Server authentication with role-based permissions |

### Technical Features

- ✅ **PascalCase Naming Convention** - Consistent, professional database object naming
- ✅ **Named Constraints** - All FK/PK constraints explicitly named for maintainability
- ✅ **Schema Qualification** - Full `dbo.` prefixes throughout
- ✅ **Stored Procedures** - Parameterized operations with return codes
- ✅ **Triggers** - AFTER DELETE triggers for audit trails
- ✅ **Transaction Management** - TRY/CATCH blocks with automatic rollback
- ✅ **Data Validation** - Check constraints and business rule enforcement

---

## 🏗️ Architecture

### Database Schema

**17 Core Tables** organized into logical groups:

#### Core Entities
- **Students** - Student records with departmental affiliations
- **Teachers** - Faculty records with department assignments
- **Departments** - Academic department hierarchy
- **Courses** - Course catalog with credits and prerequisites

#### Relationship Tables
- **StudentCourses** - Many-to-many student enrollment
- **TeacherCourses** - Course-instructor assignments
- **DepartmentCourses** - Department-course relationships

#### Activity Tables
- **Attendances** - Daily attendance records
- **Exams** - Examination schedules and types
- **Grades** - Student exam results
- **Timetables** - Weekly course schedules

#### System Tables
- **Roles** - User role definitions
- **RolePermissions** - Permission mappings
- **Admins** - System administrator accounts
- **Logs** - Audit trail records

### Entity Relationship Diagram

```
Students ──< StudentCourses >── Courses ──< TeacherCourses >── Teachers
    │                              │                               │
    │                              │                               │
    └─── Departments ──────────────┴───────────────────────────────┘
    │                              │
    │                              │
    └─── Attendances               └─── Exams ──< Grades
```

---

## 🚀 Quick Start

### Prerequisites

- **SQL Server 2019+** (Express/Developer/Enterprise)
- **PowerShell 5.1+**
- **Windows Authentication** or SQL Server authentication

### Installation

#### Option 1: Automated Setup (Recommended)

```powershell
# Clone the repository
git clone https://github.com/yourusername/advanced-student-management-system.git
cd advanced-student-management-system

# Run automated setup
.\run_sql_scripts.ps1
```

#### Option 2: Manual Setup

```powershell
# Step 1: Create database and tables
sqlcmd -S localhost\SQLEXPRESS -E -i obs_sql\01_CreateTables.sql

# Step 2: Insert sample data
sqlcmd -S localhost\SQLEXPRESS -E -i obs_sql\02_InsertData.sql

# Step 3: Configure security (update passwords first!)
sqlcmd -S localhost\SQLEXPRESS -E -i obs_sql\03_SecurityPermissions.sql

# Step 4: Create stored procedures
sqlcmd -S localhost\SQLEXPRESS -E -i obs_sql\04_StoredProcedures.sql

# Step 5: Create triggers
sqlcmd -S localhost\SQLEXPRESS -E -i obs_sql\05_Triggers.sql

# Step 6: (Optional) Test transaction management
sqlcmd -S localhost\SQLEXPRESS -E -i obs_sql\06_TransactionExample.sql
```

### Configuration

**Security Configuration Required**

Before deployment, update passwords in `03_SecurityPermissions.sql`:

```sql
-- Replace placeholders with strong passwords
CREATE LOGIN student1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]';
CREATE LOGIN teacher1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]';
CREATE LOGIN admin1 WITH PASSWORD = '[SECURE_PASSWORD_HERE]';
```

**Password Requirements:**
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers, and symbols
- Never use default passwords in production

---

## 📁 Project Structure

```
advanced-student-management-system/
│
├── obs_sql/                          # SQL Scripts
│   ├── 01_CreateTables.sql          # Database schema creation
│   ├── 02_InsertData.sql            # Sample data insertion (wrapped in transaction)
│   ├── 03_SecurityPermissions.sql   # RBAC setup (roles, logins, permissions)
│   ├── 04_StoredProcedures.sql      # RegisterStudent procedure with validation
│   ├── 05_Triggers.sql              # Audit trail trigger (student deletion)
│   └── 06_TransactionExample.sql    # Transaction management demonstration
│
├── run_sql_scripts.ps1              # Automated setup script
├── database_operations.ps1          # Database utility functions
├── .gitignore                       # Git ignore patterns
├── README.md                        # This file
└──LICENSE                          # MIT License
```

---

## 💻 Usage Examples

### Register a New Student

```sql
DECLARE @ReturnCode INT;

EXEC @ReturnCode = RegisterStudent 
    @StudentNo = '220260999',
    @Name = 'John',
    @Surname = 'Smith',
    @DepartmentID = 1,
    @AdvisorID = 5;

-- Return Codes:
-- 0 = Success
-- -1 = Invalid department
-- -2 = Invalid advisor
-- -3 = Duplicate student number
-- -99 = Unexpected error
```

### Query Student Information

```sql
-- Get student with their department and advisor
SELECT 
    s.StudentNo,
    s.Name + ' ' + s.Surname AS FullName,
    d.DepartmentName,
    t.Name + ' ' + t.Surname AS AdvisorName
FROM Students s
INNER JOIN Departments d ON s.DepartmentID = d.ID
INNER JOIN Teachers t ON s.AdvisorID = t.ID
WHERE s.StudentNo = '220260001';
```

### Check Attendance Rate

```sql
-- Calculate student attendance percentage
SELECT 
    s.Name + ' ' + s.Surname AS Student,
    c.CourseName,
    COUNT(*) AS TotalClasses,
    SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
    CAST(SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttendanceRate
FROM Attendances a
INNER JOIN Students s ON a.StudentID = s.ID
INNER JOIN Courses c ON a.CourseID = c.ID
WHERE s.StudentNo = '220260001'
GROUP BY s.Name, s.Surname, c.CourseName;
```

---

## 📊 Sample Data

The database includes realistic sample data for testing and demonstration:

| Entity | Count | Description |
|--------|-------|-------------|
| **Students** | 400 | Distributed across 30 departments |
| **Teachers** | 210 | With department assignments |
| **Courses** | 239 | Various credit hours and course types |
| **Departments** | 30 | Academic departments |
| **Exams** | 51 | Midterms, finals, quizzes |
| **Grades** | 51 | Sample exam results |
| **Attendances** | 600+ | Various attendance statuses |

---

## 🔒 Security Model

### Role Hierarchy

```
AdminRole
    ├── Full CRUD access on all tables
    ├── User management capabilities
    └── System configuration

TeacherRole
    ├── READ: All student/course data
    ├── WRITE: Grades, Exams, Attendances
    └── UPDATE: Own course information

StudentRole
    ├── READ: Own records only
    │   ├── Grades
    │   ├── Attendances
    │   ├── Timetables
    │   └── Course information
    └── No WRITE permissions
```

### Audit Logging

All critical operations are automatically logged:

- **Student Deletion**: `trg_Student_Delete` trigger logs to `Logs` table
- **Timestamp**: Automatic GETDATE() on all log entries
- **User Tracking**: UserType, UserID, Action, Description fields

---

## 🛠️ Technical Specifications

### Technologies

- **Database**: Microsoft SQL Server 2019+
- **Scripting**: PowerShell 5.1+
- **Authentication**: Windows Authentication / SQL Server Authentication
- **Character Encoding**: UTF-8 with bilingual support

### Design Patterns

- **Idempotency**: All scripts use `DROP IF EXISTS` and `CREATE OR ALTER`
- **Transaction Management**: ACID compliance with TRY/CATCH blocks
- **Error Handling**: Comprehensive error logging with RAISERROR/THROW
- **Naming Conventions**: PascalCase for all database objects
- **Schema Qualification**: Explicit `dbo.` prefixes throughout

### Performance Considerations

- **Indexes**: Primary keys on all ID columns (auto-indexed)
- **Foreign Keys**: Named constraints for query optimization
- **Batch Processing**: GO statements for proper batch separation
- **Connection Pooling**: Supports connection reuse in PowerShell scripts

---

## 📚 Documentation

### File Documentation

Each SQL file includes comprehensive bilingual documentation:

```sql
/*******************************************************************************
 * File: 01_CreateTables.sql
 * Purpose: Creates all database tables with proper schema
 * 
 * Author: Yunus Emre Gümüş
 * Date Created: February 16, 2026
 * 
 * Description:
 *   Defines the complete database schema with 17 tables...
 * 
 * Açıklama:
 *   17 tablo ile tam veritabanı şemasını tanımlar...
 ******************************************************************************/
```

### Inline Comments

All code includes bilingual inline comments:

```sql
-- Create database users from logins / Oturum açma bilgilerinden veritabanı kullanıcıları oluştur
CREATE USER student1 FOR LOGIN student1;
```

---

## 🧪 Testing

### Automated Tests

Run the test suite:

```powershell
# Test all components
.\run_sql_scripts.ps1

# Verify installation
sqlcmd -S localhost\SQLEXPRESS -E -Q "USE StudentManagementDB; SELECT COUNT(*) AS Tables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';"
```

### Manual Testing

Test stored procedures:

```sql
-- Test successful registration
EXEC RegisterStudent '999999999', 'Test', 'User', 1, 1;

-- Test duplicate prevention
EXEC RegisterStudent '999999999', 'Test', 'User', 1, 1; -- Returns -3

-- Test invalid department
EXEC RegisterStudent '999999998', 'Test', 'User', 9999, 1; -- Returns -1
```

Test triggers:

```sql
-- Create a test student
INSERT INTO Students (StudentNo, Name, Surname, DepartmentID, AdvisorID, RoleID)
VALUES ('888888888', 'Trigger', 'Test', 1, 1, 1);

-- Delete and check audit log
DELETE FROM Students WHERE StudentNo = '888888888';

-- Verify audit trail
SELECT * FROM Logs WHERE Description LIKE '%Trigger Test%';
```

---

## 🤝 Contributing

Contributions are welcome! This project demonstrates professional SQL development practices and welcomes improvements.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow PascalCase naming conventions
- Add bilingual comments (English/Turkish) for all major sections
- Ensure idempotency in all scripts
- Include comprehensive error handling
- Update documentation for new features

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Yunus Emre Gümüş**

- GitHub: [@emregumusai](https://github.com/emregumusai)
- LinkedIn: [emregumusai](https://linkedin.com/in/emregumusai)

---

## 🌟 Acknowledgments

- Built with enterprise-grade SQL Server best practices
- Inspired by real-world student information systems
- Implements patterns from Microsoft SQL Server documentation

---

## 📞 Support

If you have any questions or run into issues, please:

1. Check the [documentation](#-documentation)
2. Review the [Quick Start](#-quick-start) guide
3. Open an [issue](https://github.com/emregumusai/advanced-student-management-system/issues)

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

Made with using SQL Server and PowerShell

</div>

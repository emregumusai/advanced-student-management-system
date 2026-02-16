# Quick Database Operations Script
# Run this script for common database operations

# Connection Setup
$ServerInstance = "localhost\SQLEXPRESS"
$DatabaseName = "StudentManagementDB"
$ConnectionString = "Server=$ServerInstance;Database=$DatabaseName;Integrated Security=true;TrustServerCertificate=true;"

function Execute-Query {
    param([string]$Query)
    
    $conn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $Query
    
    try {
        $reader = $cmd.ExecuteReader()
        $table = New-Object System.Data.DataTable
        $table.Load($reader)
        $reader.Close()
        $conn.Close()
        return $table
    }
    catch {
        $conn.Close()
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host " Student Management Database" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. View all students" -ForegroundColor Green
    Write-Host "2. View all teachers" -ForegroundColor Green
    Write-Host "3. View all courses" -ForegroundColor Green
    Write-Host "4. View all departments" -ForegroundColor Green
    Write-Host "5. View student grades" -ForegroundColor Green
    Write-Host "6. View course schedule" -ForegroundColor Green
    Write-Host "7. Register new student" -ForegroundColor Yellow
    Write-Host "8. View database statistics" -ForegroundColor Magenta
    Write-Host "9. View recent logs" -ForegroundColor Magenta
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host ""
}

function View-Students {
    Write-Host "`nLoading students..." -ForegroundColor Cyan
    $query = @"
SELECT TOP 20
    s.ID,
    s.StudentNo,
    s.Name,
    s.Surname,
    d.DepartmentName,
    t.Name + ' ' + t.Surname AS AdvisorName
FROM Students s
INNER JOIN Departments d ON s.DepartmentID = d.ID
LEFT JOIN Teachers t ON s.AdvisorID = t.ID
ORDER BY s.StudentNo;
"@
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
}

function View-Teachers {
    Write-Host "`nLoading teachers..." -ForegroundColor Cyan
    $query = @"
SELECT TOP 20
    t.ID,
    t.Name,
    t.Surname,
    d.DepartmentName
FROM Teachers t
INNER JOIN Departments d ON t.DepartmentID = d.ID
ORDER BY d.DepartmentName, t.Surname;
"@
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
}

function View-Courses {
    Write-Host "`nLoading courses..." -ForegroundColor Cyan
    $query = @"
SELECT TOP 20
    c.ID,
    c.CourseName,
    c.GradeLevel
FROM Courses c
ORDER BY c.CourseName;
"@
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
}

function View-Departments {
    Write-Host "`nLoading departments..." -ForegroundColor Cyan
    $query = "SELECT * FROM Departments ORDER BY DepartmentName;"
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
}

function View-Grades {
    Write-Host "`nLoading student grades..." -ForegroundColor Cyan
    $query = @"
SELECT TOP 20
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
"@
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
}

function View-Schedule {
    Write-Host "`nLoading course schedule..." -ForegroundColor Cyan
    $query = @"
SELECT TOP 20
    c.CourseName,
    dy.DayNames AS Day,
    CAST(tt.StartTime AS TIME) AS StartTime,
    CAST(tt.EndTime AS TIME) AS EndTime,
    cl.ClassName AS Class
FROM Timetables tt
INNER JOIN Courses c ON tt.CourseID = c.ID
INNER JOIN Days dy ON tt.DayID = dy.ID
INNER JOIN Classes cl ON tt.ClassID = cl.ID
ORDER BY dy.ID, tt.StartTime;
"@
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
}

function Register-NewStudent {
    Write-Host "`n=== Register New Student ===" -ForegroundColor Yellow
    $studentNo = Read-Host "Student Number"
    $name = Read-Host "First Name"
    $surname = Read-Host "Last Name"
    $deptId = Read-Host "Department ID"
    $advisorId = Read-Host "Advisor (Teacher) ID"
    
    $query = @"
EXEC RegisterStudent 
    @StudentNo='$studentNo', 
    @Name='$name', 
    @Surname='$surname', 
    @DepartmentID=$deptId, 
    @AdvisorID=$advisorId;
"@
    
    $conn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    try {
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $query
        $cmd.ExecuteNonQuery() | Out-Null
        $conn.Close()
        Write-Host "Student registered successfully!" -ForegroundColor Green
    }
    catch {
        $conn.Close()
        Write-Host "Error: $_" -ForegroundColor Red
    }
    
    Read-Host "`nPress Enter to continue"
}

function View-Statistics {
    Write-Host "`nDatabase Statistics:" -ForegroundColor Cyan
    
    $queries = @{
        "Students" = "SELECT COUNT(*) AS Count FROM Students"
        "Teachers" = "SELECT COUNT(*) AS Count FROM Teachers"
        "Courses" = "SELECT COUNT(*) AS Count FROM Courses"
        "Departments" = "SELECT COUNT(*) AS Count FROM Departments"
        "Exams" = "SELECT COUNT(*) AS Count FROM Exams"
        "Grades" = "SELECT COUNT(*) AS Count FROM Grades"
    }
    
    foreach ($item in $queries.GetEnumerator()) {
        $result = Execute-Query -Query $item.Value
        if ($result) {
            Write-Host "  $($item.Key): $($result.Count)" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function View-Logs {
    Write-Host "`nRecent System Logs:" -ForegroundColor Cyan
    $query = @"
SELECT TOP 10
    UserType,
    UserID,
    Action,
    Description,
    Timestamp
FROM Logs
ORDER BY Timestamp DESC;
"@
    $result = Execute-Query -Query $query
    if ($result) {
        $result | Format-Table -AutoSize
    }
    Read-Host "`nPress Enter to continue"
}

# Main Loop
do {
    Show-Menu
    $choice = Read-Host "Select an option"
    
    switch ($choice) {
        "1" { View-Students; Read-Host "`nPress Enter to continue" }
        "2" { View-Teachers; Read-Host "`nPress Enter to continue" }
        "3" { View-Courses; Read-Host "`nPress Enter to continue" }
        "4" { View-Departments; Read-Host "`nPress Enter to continue" }
        "5" { View-Grades; Read-Host "`nPress Enter to continue" }
        "6" { View-Schedule; Read-Host "`nPress Enter to continue" }
        "7" { Register-NewStudent }
        "8" { View-Statistics }
        "9" { View-Logs }
        "0" { Write-Host "`nGoodbye!" -ForegroundColor Cyan; break }
        default { Write-Host "`nInvalid option!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")

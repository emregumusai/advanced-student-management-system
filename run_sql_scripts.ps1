# SQL Server Connection Parameters
$ServerInstance = "localhost\SQLEXPRESS"
$DatabaseName = "StudentManagementDB"
$UseWindowsAuth = $true

# Connection String
if ($UseWindowsAuth) {
    $ConnectionString = "Server=$ServerInstance;Integrated Security=true;TrustServerCertificate=true;"
    $DbConnectionString = "Server=$ServerInstance;Database=$DatabaseName;Integrated Security=true;TrustServerCertificate=true;"
} else {
    $Username = "sa"
    $Password = "YourPassword"
    $ConnectionString = "Server=$ServerInstance;User Id=$Username;Password=$Password;TrustServerCertificate=true;"
    $DbConnectionString = "Server=$ServerInstance;Database=$DatabaseName;User Id=$Username;Password=$Password;TrustServerCertificate=true;"
}

function Execute-SqlQuery {
    param (
        [string]$Query,
        [string]$ConnString
    )
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnString)
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandText = $Query
        $command.CommandTimeout = 120
        
        $result = $command.ExecuteNonQuery()
        $connection.Close()
        
        return $true
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
        if ($connection.State -eq 'Open') {
            $connection.Close()
        }
        return $false
    }
}

function Execute-SqlFile {
    param (
        [string]$FilePath,
        [string]$ConnString
    )
    
    Write-Host "Executing: $FilePath" -ForegroundColor Cyan
    
    try {
        $sqlContent = Get-Content -Path $FilePath -Raw -Encoding UTF8
        
        # Split by GO statements
        $batches = $sqlContent -split '\r?\nGO\r?\n'
        
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnString)
        $connection.Open()
        
        foreach ($batch in $batches) {
            $batch = $batch.Trim()
            if ($batch -ne "") {
                $command = $connection.CreateCommand()
                $command.CommandText = $batch
                $command.CommandTimeout = 120
                
                try {
                    $command.ExecuteNonQuery() | Out-Null
                }
                catch {
                    Write-Host "  Error in batch: $_" -ForegroundColor Red
                    throw
                }
            }
        }
        
        $connection.Close()
        Write-Host "  Success!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  Failed: $_" -ForegroundColor Red
        if ($connection -and $connection.State -eq 'Open') {
            $connection.Close()
        }
        return $false
    }
}

# Main Execution
Write-Host "=== SQL Server Database Setup ===" -ForegroundColor Yellow
Write-Host "Server: $ServerInstance" -ForegroundColor Yellow
Write-Host "Database: $DatabaseName" -ForegroundColor Yellow
Write-Host ""

# Step 1: Create Database
Write-Host "Step 1: Creating database..." -ForegroundColor Cyan
$createDbQuery = "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$DatabaseName') CREATE DATABASE [$DatabaseName]"
if (Execute-SqlQuery -Query $createDbQuery -ConnString $ConnectionString) {
    Write-Host "  Database created/verified successfully!" -ForegroundColor Green
} else {
    Write-Host "  Failed to create database. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Execute SQL Files in order
# Updated file names: Professional English naming convention for portability
# Güncellenmiş dosya adları: Taşınabilirlik için profesyonel İngilizce adlandırma
$sqlFiles = @(
    "obs_sql\01_CreateTables.sql",
    "obs_sql\02_InsertData.sql",
    "obs_sql\03_SecurityPermissions.sql",
    "obs_sql\04_StoredProcedures.sql",
    "obs_sql\05_Triggers.sql",
    "obs_sql\06_TransactionExample.sql"
)

$step = 2
foreach ($sqlFile in $sqlFiles) {
    $fullPath = Join-Path $PSScriptRoot $sqlFile
    
    if (Test-Path $fullPath) {
        Write-Host "Step $step`: Executing $(Split-Path $sqlFile -Leaf)" -ForegroundColor Cyan
        if (Execute-SqlFile -FilePath $fullPath -ConnString $DbConnectionString) {
            Write-Host ""
        } else {
            Write-Host "Failed to execute $sqlFile. Stopping." -ForegroundColor Red
            exit 1
        }
        $step++
    } else {
        Write-Host "File not found: $fullPath" -ForegroundColor Red
    }
}

Write-Host "=== All scripts executed successfully! ===" -ForegroundColor Green
Write-Host "Database: $DatabaseName is ready to use." -ForegroundColor Green

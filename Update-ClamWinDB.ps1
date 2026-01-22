# ClamWin Database Updater Script
# Downloads ClamAV database files when ClamWin cannot update automatically

param(
    [string]$TargetPath = "C:\ProgramData\.clamwin\db",
    [string]$MirrorUrl = ""
)

# ClamAV mirror URLs (will try in order if primary fails)
$MirrorUrls = @(
    "https://database.clamav.net",
    "http://database.clamav.net",
    "http://db.it.clamav.net"
)

# User-Agent strings to try (some CDNs are picky)
$UserAgents = @(
    'ClamAV/1.0',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Wget/1.21.3'
)

# Files to download (mirrors.dat is optional - ClamWin may not require it)
$FilesToDownload = @(
    "bytecode.cvd",
    "daily.cvd",
    "main.cvd",
    "mirrors.dat"
)

# Files that are required (non-optional)
$RequiredFiles = @(
    "bytecode.cvd",
    "daily.cvd",
    "main.cvd"
)

# Function to download file with progress and fallback mirrors
function Download-File {
    param(
        [string[]]$MirrorUrls,
        [string[]]$UserAgents,
        [string]$Destination,
        [string]$FileName
    )
    
    $FullPath = Join-Path -Path $Destination -ChildPath $FileName
    
    Write-Host "Downloading $FileName..." -ForegroundColor Cyan
    
    foreach ($MirrorUrl in $MirrorUrls) {
        $FileUrl = "$MirrorUrl/$FileName"
        Write-Host "  Trying: $FileUrl" -ForegroundColor Gray
        
        # Try each User-Agent
        foreach ($UserAgent in $UserAgents) {
            try {
                # Method 1: Try with Invoke-WebRequest
                $ProgressPreference = 'Continue'
                $Headers = @{
                    'User-Agent' = $UserAgent
                }
                
                # Try Invoke-WebRequest first
                try {
                    Invoke-WebRequest -Uri $FileUrl -OutFile $FullPath -UseBasicParsing -ErrorAction Stop -TimeoutSec 30 -Headers $Headers
                }
                catch {
                    # If Invoke-WebRequest fails, try WebClient
                    $webClient = New-Object System.Net.WebClient
                    $webClient.Headers.Add('User-Agent', $UserAgent)
                    $webClient.DownloadFile($FileUrl, $FullPath)
                    $webClient.Dispose()
                }
                
                if (Test-Path $FullPath) {
                    $FileSize = (Get-Item $FullPath).Length
                    if ($FileSize -gt 0) {
                        $FileSizeMB = [math]::Round($FileSize/1MB, 2)
                        Write-Host "  [OK] Successfully downloaded $FileName ($FileSizeMB MB)" -ForegroundColor Green
                        return $true
                    } else {
                        Write-Host "  [X] Downloaded file is empty, trying next..." -ForegroundColor Yellow
                        Remove-Item $FullPath -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            catch {
                # Only show error if this was the last User-Agent to try
                if ($UserAgent -eq $UserAgents[-1]) {
                    Write-Host "  [X] Failed: $($_.Exception.Message)" -ForegroundColor Gray
                }
                if (Test-Path $FullPath) {
                    Remove-Item $FullPath -Force -ErrorAction SilentlyContinue
                }
                continue
            }
        }
    }
    
    Write-Host "  [X] Failed to download $FileName from all mirrors" -ForegroundColor Red
    return $false
}

# Main execution
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "ClamWin Database Updater" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Check if running as Administrator (may be needed for ProgramData)
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "Warning: Not running as Administrator. May need elevated privileges for C:\ProgramData" -ForegroundColor Yellow
    Write-Host ""
}

# Create target directory if it doesn't exist
if (-not (Test-Path $TargetPath)) {
    Write-Host "Creating directory: $TargetPath" -ForegroundColor Cyan
    try {
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
        Write-Host "  [OK] Directory created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  [X] Failed to create directory: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Please run this script as Administrator or check permissions." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Target directory exists: $TargetPath" -ForegroundColor Green
}

Write-Host ""

# Determine which mirrors to use
$MirrorsToUse = if ($MirrorUrl) { @($MirrorUrl) } else { $MirrorUrls }
Write-Host "Using mirrors: $($MirrorsToUse -join ', ')" -ForegroundColor Cyan
Write-Host ""

$SuccessCount = 0
$FailCount = 0

# Download each file
foreach ($File in $FilesToDownload) {
    $Result = Download-File -MirrorUrls $MirrorsToUse -UserAgents $UserAgents -Destination $TargetPath -FileName $File
    
    if ($Result) {
        $SuccessCount++
    } else {
        $FailCount++
    }
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Download Summary" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

# Check if all required files were downloaded
$RequiredFailed = 0
foreach ($RequiredFile in $RequiredFiles) {
    $RequiredPath = Join-Path -Path $TargetPath -ChildPath $RequiredFile
    if (-not (Test-Path $RequiredPath)) {
        $RequiredFailed++
    }
}

if ($RequiredFailed -eq 0) {
    Write-Host "[OK] All required database files downloaded successfully!" -ForegroundColor Green
    if ($FailCount -gt 0) {
        Write-Host "Note: mirrors.dat failed to download but is optional." -ForegroundColor Yellow
    }
    Write-Host "ClamWin database has been updated." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[X] Some required files failed to download. Please check your internet connection and try again." -ForegroundColor Red
    exit 1
}

@echo off
REM ClamWin Database Updater - Windows Batch Wrapper
REM This batch file runs the Python updater script with elevated privileges

echo ================================================
echo ClamWin Database Updater
echo ================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH.
    echo.
    echo Please install Python 3.x from https://www.python.org/
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)

echo Running ClamWin database updater...
echo This may take a few minutes depending on your internet connection.
echo.

REM Run the Python script
python "%~dp0clamwin_updater.py" %*

echo.
echo ================================================
echo Update process completed.
echo ================================================
pause

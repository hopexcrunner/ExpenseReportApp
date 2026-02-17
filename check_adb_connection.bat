@echo off
REM ADB Conflict Resolution Helper for Windows
REM Detects if Android Studio's adb is running and provides solutions

echo ================================================
echo ADB Conflict Detection Tool
echo ================================================
echo.

REM Check if adb is available
where adb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] adb not found in PATH
    echo.
    echo Solutions:
    echo 1. Use Android Studio's Terminal ^(easiest^)
    echo 2. Install Android SDK Platform Tools
    echo 3. Add adb to your PATH
    echo.
    echo See ANDROID_STUDIO_ADB_CONFLICT.md for details
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('where adb') do set ADB_PATH=%%i
echo [SUCCESS] adb found: %ADB_PATH%
echo.

REM Check device connection
echo Checking for connected devices...
adb devices > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] adb server not responding
    echo.
    echo Attempting to start adb server...
    adb start-server
    timeout /t 2 /nobreak >nul
)

REM Count connected devices
set DEVICE_COUNT=0
for /f "tokens=2" %%a in ('adb devices ^| find "device"') do set /a DEVICE_COUNT+=1

echo.
if %DEVICE_COUNT% EQU 0 (
    echo [ERROR] No devices detected
    echo.
    
    REM Check if port 5037 is in use
    netstat -an | find ":5037" | find "LISTENING" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [INFO] Port 5037 is in use ^(adb server running^)
        echo.
        echo Possible causes:
        echo 1. Android Studio is running with its own adb
        echo 2. Another adb instance is running
        echo.
        echo [SOLUTION] See ANDROID_STUDIO_ADB_CONFLICT.md
        echo.
        echo Quick fixes:
        echo   Option A: Use Android Studio's Terminal ^(bottom of window^)
        echo   Option B: Close Android Studio, then run: adb kill-server ^&^& adb start-server
        echo   Option C: In Android Studio Terminal, run this script
    ) else (
        echo Common issues:
        echo 1. Device not connected via USB
        echo 2. USB debugging not enabled on device
        echo 3. Didn't accept 'Allow USB debugging' prompt
        echo 4. Android Studio has locked the connection
        echo.
        echo If Android Studio shows your device:
        echo   -^> Use Android Studio's Terminal instead
        echo   -^> See ANDROID_STUDIO_ADB_CONFLICT.md
    )
) else (
    echo [SUCCESS] Device connected successfully!
    echo.
    echo Connected device^(s^):
    adb devices | find "device"
    echo.
    echo You're ready to run the diagnostic script:
    echo   diagnose_crash.bat
)

echo.
echo For more help, see:
echo   - ANDROID_STUDIO_ADB_CONFLICT.md ^(if Android Studio is open^)
echo   - QUICK_START_GUIDE.md ^(general instructions^)
echo   - DEVICE_CONNECTION_GUIDE.md ^(connection troubleshooting^)
echo.
pause

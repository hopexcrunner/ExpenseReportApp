@echo off
REM Device Connection and Crash Log Capture Script for Windows
REM This script helps capture real crash logs from the connected Google Pixel 6a

setlocal EnableDelayedExpansion

echo ================================================
echo ExpenseReportApp - Live Crash Diagnosis Tool
echo ================================================
echo.

REM Check if adb is available
where adb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] adb not found!
    echo.
    echo Please install Android SDK Platform Tools:
    echo 1. Download from: https://developer.android.com/tools/releases/platform-tools
    echo 2. Extract the zip file
    echo 3. Add the folder to your PATH or run this script from that folder
    echo.
    pause
    exit /b 1
)

REM Function to check device connection
:check_device
adb devices 2>nul | find "device" >nul
if %ERRORLEVEL% NEQ 0 (
    exit /b 1
)
exit /b 0

echo Checking for connected device...
echo.

call :check_device
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No device connected
    echo.
    echo Please ensure your Google Pixel 6a is connected via USB and:
    echo 1. USB debugging is enabled ^(Settings ^> Developer options^)
    echo 2. You've accepted the 'Allow USB debugging?' prompt
    echo.
    echo Waiting for device connection...
    echo ^(This will check every 3 seconds. Press Ctrl+C to cancel^)
    echo.
    
    :wait_loop
    timeout /t 3 /nobreak >nul
    echo .
    call :check_device
    if %ERRORLEVEL% NEQ 0 goto wait_loop
    
    echo.
    echo [SUCCESS] Device connected!
    echo.
)

REM Get device info
echo [INFO] Connected Device:
for /f "tokens=*" %%a in ('adb shell getprop ro.product.model 2^>nul') do set DEVICE_MODEL=%%a
for /f "tokens=*" %%a in ('adb shell getprop ro.build.version.release 2^>nul') do set DEVICE_ANDROID=%%a
for /f "tokens=*" %%a in ('adb shell getprop ro.build.version.sdk 2^>nul') do set DEVICE_SDK=%%a
echo    Model: %DEVICE_MODEL%
echo    Android: %DEVICE_ANDROID% ^(API %DEVICE_SDK%^)
echo.

echo What would you like to do?
echo.
echo 1^) Capture crash logs from device ^(if crash already happened^)
echo 2^) Build, install app and monitor logs in real-time
echo 3^) Just install latest APK
echo 4^) Start live monitoring ^(assumes app already installed^)
echo 5^) Clear app data and reinstall
echo 6^) Get current app version info
echo.
set /p choice="Enter choice (1-6): "

if "%choice%"=="1" goto capture_logs
if "%choice%"=="2" goto build_install_monitor
if "%choice%"=="3" goto install_only
if "%choice%"=="4" goto monitor_only
if "%choice%"=="5" goto clear_reinstall
if "%choice%"=="6" goto version_info
echo [ERROR] Invalid choice
goto end

:capture_logs
echo.
echo [INFO] Capturing crash logs...
set OUTPUT_FILE=crash_log_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt
set OUTPUT_FILE=%OUTPUT_FILE: =0%

adb logcat -b crash -d > "%OUTPUT_FILE%" 2>&1
echo. >> "%OUTPUT_FILE%"
echo ========== MAIN LOGCAT ========== >> "%OUTPUT_FILE%"
adb logcat -d | findstr /i "AndroidRuntime FATAL Exception com.avant.expensereport MainActivity" >> "%OUTPUT_FILE%" 2>&1

echo [SUCCESS] Crash logs saved to: %OUTPUT_FILE%
echo.

findstr /i "FATAL" "%OUTPUT_FILE%" >nul
if %ERRORLEVEL% EQU 0 (
    echo [CRASH DETECTED!]
    echo.
    echo ========== CRASH DETAILS ==========
    findstr /i /a "FATAL" "%OUTPUT_FILE%" 
    echo ===================================
    echo.
    echo Full logs saved to: %OUTPUT_FILE%
) else (
    echo [INFO] No crash found in current logs.
    echo To capture crash:
    echo 1. Clear logs: adb logcat -c
    echo 2. Launch app and reproduce crash
    echo 3. Run this script again
)
goto end

:build_install_monitor
echo.
echo [INFO] Building and installing app...
if not exist "gradlew.bat" (
    echo [ERROR] Must run from project root directory
    goto end
)

call gradlew.bat assembleDebug
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    goto end
)

adb install -r app\build\outputs\apk\debug\app-debug.apk
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Installation failed
    goto end
)

echo [SUCCESS] App installed
echo.
set /p launch="Launch app now? (y/n): "
if /i "%launch%"=="y" (
    adb shell am start -n com.avant.expensereport/.MainActivity
    timeout /t 2 /nobreak >nul
)
echo.
echo [INFO] Starting live log monitoring...
echo Press Ctrl+C to stop
echo.
echo Waiting for crash or errors...
echo ===================================
adb logcat -c
adb logcat | findstr /i "FATAL AndroidRuntime Exception Error.*com.avant MainActivity com.avant.expensereport"
goto end

:install_only
echo.
echo [INFO] Building and installing app...
if not exist "gradlew.bat" (
    echo [ERROR] Must run from project root directory
    goto end
)

call gradlew.bat assembleDebug
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    goto end
)

adb install -r app\build\outputs\apk\debug\app-debug.apk
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Installation failed
    goto end
)

echo [SUCCESS] App installed
goto end

:monitor_only
echo.
echo [INFO] Starting live log monitoring...
echo Press Ctrl+C to stop
echo.
echo Waiting for crash or errors...
echo ===================================
adb logcat -c
adb logcat | findstr /i "FATAL AndroidRuntime Exception Error.*com.avant MainActivity com.avant.expensereport"
goto end

:clear_reinstall
echo.
echo [INFO] Clearing app data...
adb shell pm clear com.avant.expensereport
echo [INFO] Building and installing app...
if not exist "gradlew.bat" (
    echo [ERROR] Must run from project root directory
    goto end
)

call gradlew.bat assembleDebug
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    goto end
)

adb install -r app\build\outputs\apk\debug\app-debug.apk
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Installation failed
    goto end
)

echo [SUCCESS] App data cleared and fresh install complete
goto end

:version_info
echo.
echo [INFO] App Information:
adb shell dumpsys package com.avant.expensereport | findstr /i "versionName versionCode firstInstallTime lastUpdateTime"
if %ERRORLEVEL% NEQ 0 echo App not installed
goto end

:end
echo.
echo Done!
pause

@echo off
REM Automated APK Build Script for Windows
REM Avant Expense Report App

echo =========================================
echo Avant Expense Report App - APK Builder
echo =========================================
echo.

REM Check if we're in the right directory
if not exist "settings.gradle.kts" (
    echo ERROR: Must run from ExpenseReportApp root directory
    echo Usage: cd ExpenseReportApp ^&^& build_apk.bat
    pause
    exit /b 1
)

echo Checking prerequisites...
echo.

REM Check Java
java -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java not found. Please install JDK 8 or higher
    echo Download from: https://www.oracle.com/java/technologies/downloads/
    pause
    exit /b 1
)

echo Java found
java -version
echo.

REM Check Android SDK
if "%ANDROID_HOME%"=="" (
    echo WARNING: ANDROID_HOME not set
    echo.
    echo Please install Android Studio and set ANDROID_HOME
    echo Download from: https://developer.android.com/studio
    echo.
    echo Or set ANDROID_HOME to your Android SDK location:
    echo Example: set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
    pause
    exit /b 1
)

echo Android SDK: %ANDROID_HOME%
echo.

REM Clean previous builds
echo Cleaning previous builds...
call gradlew.bat clean

REM Build debug APK
echo.
echo Building debug APK...
echo This may take a few minutes on first run...
echo.

call gradlew.bat assembleDebug

REM Check if build succeeded
if exist "app\build\outputs\apk\debug\app-debug.apk" (
    echo.
    echo =========================================
    echo BUILD SUCCESSFUL!
    echo =========================================
    echo.
    echo APK Location:
    echo   app\build\outputs\apk\debug\app-debug.apk
    echo.
    
    REM Copy to easy location
    copy "app\build\outputs\apk\debug\app-debug.apk" "AvantExpenseReport.apk"
    echo Copied to: AvantExpenseReport.apk
    echo.
    
    echo Installation Options:
    echo.
    echo Option 1 - USB Install:
    echo   1. Connect Android device via USB
    echo   2. Enable USB debugging
    echo   3. Run: adb install AvantExpenseReport.apk
    echo.
    echo Option 2 - Email/Cloud:
    echo   1. Email AvantExpenseReport.apk to yourself
    echo   2. Open on Android device and install
    echo.
    
) else (
    echo.
    echo =========================================
    echo BUILD FAILED
    echo =========================================
    echo.
    echo Check the error messages above for details.
    echo.
)

pause

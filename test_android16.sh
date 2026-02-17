#!/bin/bash

# Android 16 Testing Script for ExpenseReportApp
# This script helps test the app on a connected Google Pixel 6a

set -e

echo "======================================"
echo "ExpenseReportApp - Android 16 Testing"
echo "======================================"
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb not found. Please install Android SDK platform tools."
    exit 1
fi

# Check device connection
echo "📱 Checking device connection..."
DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No device connected. Please connect your Google Pixel 6a via USB."
    exit 1
fi
echo "✅ Device connected"
echo ""

# Get device info
echo "📋 Device Information:"
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
echo ""

# Ask user what to do
echo "What would you like to do?"
echo "1) Build and install APK"
echo "2) Clear app data and reinstall"
echo "3) Start monitoring logs (real-time)"
echo "4) View last crash log"
echo "5) Test app (install, clear data, and monitor logs)"
echo ""
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo "🔨 Building APK..."
        ./gradlew assembleDebug
        echo "📦 Installing APK..."
        adb install -r app/build/outputs/apk/debug/app-debug.apk
        echo "✅ Installation complete!"
        ;;
    2)
        echo "🧹 Clearing app data..."
        adb shell pm clear com.avant.expensereport
        echo "🔨 Building APK..."
        ./gradlew assembleDebug
        echo "📦 Installing APK..."
        adb install -r app/build/outputs/apk/debug/app-debug.apk
        echo "✅ Complete! Launch the app manually."
        ;;
    3)
        echo "📊 Starting log monitor... (Press Ctrl+C to stop)"
        echo "Looking for: MainActivity, crashes, and exceptions"
        echo ""
        adb logcat -c  # Clear old logs
        adb logcat | grep --color=always -E "MainActivity|FATAL|AndroidRuntime|Exception|com.avant.expensereport"
        ;;
    4)
        echo "💥 Last crash log:"
        echo ""
        adb logcat -b crash -d | tail -100
        ;;
    5)
        echo "🚀 Full test sequence starting..."
        echo ""
        
        echo "Step 1/5: Building APK..."
        ./gradlew assembleDebug
        
        echo "Step 2/5: Clearing old app data..."
        adb shell pm clear com.avant.expensereport 2>/dev/null || true
        
        echo "Step 3/5: Installing APK..."
        adb install -r app/build/outputs/apk/debug/app-debug.apk
        
        echo "Step 4/5: Granting camera permission..."
        adb shell pm grant com.avant.expensereport android.permission.CAMERA
        
        echo "Step 5/5: Starting log monitor and launching app..."
        echo ""
        echo "📊 Monitoring logs... (Press Ctrl+C to stop)"
        echo "==========================================="
        
        # Clear logs and start monitoring
        adb logcat -c
        
        # Launch app
        adb shell am start -n com.avant.expensereport/.MainActivity
        
        # Monitor logs
        adb logcat | grep --color=always -E "MainActivity|FATAL|AndroidRuntime|Exception|com.avant.expensereport"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

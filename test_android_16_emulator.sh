#!/bin/bash
# Emulator Test Script for Pixel 6a (Android 16)
# This script sets up and tests the ExpenseReportApp on an Android 16 emulator

set -e

echo "======================================================================"
echo "ExpenseReportApp - Pixel 6a Android 16 Emulator Test"
echo "======================================================================"
echo ""

# Configuration
export ANDROID_SDK_ROOT="/usr/local/lib/android/sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

AVD_NAME="Pixel_6a_API_36"
PACKAGE_NAME="com.avant.expensereport"
APK_PATH="${1:-app-debug.apk}"

echo "📋 Configuration:"
echo "  AVD Name: $AVD_NAME"
echo "  Package: $PACKAGE_NAME"
echo "  APK: $APK_PATH"
echo ""

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK not found at $APK_PATH"
    echo ""
    echo "Please download the APK from GitHub Actions:"
    echo "1. Go to: https://github.com/hopexcrunner/ExpenseReportApp/actions"
    echo "2. Click on latest successful 'Build and Test Android APK' run"
    echo "3. Download 'AvantExpenseReport-APK' artifact"
    echo "4. Extract app-debug.apk"
    echo "5. Run: $0 path/to/app-debug.apk"
    echo ""
    exit 1
fi

echo "✅ APK found: $APK_PATH ($(du -h "$APK_PATH" | cut -f1))"
echo ""

# Check if AVD exists
echo "🔍 Checking for AVD: $AVD_NAME"
if ! avdmanager list avd | grep -q "$AVD_NAME"; then
    echo "⚠️  AVD not found. Creating Pixel 6a emulator with Android 16..."
    echo ""
    
    # Check if system image is available
    if [ ! -d "$ANDROID_SDK_ROOT/system-images/android-36" ]; then
        echo "📥 Downloading Android 16 system image..."
        sdkmanager "system-images;android-36;google_apis;x86_64" || {
            echo "❌ Failed to download system image"
            echo "You may need to run: sdkmanager --licenses"
            exit 1
        }
    fi
    
    # Create AVD
    echo "no" | avdmanager create avd \
        --name "$AVD_NAME" \
        --package "system-images;android-36;google_apis;x86_64" \
        --device "pixel_6a" \
        --sdcard 512M \
        --force || {
        echo "⚠️  Pixel 6a device profile not found, trying pixel_6..."
        echo "no" | avdmanager create avd \
            --name "$AVD_NAME" \
            --package "system-images;android-36;google_apis;x86_64" \
            --device "pixel_6" \
            --sdcard 512M \
            --force
    }
    
    echo "✅ AVD created successfully"
else
    echo "✅ AVD found"
fi
echo ""

# Start emulator
echo "🚀 Starting Pixel 6a emulator (Android 16)..."
echo "   This may take 1-2 minutes..."
echo ""

# Check if emulator is already running
if adb devices | grep -q "emulator"; then
    echo "✅ Emulator already running"
else
    # Start emulator in background
    emulator -avd "$AVD_NAME" -no-window -no-audio -gpu swiftshader_indirect > /tmp/emulator.log 2>&1 &
    EMULATOR_PID=$!
    
    echo "⏳ Waiting for emulator to boot..."
    adb wait-for-device
    
    # Wait for system to be fully ready
    echo "⏳ Waiting for system to be ready..."
    sleep 10
    
    # Check if fully booted
    timeout=60
    elapsed=0
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
        if [ $elapsed -ge $timeout ]; then
            echo "❌ Emulator failed to boot within $timeout seconds"
            cat /tmp/emulator.log | tail -50
            exit 1
        fi
        echo "   Still booting... ($elapsed/$timeout seconds)"
        sleep 5
        elapsed=$((elapsed + 5))
    done
fi

echo "✅ Emulator ready!"
echo ""

# Get device info
echo "📱 Device Information:"
adb shell getprop | grep -E "ro.build.version.sdk|ro.product.model|ro.build.version.release" | while read line; do
    echo "   $line"
done
echo ""

# Uninstall old version if exists
echo "🧹 Cleaning old installation..."
adb uninstall "$PACKAGE_NAME" 2>/dev/null && echo "   Removed old version" || echo "   No previous installation"
echo ""

# Install APK
echo "📲 Installing APK..."
if adb install -r "$APK_PATH"; then
    echo "✅ APK installed successfully"
else
    echo "❌ Failed to install APK"
    adb logcat -d *:E | tail -30
    exit 1
fi
echo ""

# Grant permissions
echo "🔐 Granting permissions..."
adb shell pm grant "$PACKAGE_NAME" android.permission.CAMERA 2>/dev/null && echo "   ✅ CAMERA granted" || echo "   ⚠️  CAMERA already granted"
adb shell pm grant "$PACKAGE_NAME" android.permission.READ_EXTERNAL_STORAGE 2>/dev/null && echo "   ✅ READ_EXTERNAL_STORAGE granted" || echo "   ℹ️  READ_EXTERNAL_STORAGE not needed/granted"
adb shell pm grant "$PACKAGE_NAME" android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null && echo "   ✅ WRITE_EXTERNAL_STORAGE granted" || echo "   ℹ️  WRITE_EXTERNAL_STORAGE not needed/granted"
adb shell pm grant "$PACKAGE_NAME" android.permission.READ_MEDIA_IMAGES 2>/dev/null && echo "   ✅ READ_MEDIA_IMAGES granted" || echo "   ℹ️  READ_MEDIA_IMAGES not needed/granted"
echo ""

# Launch app
echo "🚀 Launching app..."
adb shell am start -n "$PACKAGE_NAME/.MainActivity"
sleep 5
echo ""

# Check if app is running
echo "🔍 Checking app status..."
if adb shell pidof "$PACKAGE_NAME" > /dev/null; then
    echo "✅ App is running!"
    PID=$(adb shell pidof "$PACKAGE_NAME")
    echo "   Process ID: $PID"
else
    echo "❌ App failed to start. Checking logs..."
    echo ""
    echo "Last 30 error log lines:"
    adb logcat -d *:E | tail -30
    exit 1
fi
echo ""

# Take screenshot
echo "📸 Capturing screenshot..."
mkdir -p ./screenshots
SCREENSHOT_FILE="./screenshots/app_launch_$(date +%Y%m%d_%H%M%S).png"
adb exec-out screencap -p > "$SCREENSHOT_FILE" 2>/dev/null || {
    adb shell screencap -p /sdcard/screenshot.png
    adb pull /sdcard/screenshot.png "$SCREENSHOT_FILE" > /dev/null
    adb shell rm /sdcard/screenshot.png
}
echo "✅ Screenshot saved: $SCREENSHOT_FILE"
echo ""

# Get app info
echo "📊 App Information:"
adb shell dumpsys package "$PACKAGE_NAME" | grep -E "versionName|versionCode|targetSdk|minSdk" | head -5 | while read line; do
    echo "   $line"
done
echo ""

# Monitor app for a few seconds
echo "📋 Monitoring app logs (10 seconds)..."
timeout 10 adb logcat -s "ExpenseReport:*" -s "AndroidRuntime:E" 2>/dev/null || true
echo ""

# Memory usage
echo "💾 Memory Usage:"
adb shell dumpsys meminfo "$PACKAGE_NAME" | grep -A 10 "App Summary" | while read line; do
    echo "   $line"
done
echo ""

# Final status
echo "======================================================================"
echo "✅ TEST COMPLETE"
echo "======================================================================"
echo ""
echo "📱 Emulator: Pixel 6a (Android 16, API 36)"
echo "📦 Package: $PACKAGE_NAME"
echo "📸 Screenshot: $SCREENSHOT_FILE"
echo ""

# Display image if possible
if command -v display &> /dev/null; then
    echo "🖼️  Opening screenshot..."
    display "$SCREENSHOT_FILE" &
elif command -v xdg-open &> /dev/null; then
    xdg-open "$SCREENSHOT_FILE" &
fi

echo "🔧 Emulator Commands:"
echo "   View logs:    adb logcat"
echo "   Shell access: adb shell"
echo "   Restart app:  adb shell am start -n $PACKAGE_NAME/.MainActivity"
echo "   Uninstall:    adb uninstall $PACKAGE_NAME"
echo "   Stop emulator: adb emu kill"
echo ""

echo "📝 Test Summary:"
echo "   ✅ Emulator started"
echo "   ✅ APK installed"
echo "   ✅ Permissions granted"
echo "   ✅ App launched"
echo "   ✅ Screenshot captured"
echo ""

echo "🎯 Next Steps:"
echo "   1. Review screenshot to verify UI"
echo "   2. Test camera capture functionality"
echo "   3. Test OCR with sample receipt"
echo "   4. Test Excel report generation"
echo "   5. Test email draft creation"
echo ""

echo "⏹️  To stop the emulator, run: adb emu kill"
echo ""

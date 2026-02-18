#!/bin/bash
# Automated Test Script for ExpenseReportApp on Pixel 6a Emulator (Android 16)
# Usage: ./test_emulator.sh [path/to/app-debug.apk]

set -e  # Exit on error

echo "========================================="
echo "ExpenseReportApp - Emulator Test Suite"
echo "Testing on Pixel 6a with Android 16"
echo "========================================="
echo ""

# Configuration
APK_PATH="${1:-app/build/outputs/apk/debug/app-debug.apk}"
AVD_NAME="Pixel_6a_API_36"
PACKAGE_NAME="com.avant.expensereport"
ACTIVITY_NAME=".MainActivity"
SCREENSHOTS_DIR="./test_screenshots"

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK not found at $APK_PATH"
    echo ""
    echo "Please provide the APK path:"
    echo "  ./test_emulator.sh path/to/app-debug.apk"
    echo ""
    echo "Or build via GitHub Actions and download the artifact."
    exit 1
fi

echo "✅ APK found: $APK_PATH"
echo ""

# Set up SDK environment
export ANDROID_HOME=${ANDROID_HOME:-/usr/local/lib/android/sdk}
export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-$ANDROID_HOME}
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Check for required tools
echo "📋 Checking prerequisites..."

if ! command -v adb &> /dev/null; then
    echo "❌ adb not found. Please install Android SDK platform-tools"
    exit 1
fi

if ! command -v emulator &> /dev/null; then
    echo "❌ emulator not found. Please install Android SDK emulator"
    exit 1
fi

echo "✅ Android SDK tools found"
echo ""

# Check if AVD exists
echo "🔍 Checking for AVD: $AVD_NAME"
if ! avdmanager list avd | grep -q "$AVD_NAME"; then
    echo "⚠️  AVD '$AVD_NAME' not found"
    echo ""
    echo "Creating Pixel 6a emulator with Android 16..."
    
    # Check if system image is installed
    if [ ! -d "$ANDROID_HOME/system-images/android-36" ]; then
        echo "📥 Installing Android 16 system image..."
        sdkmanager "system-images;android-36;google_apis;x86_64" || {
            echo "❌ Failed to install system image"
            echo "You may need to install it manually:"
            echo "  sdkmanager \"system-images;android-36;google_apis;x86_64\""
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
echo "🚀 Starting emulator..."
echo "This may take 1-2 minutes..."
echo ""

# Check if emulator is already running
if adb devices | grep -q "emulator"; then
    echo "✅ Emulator already running"
else
    # Start emulator in background
    emulator -avd "$AVD_NAME" -no-window -no-audio -gpu swiftshader_indirect > /dev/null 2>&1 &
    EMULATOR_PID=$!
    
    # Wait for device
    echo "⏳ Waiting for emulator to boot..."
    adb wait-for-device
    
    # Wait for system to be ready
    echo "⏳ Waiting for system to be ready..."
    sleep 10
    
    # Check if fully booted
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
        echo "   Still booting..."
        sleep 5
    done
fi

echo "✅ Emulator is ready!"
echo ""

# Create screenshots directory
mkdir -p "$SCREENSHOTS_DIR"

# Uninstall old version if exists
echo "🧹 Cleaning old installation..."
adb uninstall "$PACKAGE_NAME" 2>/dev/null || echo "   No previous installation found"
echo ""

# Install APK
echo "📲 Installing APK..."
if adb install -r "$APK_PATH"; then
    echo "✅ APK installed successfully"
else
    echo "❌ Failed to install APK"
    exit 1
fi
echo ""

# Grant permissions
echo "🔐 Granting permissions..."
adb shell pm grant "$PACKAGE_NAME" android.permission.CAMERA 2>/dev/null || echo "   Camera permission already granted"
adb shell pm grant "$PACKAGE_NAME" android.permission.READ_EXTERNAL_STORAGE 2>/dev/null || echo "   Storage read permission already granted"
adb shell pm grant "$PACKAGE_NAME" android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null || echo "   Storage write permission already granted"
adb shell pm grant "$PACKAGE_NAME" android.permission.READ_MEDIA_IMAGES 2>/dev/null || echo "   Media images permission not needed/already granted"
echo "✅ Permissions granted"
echo ""

# Push sample receipt if exists
if [ -f "sample_receipt.jpg" ]; then
    echo "📸 Pushing sample receipt to device..."
    adb push sample_receipt.jpg /sdcard/DCIM/Camera/test_receipt.jpg > /dev/null
    echo "✅ Sample receipt uploaded"
    echo ""
fi

# Launch app
echo "🚀 Launching app..."
adb shell am start -n "$PACKAGE_NAME/$ACTIVITY_NAME"
sleep 3

# Take initial screenshot
echo "📸 Capturing screenshot..."
adb exec-out screencap -p > "$SCREENSHOTS_DIR/01_app_launched.png" 2>/dev/null || {
    adb shell screencap -p /sdcard/screenshot.png
    adb pull /sdcard/screenshot.png "$SCREENSHOTS_DIR/01_app_launched.png" > /dev/null
    adb shell rm /sdcard/screenshot.png
}
echo "✅ Screenshot saved: $SCREENSHOTS_DIR/01_app_launched.png"
echo ""

# Check if app is running
echo "🔍 Checking app status..."
if adb shell pidof "$PACKAGE_NAME" > /dev/null; then
    echo "✅ App is running!"
else
    echo "⚠️  App may have crashed. Checking logs..."
    echo ""
    echo "Last 20 error log lines:"
    adb logcat -d *:E | tail -20
    exit 1
fi
echo ""

# Monitor logs for a few seconds
echo "📋 Monitoring app logs (5 seconds)..."
timeout 5 adb logcat | grep -i "$PACKAGE_NAME\|AndroidRuntime" || true
echo ""

# Get app info
echo "📊 App Information:"
adb shell dumpsys package "$PACKAGE_NAME" | grep -E "versionName|versionCode|targetSdk" | head -3
echo ""

# Final status check
echo "========================================="
echo "✅ TEST COMPLETE"
echo "========================================="
echo ""
echo "📱 Emulator: $AVD_NAME (Android 16, API 36)"
echo "📦 APK: $APK_PATH"
echo "🖼️  Screenshots: $SCREENSHOTS_DIR/"
echo ""
echo "🔧 Emulator is still running. To interact:"
echo "   adb shell                    # Shell access"
echo "   adb logcat                   # View logs"
echo "   adb exec-out screencap -p > screenshot.png  # Take screenshot"
echo ""
echo "⏹️  To stop emulator:"
echo "   adb emu kill"
echo ""
echo "📝 Test Results Summary:"
echo "   ✅ Emulator created/started successfully"
echo "   ✅ APK installed without errors"
echo "   ✅ Permissions granted"
echo "   ✅ App launched successfully"
echo "   ✅ App is running without crashes"
echo "   ✅ Screenshot captured"
echo ""
echo "🎯 Next Steps:"
echo "   1. Review screenshot in $SCREENSHOTS_DIR/"
echo "   2. Interact with app via emulator"
echo "   3. Test camera capture functionality"
echo "   4. Test OCR with sample receipt"
echo "   5. Verify Excel report generation"
echo "   6. Check email draft creation"
echo ""

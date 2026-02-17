#!/bin/bash
# Automated APK Build Script for Avant Expense Report App
# This script builds a debug APK that can be installed directly on Android devices

set -e  # Exit on error

echo "========================================="
echo "Avant Expense Report App - APK Builder"
echo "========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "settings.gradle.kts" ]; then
    echo "❌ Error: Must run from ExpenseReportApp root directory"
    echo "Usage: cd ExpenseReportApp && ./build_apk.sh"
    exit 1
fi

# Check for required tools
echo "📋 Checking prerequisites..."

if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Please install JDK 8 or higher"
    exit 1
fi

echo "✅ Java found: $(java -version 2>&1 | head -n 1)"

# Check Android SDK
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "⚠️  ANDROID_HOME not set. Attempting to find Android SDK..."
    
    # Common locations
    POSSIBLE_LOCATIONS=(
        "$HOME/Android/Sdk"
        "$HOME/Library/Android/sdk"
        "/usr/local/android-sdk"
    )
    
    for location in "${POSSIBLE_LOCATIONS[@]}"; do
        if [ -d "$location" ]; then
            export ANDROID_HOME="$location"
            export ANDROID_SDK_ROOT="$location"
            echo "✅ Found Android SDK at: $ANDROID_HOME"
            break
        fi
    done
    
    if [ -z "$ANDROID_HOME" ]; then
        echo "❌ Android SDK not found. Please install Android Studio or set ANDROID_HOME"
        echo ""
        echo "Install Android Studio from: https://developer.android.com/studio"
        exit 1
    fi
fi

echo "✅ Android SDK: $ANDROID_HOME"
echo ""

# Make gradlew executable
chmod +x gradlew

# Clean previous builds
echo "🧹 Cleaning previous builds..."
./gradlew clean

# Build debug APK
echo ""
echo "🔨 Building debug APK..."
echo "This may take a few minutes on first run..."
echo ""

./gradlew assembleDebug

# Check if build succeeded
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "========================================="
    echo "✅ BUILD SUCCESSFUL!"
    echo "========================================="
    echo ""
    echo "📱 APK Location:"
    echo "   app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    
    # Get file size
    SIZE=$(ls -lh app/build/outputs/apk/debug/app-debug.apk | awk '{print $5}')
    echo "📊 APK Size: $SIZE"
    echo ""
    
    # Copy to easy-to-find location
    cp app/build/outputs/apk/debug/app-debug.apk ./AvantExpenseReport.apk
    echo "📋 Copied to: ./AvantExpenseReport.apk"
    echo ""
    
    echo "📲 Installation Options:"
    echo ""
    echo "Option 1 - USB Install (Recommended):"
    echo "  1. Connect Android device via USB"
    echo "  2. Enable USB debugging on device"
    echo "  3. Run: adb install AvantExpenseReport.apk"
    echo ""
    echo "Option 2 - Email/Cloud:"
    echo "  1. Email AvantExpenseReport.apk to yourself"
    echo "  2. Open on Android device"
    echo "  3. Tap to install (may need to allow 'Unknown Sources')"
    echo ""
    echo "Option 3 - Direct Copy:"
    echo "  1. Copy AvantExpenseReport.apk to device via USB"
    echo "  2. Use file manager to open and install"
    echo ""
    
else
    echo ""
    echo "========================================="
    echo "❌ BUILD FAILED"
    echo "========================================="
    echo ""
    echo "Check the error messages above for details."
    echo ""
    exit 1
fi

#!/bin/bash

# Device Connection and Crash Log Capture Script
# This script helps capture real crash logs from the connected Google Pixel 6a

set -e

echo "================================================"
echo "ExpenseReportApp - Live Crash Diagnosis Tool"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check device connection
check_device() {
    DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device$" | wc -l)
    if [ "$DEVICE_COUNT" -eq 0 ]; then
        return 1
    fi
    return 0
}

# Function to get device info
get_device_info() {
    echo -e "${GREEN}📱 Connected Device:${NC}"
    DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_ANDROID=$(adb shell getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    DEVICE_SDK=$(adb shell getprop ro.build.version.sdk 2>/dev/null || echo "Unknown")
    echo "   Model: $DEVICE_MODEL"
    echo "   Android: $DEVICE_ANDROID (API $DEVICE_SDK)"
    echo ""
}

# Function to capture crash logs
capture_crash_logs() {
    local OUTPUT_FILE="crash_log_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${YELLOW}📝 Capturing crash logs...${NC}"
    
    # Get crash buffer
    adb logcat -b crash -d > "$OUTPUT_FILE" 2>&1
    
    # Get main logcat with relevant filters
    echo "" >> "$OUTPUT_FILE"
    echo "========== MAIN LOGCAT ==========" >> "$OUTPUT_FILE"
    adb logcat -d | grep -E "AndroidRuntime|FATAL|Exception|com.avant.expensereport|MainActivity" >> "$OUTPUT_FILE" 2>&1 || true
    
    echo -e "${GREEN}✅ Crash logs saved to: $OUTPUT_FILE${NC}"
    echo ""
    
    # Display the crash if found
    if grep -q "FATAL EXCEPTION" "$OUTPUT_FILE"; then
        echo -e "${RED}💥 CRASH DETECTED!${NC}"
        echo ""
        echo "========== CRASH DETAILS =========="
        grep -A 50 "FATAL EXCEPTION" "$OUTPUT_FILE" | head -50
        echo "==================================="
        echo ""
        echo -e "${YELLOW}Full logs saved to: $OUTPUT_FILE${NC}"
    else
        echo -e "${GREEN}No crash found in current logs.${NC}"
        echo "To capture crash:"
        echo "1. Clear logs: adb logcat -c"
        echo "2. Launch app and reproduce crash"
        echo "3. Run this script again"
    fi
}

# Function to install app
install_app() {
    echo -e "${YELLOW}📦 Building and installing app...${NC}"
    
    if [ ! -f "./gradlew" ]; then
        echo -e "${RED}❌ Error: Must run from project root directory${NC}"
        exit 1
    fi
    
    ./gradlew assembleDebug || {
        echo -e "${RED}❌ Build failed${NC}"
        exit 1
    }
    
    adb install -r app/build/outputs/apk/debug/app-debug.apk || {
        echo -e "${RED}❌ Installation failed${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✅ App installed${NC}"
}

# Function to start live monitoring
live_monitor() {
    echo -e "${YELLOW}📊 Starting live log monitoring...${NC}"
    echo "Press Ctrl+C to stop"
    echo ""
    echo "Waiting for crash or errors..."
    echo "==================================="
    
    adb logcat -c  # Clear old logs
    adb logcat | grep --line-buffered --color=always -E "FATAL|AndroidRuntime|Exception|Error.*com.avant|MainActivity|com.avant.expensereport"
}

# Main menu
echo "Checking for connected device..."
echo ""

if ! check_device; then
    echo -e "${RED}❌ No device connected${NC}"
    echo ""
    echo "Please ensure your Google Pixel 6a is connected via USB and:"
    echo "1. USB debugging is enabled (Settings > Developer options)"
    echo "2. You've accepted the 'Allow USB debugging?' prompt"
    echo ""
    echo "Waiting for device connection..."
    echo "(This will check every 3 seconds. Press Ctrl+C to cancel)"
    echo ""
    
    # Wait for device
    while ! check_device; do
        sleep 3
        echo -n "."
    done
    echo ""
    echo -e "${GREEN}✅ Device connected!${NC}"
    echo ""
fi

get_device_info

echo "What would you like to do?"
echo ""
echo "1) Capture crash logs from device (if crash already happened)"
echo "2) Build, install app and monitor logs in real-time"
echo "3) Just install latest APK"
echo "4) Start live monitoring (assumes app already installed)"
echo "5) Clear app data and reinstall"
echo "6) Get current app version info"
echo ""
read -p "Enter choice (1-6): " choice

case $choice in
    1)
        capture_crash_logs
        ;;
    2)
        install_app
        echo ""
        read -p "Launch app now? (y/n): " launch
        if [ "$launch" = "y" ] || [ "$launch" = "Y" ]; then
            adb shell am start -n com.avant.expensereport/.MainActivity
            sleep 2
        fi
        echo ""
        live_monitor
        ;;
    3)
        install_app
        ;;
    4)
        live_monitor
        ;;
    5)
        echo -e "${YELLOW}🧹 Clearing app data...${NC}"
        adb shell pm clear com.avant.expensereport
        install_app
        echo ""
        echo -e "${GREEN}✅ App data cleared and fresh install complete${NC}"
        ;;
    6)
        echo "📋 App Information:"
        adb shell dumpsys package com.avant.expensereport | grep -E "versionName|versionCode|firstInstallTime|lastUpdateTime" || echo "App not installed"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo "Done!"

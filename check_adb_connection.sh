#!/bin/bash

# ADB Conflict Resolution Helper
# Detects if Android Studio's adb is running and provides solutions

echo "================================================"
echo "ADB Conflict Detection Tool"
echo "================================================"
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ adb not found in PATH"
    echo ""
    echo "Solutions:"
    echo "1. Use Android Studio's Terminal (easiest)"
    echo "2. Install Android SDK Platform Tools"
    echo "3. Add adb to your PATH"
    echo ""
    echo "See ANDROID_STUDIO_ADB_CONFLICT.md for details"
    exit 1
fi

echo "✅ adb found: $(which adb)"
echo ""

# Check if adb server is running
ADB_SERVER_RUNNING=$(adb devices 2>&1 | grep -c "List of devices")

if [ $ADB_SERVER_RUNNING -eq 0 ]; then
    echo "⚠️  adb server not responding"
    echo ""
    echo "Attempting to start adb server..."
    adb start-server
    sleep 2
fi

# Check device connection
echo "Checking for connected devices..."
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device$" | wc -l)

echo ""
if [ $DEVICE_COUNT -eq 0 ]; then
    echo "❌ No devices detected"
    echo ""
    
    # Check if port 5037 is in use (adb default port)
    if lsof -Pi :5037 -sTCP:LISTEN -t &>/dev/null 2>&1 || netstat -an 2>/dev/null | grep -q ":5037.*LISTEN"; then
        echo "🔍 Port 5037 is in use (adb server running)"
        echo ""
        echo "Possible causes:"
        echo "1. Android Studio is running with its own adb"
        echo "2. Another adb instance is running"
        echo ""
        echo "📖 SOLUTION: See ANDROID_STUDIO_ADB_CONFLICT.md"
        echo ""
        echo "Quick fixes:"
        echo "  Option A: Use Android Studio's Terminal (bottom of Android Studio window)"
        echo "  Option B: Close Android Studio, then run: adb kill-server && adb start-server"
        echo "  Option C: In Android Studio Terminal, run this script"
    else
        echo "Common issues:"
        echo "1. Device not connected via USB"
        echo "2. USB debugging not enabled on device"
        echo "3. Didn't accept 'Allow USB debugging' prompt"
        echo "4. Android Studio has locked the connection"
        echo ""
        echo "If Android Studio shows your device:"
        echo "  → Use Android Studio's Terminal instead"
        echo "  → See ANDROID_STUDIO_ADB_CONFLICT.md"
    fi
else
    echo "✅ Device connected successfully!"
    echo ""
    echo "Connected device(s):"
    adb devices | grep -v "List"
    echo ""
    echo "You're ready to run the diagnostic script:"
    echo "  ./diagnose_crash.sh"
fi

echo ""
echo "For more help, see:"
echo "  - ANDROID_STUDIO_ADB_CONFLICT.md (if Android Studio is open)"
echo "  - QUICK_START_GUIDE.md (general instructions)"
echo "  - DEVICE_CONNECTION_GUIDE.md (connection troubleshooting)"

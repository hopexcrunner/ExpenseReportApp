# Real-Time Crash Diagnosis Guide

## Current Status
Your Google Pixel 6a is NOT yet detected by adb. We need to establish connection to get actual crash logs.

## Step-by-Step Device Connection

### 1. Enable USB Debugging (if not already done)
1. Open **Settings** on your Pixel 6a
2. Scroll to **About phone**
3. Tap **Build number** 7 times to enable Developer options
4. Go back to Settings > **System** > **Developer options**
5. Enable **USB debugging**

### 2. Connect Device
1. Connect your Pixel 6a to computer via USB cable
2. On your phone, you should see "Allow USB debugging?" prompt
3. Check "Always allow from this computer"
4. Tap **Allow**

### 3. Verify Connection
On your computer, run:
```bash
adb devices
```

You should see output like:
```
List of devices attached
1234567890ABCDEF    device
```

If you see `unauthorized`, unplug and replug the cable, then accept the prompt again.

### 4. Get Crash Logs

#### Option A: Automated Script (Recommended)
```bash
cd /path/to/ExpenseReportApp
./diagnose_crash.sh
# Choose option 1 to capture existing crash logs
# OR choose option 2 to build, install, and monitor in real-time
```

#### Option B: Manual Commands
```bash
# Clear old logs
adb logcat -c

# Install the app
cd /path/to/ExpenseReportApp
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Start monitoring (in one terminal)
adb logcat | grep -E "FATAL|AndroidRuntime|Exception|MainActivity"

# Launch app (in another terminal)
adb shell am start -n com.avant.expensereport/.MainActivity

# Now capture a receipt and watch for crash in the monitoring terminal
```

## What to Look For in Crash Logs

The crash log will show something like:
```
FATAL EXCEPTION: main
Process: com.avant.expensereport, PID: 12345
java.lang.RuntimeException: [ERROR MESSAGE]
    at com.avant.expensereport.MainActivity.[METHOD_NAME]
    at ...
```

The key information:
1. **Exception type** (e.g., SecurityException, NullPointerException, IllegalStateException)
2. **Line number** where it crashed
3. **Full stack trace**

## Common Android 16 Crash Patterns

Based on your symptoms, likely causes:

### 1. StrictMode Violation (Most Likely)
**Symptom**: Crash immediately after capture
**Log looks like**: `android.os.StrictMode$StrictModeViolation`
**Cause**: Disk I/O on main thread (BitmapFactory.decodeFile)

### 2. ML Kit Issue
**Symptom**: Crash during "Processing receipt..."
**Log looks like**: `com.google.android.gms.common.api.ApiException`
**Cause**: Google Play Services not updated or ML Kit not available

### 3. SecurityException
**Symptom**: Crash when accessing files
**Log looks like**: `java.lang.SecurityException: Permission denial`
**Cause**: Missing permission or invalid FileProvider path

### 4. OutOfMemoryError
**Symptom**: Crash with large images
**Log looks like**: `java.lang.OutOfMemoryError`
**Cause**: Large bitmap consuming too much memory

## Preemptive Fixes

While waiting for device connection, I'm preparing fixes for the most likely issues:

1. **Moving bitmap decoding off main thread**
2. **Adding StrictMode detection and handling**
3. **Adding ML Kit availability check**
4. **Adding bitmap size optimization**

## After Getting Logs

Once you run the diagnostic script and capture the crash:
1. The script will save logs to `crash_log_YYYYMMDD_HHMMSS.txt`
2. Share the "FATAL EXCEPTION" section with me
3. I'll implement the exact fix needed

## Troubleshooting Device Connection

### Device shows as "unauthorized"
```bash
adb kill-server
adb start-server
# Unplug and replug USB cable
# Accept "Allow USB debugging?" on phone
```

### Device not showing at all
- Try different USB port
- Try different USB cable
- Check if device is in "File Transfer" mode (swipe down from top, tap USB notification)
- Install manufacturer USB drivers (though usually not needed for Pixel)

### adb command not found
```bash
# On Linux/Mac
sudo apt-get install android-sdk-platform-tools

# Verify
adb version
```

## Quick Test Without Device

If you can't connect the device right now, you can:
1. Take a screenshot of the exact crash message on your phone
2. Note the exact step where it crashes:
   - [ ] App launches
   - [ ] Camera permission
   - [ ] Camera preview shows
   - [ ] After tapping capture button
   - [ ] While showing "Processing receipt..."
   - [ ] After OCR processing
   - [ ] When creating expense report

This info helps narrow down the issue even without logs.

# Android 16 Crash Fix - Testing Guide

## Problem Fixed
The app was crashing immediately after capturing a receipt on Android 16 (Google Pixel 6a) due to:
1. Deprecated storage permissions (READ_EXTERNAL_STORAGE/WRITE_EXTERNAL_STORAGE)
2. Use of `externalMediaDirs` which requires permissions on Android 13+
3. FileProvider configuration using external-path

## Changes Applied

### 1. Permissions Updated
- Added granular media permissions for Android 13+
- Made legacy permissions Android version-specific
- Camera is now the only required permission on Android 13+

### 2. File Storage Fixed
- Changed to app-specific directories (`getExternalFilesDir()`)
- No storage permissions required for app-specific directories
- Files are stored in: `/Android/data/com.avant.expensereport/files/`

### 3. Better Error Handling
- All exceptions now logged to logcat with stack traces
- Better error messages for debugging

## Testing on Your Google Pixel 6a

### Step 1: Build and Install
```bash
cd /path/to/ExpenseReportApp
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### Step 2: Clear App Data (Important!)
This ensures old permission states don't interfere:
```bash
adb shell pm clear com.avant.expensereport
```

### Step 3: Start Monitoring Logs
Open a terminal and run:
```bash
adb logcat | grep -E "MainActivity|AndroidRuntime|FATAL"
```

### Step 4: Test the App
1. Launch the app
2. Grant camera permission when prompted
3. Capture a receipt
4. Watch the logs for any errors

### Step 5: Check for Crashes
If the app still crashes, the logcat will show:
```
FATAL EXCEPTION: main
```

Look for the stack trace immediately after this line.

## Common Issues and Solutions

### Issue: Camera permission not working
**Solution**: Make sure camera permission is granted:
```bash
adb shell pm grant com.avant.expensereport android.permission.CAMERA
```

### Issue: Files not being created
**Check**: Verify the directory exists and is writable:
```bash
adb shell ls -la /sdcard/Android/data/com.avant.expensereport/files/
```

### Issue: Still seeing storage permission errors
**Solution**: The app should work without storage permissions on Android 16. If you see permission errors, check:
```bash
adb shell dumpsys package com.avant.expensereport | grep permission
```

## Debugging Commands

### Get full logcat since last crash:
```bash
adb logcat -b crash -d
```

### Get app-specific logs:
```bash
adb logcat -s MainActivity:* AndroidRuntime:* System.err:*
```

### Check if app is running:
```bash
adb shell ps | grep expensereport
```

### Force stop and restart:
```bash
adb shell am force-stop com.avant.expensereport
adb shell am start -n com.avant.expensereport/.MainActivity
```

## Expected Behavior After Fix

1. ✅ App launches without crash
2. ✅ Camera permission prompt appears
3. ✅ After granting permission, camera preview shows
4. ✅ Capture button works
5. ✅ Receipt processing starts (shows "Processing receipt...")
6. ✅ OCR extracts text from receipt
7. ✅ Expense report is generated
8. ✅ Email draft opens with attachments

## File Locations

After successful capture, files are stored in:
- **Receipt images**: `/Android/data/com.avant.expensereport/files/ExpenseReportApp/receipt_*.jpg`
- **Expense reports**: `/Android/data/com.avant.expensereport/files/ExpenseReportApp/expense_report_*.xlsx`

You can pull them from the device:
```bash
adb pull /sdcard/Android/data/com.avant.expensereport/files/ExpenseReportApp/ ./
```

## What Was the Original Issue?

The crash was likely one of these:
1. **SecurityException**: Trying to access external storage without proper permissions
2. **NullPointerException**: `externalMediaDirs.firstOrNull()` returning null on Android 16
3. **IllegalStateException**: FileProvider unable to share files from restricted external paths

All of these have been addressed in this fix.

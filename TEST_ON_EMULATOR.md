# Testing ExpenseReportApp on Pixel 6a Emulator (Android 16)

## Current Situation

This document provides instructions for building the APK and testing it on a Pixel 6a emulator running Android 16 (API 36).

### Build Environment Limitation

The current sandboxed development environment has network restrictions that prevent:
- Downloading Android Gradle Plugin from repositories
- Downloading Gradle dependencies
- Direct APK building via `./gradlew assembleDebug`

### ✅ Recommended Build Method: GitHub Actions

The repository includes `.github/workflows/build-apk.yml` which automatically builds the APK in GitHub's cloud environment.

#### To Build via GitHub Actions:

1. **Trigger the workflow**:
   - Push to `main`, `master`, or `copilot/continue-app-development` branch
   - OR manually trigger via GitHub Actions tab → "Build Android APK" → "Run workflow"

2. **Download the APK**:
   - Go to repository → Actions tab
   - Click on the latest successful workflow run
   - Scroll to "Artifacts" section
   - Download "AvantExpenseReport-APK" (will be a ZIP file)
   - Extract to get `app-debug.apk`

## Testing on Pixel 6a Emulator

Once you have the APK, follow these steps to test on a Pixel 6a emulator running Android 16.

### Prerequisites

- Android SDK installed (check: `echo $ANDROID_HOME`)
- Android SDK Command-line tools
- Android Platform API 36 (Android 16)
- System image for Pixel 6a

### Step 1: Install Required SDK Components

```bash
# Set SDK path
export ANDROID_HOME=/usr/local/lib/android/sdk
export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Accept licenses
sdkmanager --licenses

# Install Android 16 (API 36) system image
# For x86_64 (faster on most computers):
sdkmanager "system-images;android-36;google_apis;x86_64"

# OR for ARM64 (more accurate to real device):
sdkmanager "system-images;android-36;google_apis_playstore;arm64-v8a"

# Install platform tools
sdkmanager "platform-tools" "platforms;android-36"
```

### Step 2: Create Pixel 6a Emulator

```bash
# List available device definitions
avdmanager list device

# Create AVD with Pixel 6a specs
avdmanager create avd \
  --name "Pixel_6a_API_36" \
  --package "system-images;android-36;google_apis;x86_64" \
  --device "pixel_6a" \
  --sdcard 512M \
  --force

# If pixel_6a device definition doesn't exist, use pixel_6:
avdmanager create avd \
  --name "Pixel_6a_API_36" \
  --package "system-images;android-36;google_apis;x86_64" \
  --device "pixel_6" \
  --sdcard 512M \
  --force
```

### Step 3: Start the Emulator

```bash
# Start emulator in headless mode (no UI window)
emulator -avd Pixel_6a_API_36 -no-window -no-audio -gpu swiftshader_indirect &

# OR start with UI (if display available)
emulator -avd Pixel_6a_API_36 &

# Wait for emulator to boot
adb wait-for-device
echo "Emulator is ready!"
```

### Step 4: Install and Test the APK

```bash
# Check device is connected
adb devices

# Install the APK
adb install -r app-debug.apk

# Grant necessary permissions
adb shell pm grant com.avant.expensereport android.permission.CAMERA
adb shell pm grant com.avant.expensereport android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.avant.expensereport android.permission.WRITE_EXTERNAL_STORAGE

# Launch the app
adb shell am start -n com.avant.expensereport/.MainActivity

# View logs in real-time
adb logcat | grep "ExpenseReport"
```

### Step 5: Test Scenarios

#### Test 1: App Launch
- [ ] App opens without crashing
- [ ] Camera permission prompt appears
- [ ] Main activity with camera preview loads

#### Test 2: Camera Functionality
- [ ] Camera preview displays correctly
- [ ] "Capture Receipt" button is visible and clickable
- [ ] Can capture a photo

#### Test 3: OCR Processing
- [ ] After capture, "Processing receipt..." message appears
- [ ] Receipt data is extracted and displayed
- [ ] Merchant name, date, and amount are shown

#### Test 4: Excel Report Generation
- [ ] Excel report is created successfully
- [ ] No crashes during file operations
- [ ] Status updates appropriately

#### Test 5: Email Draft Creation
- [ ] Email intent launches
- [ ] Both attachments (receipt image and Excel report) are included
- [ ] Email has correct recipient and subject

### Step 6: Capture Screenshots

```bash
# Take screenshot
adb exec-out screencap -p > screenshot_$(date +%Y%m%d_%H%M%S).png

# Or pull from device
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./test_screenshots/
```

### Step 7: Test with Sample Receipt

```bash
# Push the sample receipt to the emulator
adb push sample_receipt.jpg /sdcard/DCIM/Camera/receipt_test.jpg

# The app should be able to process this receipt
```

## Automated Test Script

A convenience script `test_emulator.sh` is provided for automated testing:

```bash
#!/bin/bash
# Usage: ./test_emulator.sh path/to/app-debug.apk

APK_PATH=$1

# Start emulator
emulator -avd Pixel_6a_API_36 -no-window &
adb wait-for-device
sleep 10

# Install and test
adb install -r "$APK_PATH"
adb shell pm grant com.avant.expensereport android.permission.CAMERA
adb shell pm grant com.avant.expensereport android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.avant.expensereport android.permission.WRITE_EXTERNAL_STORAGE

# Launch app
adb shell am start -n com.avant.expensereport/.MainActivity
sleep 5

# Take screenshot
adb exec-out screencap -p > test_launch_screenshot.png

echo "✅ Test complete! Screenshot saved to test_launch_screenshot.png"
```

## Expected Results

### Successful Test Indicators:
- ✅ App installs without errors
- ✅ App launches and displays camera preview
- ✅ No crashes in logcat
- ✅ Permissions are granted successfully
- ✅ UI elements are visible and responsive
- ✅ OCR processing completes without errors
- ✅ Excel file generation succeeds
- ✅ Email draft can be created

### Known Limitations:
- Camera may not capture actual images in headless mode
- OCR accuracy depends on test image quality
- Email functionality requires email app installed on emulator
- File operations may need storage permissions on newer Android versions

## Troubleshooting

### Emulator won't start
```bash
# Check available system images
sdkmanager --list | grep system-images

# Check AVD configuration
avdmanager list avd

# Delete and recreate AVD
avdmanager delete avd -n Pixel_6a_API_36
# Then recreate as shown in Step 2
```

### APK installation fails
```bash
# Check for existing installation
adb shell pm list packages | grep avant

# Uninstall old version
adb uninstall com.avant.expensereport

# Reinstall
adb install -r app-debug.apk
```

### Permission errors
```bash
# Grant all permissions at once
adb shell pm grant com.avant.expensereport android.permission.CAMERA
adb shell pm grant com.avant.expensereport android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.avant.expensereport android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant com.avant.expensereport android.permission.READ_MEDIA_IMAGES
```

### App crashes
```bash
# View crash logs
adb logcat *:E | grep -A 20 "AndroidRuntime"

# Filter for app-specific logs
adb logcat | grep com.avant.expensereport
```

## Manual Testing with Android Studio

If you prefer GUI testing:

1. Open project in Android Studio
2. Build → Build Bundle(s) / APK(s) → Build APK(s)
3. Tools → AVD Manager → Create Virtual Device
4. Select Pixel 6a
5. Select Android 16 (API 36) system image
6. Finish and launch emulator
7. Run → Run 'app' or drag APK to emulator

## Continuous Integration Testing

The GitHub Actions workflow can be extended to include automated emulator testing:

```yaml
- name: Run instrumented tests
  uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 36
    target: google_apis
    arch: x86_64
    profile: pixel_6a
    script: adb install app/build/outputs/apk/debug/app-debug.apk
```

## Summary

Due to network restrictions in the current environment:
1. ✅ Use GitHub Actions to build the APK (workflow already configured)
2. ✅ Download APK artifact from GitHub Actions run
3. ✅ Follow this guide to test on Pixel 6a emulator with Android 16
4. ✅ Use provided scripts for automation
5. ✅ Capture screenshots and logs for verification

The app should work correctly on Android 16 (API 36) as it targets API 34 with minSdk 24.

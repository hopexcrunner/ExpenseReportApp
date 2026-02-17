# Quick Start: Testing on Pixel 6a Emulator

## TL;DR - Get APK and Test

### Step 1: Get the APK (via GitHub Actions)
1. Go to: https://github.com/hopexcrunner/ExpenseReportApp/actions
2. Click "Build and Test Android APK" workflow
3. Click "Run workflow" → Select branch → "Run workflow"
4. Wait ~5 minutes for build to complete
5. Download "AvantExpenseReport-APK" artifact
6. Extract the ZIP to get `app-debug.apk`

### Step 2: Test Automatically
```bash
cd ExpenseReportApp
./test_emulator.sh path/to/app-debug.apk
```

### Step 3: View Results
- Screenshots: `./test_screenshots/01_app_launched.png`
- Logs: View in terminal output
- Emulator stays running for manual testing

## That's It! 🎉

### What the Script Does:
✅ Creates Pixel 6a emulator with Android 16  
✅ Starts emulator automatically  
✅ Installs the APK  
✅ Grants all permissions  
✅ Launches the app  
✅ Takes screenshot  
✅ Checks for crashes  
✅ Shows summary

### Manual Testing (if needed):
```bash
# The emulator is still running, so you can:
adb shell am start -n com.avant.expensereport/.MainActivity  # Relaunch app
adb shell input tap 540 1200                                  # Simulate tap
adb exec-out screencap -p > screenshot.png                    # Take screenshot
adb logcat | grep ExpenseReport                               # View logs
adb emu kill                                                  # Stop emulator
```

## If You Don't Have the APK Yet

The APK must be built via GitHub Actions because the local environment has network restrictions.

**Option 1: Trigger Build Now**
- Push this branch to GitHub
- GitHub Actions will auto-build
- Download artifact in ~5 minutes

**Option 2: Build Locally (requires Android Studio)**
- Open project in Android Studio
- Build → Build APK
- Find APK in `app/build/outputs/apk/debug/`

## Expected Test Results

✅ **Success Indicators:**
- App installs without errors
- App launches and shows camera preview
- No crashes in logs
- Screenshot shows main activity
- Permissions granted successfully

❌ **If Something Goes Wrong:**
1. Check `./test_screenshots/` for screenshot
2. Review error messages in terminal
3. Check logcat output for crashes
4. See TEST_ON_EMULATOR.md for troubleshooting

## Test Checklist

After running the automated test:

- [ ] Screenshot shows app main screen
- [ ] Camera preview is visible
- [ ] "Capture Receipt" button is visible
- [ ] No error messages in logs
- [ ] App is still running (no crash)

Then manually test:
- [ ] Tap capture button
- [ ] OCR processes receipt
- [ ] Excel report generates
- [ ] Email draft opens

## Full Documentation

For detailed instructions, see:
- **TEST_ON_EMULATOR.md** - Complete testing guide
- **.github/workflows/build-apk.yml** - CI/CD configuration
- **test_emulator.sh** - Automated test script source

## Troubleshooting Quick Fixes

**"AVD not found"**
```bash
# Script will create it automatically, or:
avdmanager create avd -n Pixel_6a_API_36 \
  -k "system-images;android-36;google_apis;x86_64" \
  -d "pixel_6a"
```

**"APK not found"**
```bash
# Build via GitHub Actions first, then:
./test_emulator.sh ~/Downloads/app-debug.apk
```

**"Emulator won't start"**
```bash
# Check what's available:
avdmanager list avd
emulator -list-avds

# Kill existing:
adb emu kill
```

**"App crashes immediately"**
```bash
# View crash logs:
adb logcat *:E | tail -50

# Check our fixes were applied:
git log --oneline -5
```

## Support

- 📚 Full docs: TEST_ON_EMULATOR.md
- 🔧 Script source: test_emulator.sh
- 🚀 CI/CD: .github/workflows/build-apk.yml
- 📋 Issues: GitHub Issues tab

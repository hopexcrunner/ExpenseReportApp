# ExpenseReportApp Testing Workflow

## 🔄 Complete Build and Test Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    1. BUILD APK (GitHub Actions)                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Push to GitHub  │
                    │  or Manual       │
                    │  Trigger         │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ GitHub Actions   │
                    │ Workflow Starts  │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Setup JDK 17    │
                    │  Cache Gradle    │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ ./gradlew        │
                    │ assembleDebug    │
                    │ (~5 minutes)     │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  ✅ APK Built    │
                    │  app-debug.apk   │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Upload as       │
                    │  Artifact        │
                    └──────────────────┘
                              │
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    2. DOWNLOAD APK                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ GitHub Actions   │
                    │ → Actions Tab    │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Latest Workflow  │
                    │ → Artifacts      │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Download ZIP    │
                    │  Extract APK     │
                    └──────────────────┘
                              │
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    3. TEST ON EMULATOR                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────┴─────────────────────┐
        │                                           │
        ▼                                           ▼
┌─────────────────┐                        ┌─────────────────┐
│   AUTOMATED     │                        │     MANUAL      │
│   ./test_       │                        │   Follow        │
│   emulator.sh   │                        │   TEST_ON_      │
│                 │                        │   EMULATOR.md   │
└─────────────────┘                        └─────────────────┘
        │                                           │
        ▼                                           ▼
┌─────────────────┐                        ┌─────────────────┐
│ • Check SDK     │                        │ • Install SDK   │
│ • Create AVD    │                        │ • Create AVD    │
│ • Start Emu     │                        │ • Start Emu     │
│ • Install APK   │                        │ • Install APK   │
│ • Grant Perms   │                        │ • Grant Perms   │
│ • Launch App    │                        │ • Launch App    │
│ • Screenshot    │                        │ • Test Features │
│ • Monitor Logs  │                        │ • Screenshot    │
│ • Report        │                        │ • Verify        │
└─────────────────┘                        └─────────────────┘
        │                                           │
        └─────────────────────┬─────────────────────┘
                              ▼
                    ┌──────────────────┐
                    │  ✅ TEST PASS    │
                    │  Screenshots     │
                    │  in ./test_      │
                    │  screenshots/    │
                    └──────────────────┘
                              │
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    4. REVIEW RESULTS                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ View Screenshots │
                    │ Review Logs      │
                    │ Verify Features  │
                    └──────────────────┘
                              │
                              ▼
            ┌─────────────────┴─────────────────┐
            │                                   │
            ▼                                   ▼
    ┌─────────────┐                    ┌─────────────┐
    │ Issues      │                    │ All Good    │
    │ Found?      │                    │             │
    └─────────────┘                    └─────────────┘
            │                                   │
            ▼                                   ▼
    ┌─────────────┐                    ┌─────────────┐
    │ Fix Issues  │                    │ Deploy to   │
    │ Rebuild     │                    │ Production  │
    │ Retest      │                    │ or Users    │
    └─────────────┘                    └─────────────┘
```

## 🎯 Test Scenarios

### Automated (test_emulator.sh)
```
✅ Emulator Creation
✅ APK Installation  
✅ Permission Granting
✅ App Launch
✅ Crash Detection
✅ Screenshot Capture
✅ Log Monitoring
✅ Status Reporting
```

### Manual (TEST_ON_EMULATOR.md)
```
✅ App Launch
✅ Camera Preview
✅ Capture Receipt
✅ OCR Processing
✅ Data Display
✅ Excel Generation
✅ Email Draft
✅ Attachments
```

## 📊 Emulator Setup

```
Pixel 6a Specification
├── Display: 1080x2400 (FHD+)
├── Android: API 36 (Android 16)
├── Architecture: x86_64
├── GPU: swiftshader_indirect
├── RAM: 6GB (default)
├── Storage: 128GB (virtual)
└── SD Card: 512MB

AVD Configuration
├── Name: Pixel_6a_API_36
├── System Image: google_apis
├── ABI: x86_64
├── Skin: pixel_6a
└── Mode: Headless (no-window)
```

## 🚀 Quick Commands

### Build
```bash
# Trigger via push
git push origin copilot/debug-expense-report-crash

# Or manual trigger
# GitHub → Actions → Run workflow
```

### Test (Automated)
```bash
# Download APK first, then:
./test_emulator.sh app-debug.apk
```

### Test (Manual)
```bash
# Create emulator
avdmanager create avd -n Pixel_6a_API_36 \
  -k "system-images;android-36;google_apis;x86_64" \
  -d "pixel_6a"

# Start emulator
emulator -avd Pixel_6a_API_36 -no-window &

# Install and test
adb wait-for-device
adb install -r app-debug.apk
adb shell pm grant com.avant.expensereport android.permission.CAMERA
adb shell am start -n com.avant.expensereport/.MainActivity
adb exec-out screencap -p > screenshot.png
```

## 📁 File Structure

```
ExpenseReportApp/
│
├── 📄 QUICKTEST.md           # Quick start (5 min)
├── 📄 TEST_ON_EMULATOR.md    # Complete guide
├── 📄 TESTING_SUMMARY.md     # Project summary
├── 📄 WORKFLOW_DIAGRAM.md    # This file
│
├── 🔧 test_emulator.sh       # Automated test script
│
├── 📱 .github/workflows/
│   └── build-apk.yml         # CI/CD pipeline
│
├── 📸 test_screenshots/      # Created by tests
│   └── 01_app_launched.png   # Screenshot evidence
│
└── 🏗️ app/
    └── build/outputs/apk/
        └── debug/
            └── app-debug.apk # Built by GitHub Actions
```

## ⏱️ Timeline

```
Total Time: ~10 minutes

┌─────────────────────────┐
│ Build APK               │  5 min   GitHub Actions
├─────────────────────────┤
│ Download APK            │  1 min   Manual download
├─────────────────────────┤
│ Run Test Script         │  2 min   Automated
├─────────────────────────┤
│ Review Results          │  2 min   Manual review
└─────────────────────────┘
```

## 🎯 Success Indicators

```
✅ GitHub Actions build passes
✅ APK artifact available for download
✅ Emulator starts without errors
✅ APK installs successfully
✅ App launches without crashes
✅ Screenshot shows main activity
✅ Logs show no critical errors
✅ All permissions granted
```

## 📞 Support Resources

| Issue | Solution |
|-------|----------|
| Build fails | Check GitHub Actions logs |
| APK not found | Download from Artifacts section |
| Emulator won't start | Check AVD creation logs |
| App crashes | Review adb logcat output |
| Permission errors | Re-run permission grants |
| Screenshot fails | Use alternative adb commands |

## 🔗 Quick Links

- **Build**: [GitHub Actions](.github/workflows/build-apk.yml)
- **Test Script**: [test_emulator.sh](test_emulator.sh)
- **Quick Guide**: [QUICKTEST.md](QUICKTEST.md)
- **Full Guide**: [TEST_ON_EMULATOR.md](TEST_ON_EMULATOR.md)
- **Summary**: [TESTING_SUMMARY.md](TESTING_SUMMARY.md)

---

**Status**: ✅ Ready for Testing
**Last Updated**: 2026-02-17
**Version**: 1.0.1

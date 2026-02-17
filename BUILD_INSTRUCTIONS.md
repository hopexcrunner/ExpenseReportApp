# Building the APK - Solution for Network-Restricted Environments

## Current Situation

The build environment is network-restricted and cannot access:
- dl.google.com (Android Maven repository)
- services.gradle.org (Gradle distributions)
- Other external repositories

This prevents local APK building using Gradle.

## ✅ Recommended Solution: GitHub Actions

Since local building is blocked, use GitHub Actions to build your APK in the cloud automatically.

### Setup (One-Time, 5 minutes)

1. The `.github/workflows/build-apk.yml` file is already configured
2. Push your code to GitHub
3. GitHub Actions will automatically build the APK
4. Download the APK from the Actions tab

### How It Works

Every push to the repository triggers an automatic build:
- ✅ Runs in GitHub's cloud environment (has internet access)
- ✅ Downloads all dependencies automatically
- ✅ Builds debug APK
- ✅ Uploads APK as downloadable artifact
- ✅ Typically completes in 5-7 minutes

### Downloading Your APK

1. Go to your GitHub repository
2. Click "Actions" tab
3. Click the latest workflow run
4. Scroll to "Artifacts" section
5. Download "app-debug-apk"
6. Extract the ZIP to get your APK

## Alternative: Local Build with Android Studio

If you have Android Studio installed locally:

1. **Clone the repository** to your local machine
2. **Open in Android Studio**
   - File → Open → Select ExpenseReportApp folder
   - Wait for Gradle sync (downloads dependencies)
3. **Build APK**
   - Build → Build Bundle(s) / APK(s) → Build APK(s)
   - Or run: `./gradlew assembleDebug` in terminal
4. **Get your APK**
   - Location: `app/build/outputs/apk/debug/app-debug.apk`

### Prerequisites for Local Build
- Android Studio installed
- Internet connection (for first-time dependency download)
- Java JDK 8+ (included with Android Studio)

## Quick Test Instructions

Once you have the APK:

1. **Transfer to Android device**
   - Email the APK to yourself
   - Or use USB cable to copy
   - Or upload to cloud storage

2. **Install on device**
   - Open APK file on Android device
   - Tap "Install"
   - May need to enable "Install from Unknown Sources"

3. **Grant permissions**
   - Camera access (required)
   - Storage access (required for saving files)

4. **Test the app**
   - Point camera at a receipt
   - Tap "Capture Receipt"
   - Review extracted data
   - Check email draft with attachments

## Testing Checklist

- [ ] App installs successfully
- [ ] Camera preview appears
- [ ] Can capture receipt photo
- [ ] OCR extracts text from receipt
- [ ] Receipt data appears in info panel
- [ ] Excel report is generated
- [ ] Email draft opens with both attachments
- [ ] Can send email successfully

## Known Working Configuration

The app is configured with:
- **minSdk**: 24 (Android 7.0)
- **targetSdk**: 34 (Android 14)
- **Permissions**: Camera, Storage
- **Size**: ~15-25 MB (includes ML Kit, Apache POI)

## Troubleshooting

### "App not installed" error
- Check Android version (need 7.0+)
- Enable "Install from Unknown Sources"
- Clear old version if exists

### Camera doesn't work
- Grant camera permission in settings
- Restart app after granting permission

### OCR fails or inaccurate
- Ensure good lighting
- Hold phone steady
- Receipt text should be clear and in focus
- Some handwritten receipts may not work well

## Next Steps After Testing

Once you have a working prototype:

1. **Test with real receipts** - Try various receipt formats
2. **Note improvements needed** - Document what works/doesn't work
3. **Prioritize enhancements** - List features to add or fix
4. **Iterate** - Make changes and rebuild

## Need Help?

If you encounter issues:
1. Check the GitHub Actions build logs for errors
2. Review the app logs (use `adb logcat` when device is connected)
3. Test with the sample receipt provided in the repository
4. Share specific error messages for targeted help

---

**Summary**: Use GitHub Actions to build your APK automatically, or build locally with Android Studio if you have internet access. The sandboxed development environment cannot build APKs due to network restrictions.

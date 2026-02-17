# How to Build the APK

Since I can't directly compile Android apps in this environment, here are **3 easy ways** to get your APK:

## ⚡ Option 1: Use Android Studio (Easiest - Recommended)

**5-Minute Process:**

1. **Open the project**
   - Extract the ZIP file
   - Open Android Studio
   - File → Open → Select `ExpenseReportApp` folder
   - Wait for Gradle sync (2-3 minutes first time)

2. **Build APK**
   - Click: Build → Build Bundle(s) / APK(s) → Build APK(s)
   - Wait 1-2 minutes
   - Click "locate" link in notification

3. **Get your APK**
   - Location: `app/build/outputs/apk/debug/app-debug.apk`
   - Rename to `AvantExpenseReport.apk`
   - Done! 🎉

**Install on phone:**
- Email the APK to yourself, open on phone, install
- OR connect phone via USB, drag APK to phone, install

---

## 🖥️ Option 2: Command Line (Faster for developers)

### On Mac/Linux:
```bash
cd ExpenseReportApp
./build_apk.sh
```

### On Windows:
```cmd
cd ExpenseReportApp
build_apk.bat
```

The script will:
- ✅ Check prerequisites
- ✅ Build the APK automatically
- ✅ Copy it to `AvantExpenseReport.apk`
- ✅ Show installation instructions

**Prerequisites:**
- Java JDK 8+ installed
- Android SDK installed (comes with Android Studio)
- `ANDROID_HOME` environment variable set

---

## 🌐 Option 3: Use GitHub Actions (No local setup needed)

If you have a GitHub account, I can provide a workflow file that builds the APK in the cloud:

1. Create a GitHub repository
2. Upload this project
3. GitHub Actions automatically builds APK
4. Download from Actions tab

Want me to create the GitHub Actions workflow file?

---

## 📦 What Gets Built

**APK Name:** `app-debug.apk` or `AvantExpenseReport.apk`  
**Size:** ~15-25 MB (includes all libraries)  
**Type:** Debug APK (for testing, not for Play Store)

**The APK contains:**
- ✅ All app code (camera, OCR, Excel processing)
- ✅ ML Kit for text recognition
- ✅ Apache POI for Excel
- ✅ Your Avant expense template
- ✅ All resources and UI

---

## 📲 Installing the APK on Android

### Method 1: USB Install (Most reliable)
```bash
# Connect phone via USB, enable USB debugging
adb install AvantExpenseReport.apk
```

### Method 2: Email/Cloud
1. Email APK to yourself
2. Open email on Android phone
3. Download APK
4. Tap to install
5. If needed: Settings → Security → Allow "Unknown Sources"

### Method 3: File Transfer
1. Connect phone to computer via USB
2. Copy APK to phone's Download folder
3. Use phone's file manager to open APK
4. Install

---

## ⚙️ Prerequisites for Building

### Install Android Studio (One-time setup)
1. Download: https://developer.android.com/studio
2. Run installer
3. Open Android Studio
4. Follow setup wizard (installs SDK automatically)

**That's it!** Android Studio includes everything needed.

### Verify Installation
```bash
# Check Java
java -version

# Check Android SDK (after Android Studio install)
# Mac/Linux
echo $ANDROID_HOME

# Windows
echo %ANDROID_HOME%
```

---

## 🐛 Troubleshooting

### "Gradle sync failed"
```bash
# In Android Studio:
File → Invalidate Caches → Restart
```

### "SDK not found"
```bash
# Set ANDROID_HOME to your SDK location
# Usually:
# Mac: ~/Library/Android/sdk
# Windows: C:\Users\YourName\AppData\Local\Android\Sdk
# Linux: ~/Android/Sdk

# Add to ~/.bashrc or ~/.zshrc (Mac/Linux):
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Windows: Set in Environment Variables
```

### "Build failed - missing dependencies"
- Make sure you have internet connection
- Gradle will download dependencies (first time only)
- Wait for "Gradle sync" to complete before building

### APK won't install on phone
- Enable "Install from Unknown Sources" in phone settings
- Check Android version (need 7.0+)
- Try: Settings → Apps → Special Access → Install Unknown Apps → [Your Browser/Files] → Allow

---

## 🔒 Building Release APK (For distribution)

The scripts build a **debug APK** which is fine for testing. For production:

1. Create signing key
2. Add signing config to `app/build.gradle.kts`
3. Build release APK
4. Upload to Google Play or distribute

See `BUILD_DEPLOY.md` for full release build instructions.

---

## ⏱️ Build Times

- **First build:** 5-10 minutes (downloads dependencies)
- **Subsequent builds:** 1-2 minutes
- **No code changes:** 30 seconds

---

## 📊 APK Info

```
Name: AvantExpenseReport.apk
Package: com.avant.expensereport
Min Android: 7.0 (API 24)
Target Android: 14 (API 34)
Permissions: Camera, Storage
Size: ~20MB
```

---

## 🚀 Quick Start Summary

**Absolute fastest way:**
1. Install Android Studio
2. Open project
3. Click Build → Build APK
4. Done in 5 minutes!

**No Android Studio?**
1. Install Android Studio anyway (it's free and needed)
2. Or use the build scripts provided
3. Or let me create GitHub Actions workflow

---

## ❓ Need Help?

**Can't install Android Studio?**
- It's a 1GB download but handles everything automatically
- No manual SDK setup needed
- Required for Android development

**Still stuck?**
- Check `BUILD_DEPLOY.md` for detailed instructions
- Common issues documented in `README.md`
- All build errors have solutions in Android Studio

**Want me to create additional build options?**
- GitHub Actions workflow
- Docker container for building
- Gradle wrapper configuration
- Just ask!

---

## 📝 Next Steps After Building

1. ✅ Build APK (you are here)
2. 📱 Install on test device
3. 📸 Test with sample receipt
4. ✏️ Customize if needed
5. 📧 Distribute to users

The APK is ready for testing and distribution once built!

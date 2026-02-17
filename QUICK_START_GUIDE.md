# 🚀 QUICK START: Testing Your App on Google Pixel 6a

## ❓ Where Do I Run The Script?

**Run it in your PC's Command Prompt or Terminal** - NOT in Android Studio, NOT on GitHub!

---

## 📍 Step-by-Step Instructions

### Step 1: Open Command Prompt/Terminal on Your PC

**On Windows:**
- Press `Windows Key + R`
- Type `cmd` and press Enter
- You'll see a black window (Command Prompt)

**On Mac:**
- Press `Command + Space`
- Type `terminal` and press Enter
- You'll see a terminal window

**On Linux:**
- Press `Ctrl + Alt + T`
- Terminal opens

### Step 2: Navigate to the Project Folder

In the Command Prompt/Terminal, type:

```bash
cd path/to/ExpenseReportApp
```

**Example for Windows:**
```cmd
cd C:\Users\YourName\Documents\ExpenseReportApp
```

**Example for Mac/Linux:**
```bash
cd /Users/YourName/Documents/ExpenseReportApp
```

**How to find the path?**
- Right-click the `ExpenseReportApp` folder
- Windows: Choose "Copy as path"
- Mac: Hold Option key, right-click, choose "Copy ... as Pathname"

### Step 3: Connect Your Google Pixel 6a

1. Connect USB cable from your Pixel 6a to your PC
2. On your phone, accept "Allow USB debugging?" prompt
3. Make sure USB debugging is enabled in Developer options

### Step 4: Run the Diagnostic Script

**On Windows:**
```cmd
diagnose_crash.bat
```

**On Mac/Linux:**
```bash
./diagnose_crash.sh
```

**If you see "permission denied" on Mac/Linux:**
```bash
chmod +x diagnose_crash.sh
./diagnose_crash.sh
```

### Step 5: Choose an Option

The script will show a menu:
```
What would you like to do?

1) Capture crash logs from device
2) Build, install app and monitor logs in real-time
3) Just install latest APK
4) Start live monitoring
5) Clear app data and reinstall
6) Get current app version info

Enter choice (1-6):
```

**Recommended: Type `2` and press Enter**

This will:
- Build your app
- Install it on your phone
- Monitor for any crashes
- Show you what's happening in real-time

---

## 🖥️ What You Should See

### Successful Connection
```
================================================
ExpenseReportApp - Live Crash Diagnosis Tool
================================================

📱 Connected Device:
   Model: Pixel 6a
   Android: 16 (API 35)

Building APK...
Installing...
Monitoring logs...
```

### Device Not Connected
```
❌ No device connected

Please ensure your Google Pixel 6a is connected via USB and:
1. USB debugging is enabled
2. You've accepted the 'Allow USB debugging?' prompt

Waiting for device connection...
```

If you see this, check your USB connection and phone settings.

---

## 🆘 Common Issues

### "command not found" or "not recognized"

**Problem:** You're not in the right folder

**Solution:**
1. Use `cd` command to navigate to ExpenseReportApp folder
2. Verify you're in the right place by typing:
   - Windows: `dir` (should list files including `diagnose_crash.bat`)
   - Mac/Linux: `ls` (should list files including `diagnose_crash.sh`)

### "adb: command not found"

**Problem:** Android tools not installed

**Solution:** 
1. The script should work anyway - it will tell you what's missing
2. Or install Android SDK Platform Tools:
   - Download from: https://developer.android.com/tools/releases/platform-tools
   - Extract and add to your system PATH

### Device shows as "unauthorized"

**Problem:** You didn't accept the USB debugging prompt

**Solution:**
1. Look at your Pixel 6a screen
2. You should see "Allow USB debugging?" prompt
3. Check "Always allow from this computer"
4. Tap "Allow"
5. Try running the script again

---

## ✅ Summary

1. ✅ Open **Command Prompt** (Windows) or **Terminal** (Mac/Linux) on your PC
2. ✅ Navigate to ExpenseReportApp folder using `cd` command
3. ✅ Connect your Pixel 6a via USB
4. ✅ Run `diagnose_crash.bat` (Windows) or `./diagnose_crash.sh` (Mac/Linux)
5. ✅ Choose option 2 for automated testing

**NOT in Android Studio ❌**  
**NOT on GitHub website ❌**  
**YES in Command Prompt/Terminal on your PC ✅**

---

## 📺 Video Guide (Coming Soon)

If you're still unsure, look for `VISUAL_GUIDE.md` which will include screenshots of each step.

---

## Need More Help?

- See `DEVICE_CONNECTION_GUIDE.md` for detailed troubleshooting
- See `FIX_SUMMARY.md` for what was fixed in the app
- Ask for help if you're stuck!

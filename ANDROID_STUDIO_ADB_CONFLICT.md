# 🔧 Android Studio ADB Conflict - SOLVED

## Your Situation

✅ **Android Studio shows your device connected**  
✅ **You can see the device screen in Android Studio**  
❌ **Command Prompt `adb devices` shows no devices**  

## 🎯 The Problem

**Android Studio is hogging the connection!**

Android Studio runs its own adb (Android Debug Bridge) server, which locks the USB connection to your Pixel 6a. When you try to run `adb devices` in Command Prompt, it can't access the device because Android Studio's adb server is already using it.

This is **NOT a phone settings issue** - it's an adb server conflict on your PC.

---

## ✅ Solution 1: Use Android Studio's Built-In Terminal (EASIEST)

Since Android Studio already has the connection, just use its terminal!

### Steps:

1. **In Android Studio**, look at the bottom of the window
2. Click the **"Terminal"** tab (bottom left area)
3. A terminal will open **inside Android Studio**
4. You're now in your project folder automatically!
5. Run the diagnostic script:

**Windows:**
```cmd
diagnose_crash.bat
```

**Mac/Linux:**
```bash
./diagnose_crash.sh
```

**Why this works:** Android Studio's terminal uses Android Studio's adb server, which already has your device connected.

### Screenshot locations:
```
Android Studio
├── Top Menu Bar
├── Code Editor (center)
├── Project Files (left)
└── Bottom Panel
    ├── [Terminal] ← Click here!
    ├── Logcat
    └── Build
```

---

## ✅ Solution 2: Restart ADB Server (TEMPORARY FIX)

If you prefer using regular Command Prompt, you can temporarily stop Android Studio's adb.

### Steps:

1. **Close Android Studio** (important!)
2. Open Command Prompt
3. Run these commands:

```cmd
adb kill-server
adb start-server
adb devices
```

You should now see your device!

4. Run the diagnostic script:
```cmd
cd C:\path\to\ExpenseReportApp
diagnose_crash.bat
```

**Note:** If you open Android Studio again, it will take over the connection and you'll need to repeat this.

---

## ✅ Solution 3: Use Android Studio's ADB from Command Prompt

Tell Command Prompt to use Android Studio's adb instead of the standalone one.

### Find Android Studio's ADB Location:

**Windows:**
```
C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

**Mac:**
```
/Users/YourName/Library/Android/sdk/platform-tools/adb
```

**Linux:**
```
/home/yourname/Android/Sdk/platform-tools/adb
```

### Use it directly:

**Windows:**
```cmd
cd C:\path\to\ExpenseReportApp
set PATH=C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools;%PATH%
adb devices
diagnose_crash.bat
```

**Mac/Linux:**
```bash
cd /path/to/ExpenseReportApp
export PATH="/Users/YourName/Library/Android/sdk/platform-tools:$PATH"
adb devices
./diagnose_crash.sh
```

---

## ✅ Solution 4: No Phone Settings Needed!

### Your phone is configured correctly! ✅

You mentioned Android Studio can see your device, which means:
- ✅ USB Debugging is enabled
- ✅ You've accepted the "Allow USB debugging" prompt
- ✅ Your USB cable is working
- ✅ Drivers are installed correctly

**There are NO phone settings you need to change.**

The issue is purely on the PC side - two adb servers trying to use the same device.

---

## 🚀 Recommended Solution

**Use Android Studio's Terminal** (Solution 1)

Why?
- ✅ Easiest - no configuration needed
- ✅ Works immediately
- ✅ No need to close Android Studio
- ✅ No adb server conflicts
- ✅ Already in the right folder

### Quick Steps:
1. Open Android Studio
2. Click "Terminal" tab at bottom
3. Type: `diagnose_crash.bat` (Windows) or `./diagnose_crash.sh` (Mac/Linux)
4. Press Enter
5. Choose option 2 from the menu

Done! ✅

---

## 🔍 How to Verify Connection

Once you're in Android Studio's terminal (or have fixed the adb conflict), run:

```bash
adb devices
```

You should see:
```
List of devices attached
1234567890ABCDEF    device
```

If you see this, your device is properly connected!

---

## 📊 Troubleshooting

### "adb: command not found" in Android Studio Terminal

**Rare, but if this happens:**

The terminal needs to know where adb is. Add it to your PATH:

**Windows (in Android Studio Terminal):**
```cmd
set PATH=C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools;%PATH%
```

**Mac (in Android Studio Terminal):**
```bash
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
```

Then try `adb devices` again.

### Device shows as "unauthorized"

This means you haven't accepted the prompt on your phone:
1. Look at your Pixel 6a screen
2. Tap "Allow" on the "Allow USB debugging?" prompt
3. Check "Always allow from this computer"

### Android Studio not showing device

This would be unusual if you can see it in the device window. But if needed:
1. Unplug USB cable
2. In Android Studio: Tools → Device Manager
3. Replug USB cable
4. Device should appear

---

## 📝 Understanding the Conflict

```
Your Computer:
├── Standalone adb.exe (from platform-tools download)
│   └── Tries to start its own server on port 5037
│
└── Android Studio
    └── Built-in adb.exe (comes with Android Studio)
        └── Already running server on port 5037 ← Conflict!

Only ONE adb server can run at a time!
```

When both try to use port 5037, they conflict. Android Studio usually wins because it starts first.

---

## 🎓 What NOT to Change on Your Phone

You asked about phone settings. Here's what you **should NOT change**:

❌ Don't disable USB debugging - you need it  
❌ Don't revoke USB debugging authorizations - you already authorized  
❌ Don't change USB configuration mode - current mode is fine  
❌ Don't install anything on your phone - it's configured correctly  

The phone is fine! The issue is purely on your PC with adb servers.

---

## 🎉 Summary

**Your Problem:** Android Studio's adb server is using the device connection.

**Your Phone:** Configured perfectly - no changes needed! ✅

**Best Solution:** Use Android Studio's built-in Terminal tab

**Quick Fix:**
1. Android Studio → Terminal (bottom tab)
2. Run: `diagnose_crash.bat` or `./diagnose_crash.sh`
3. Device will be detected automatically!

**Alternative:** Close Android Studio, restart adb in Command Prompt

---

## 🆘 Still Having Issues?

If none of these solutions work:

1. Share what you see when you run `adb devices` in Android Studio's terminal
2. Share any error messages
3. We'll troubleshoot further!

But 99% of the time, using Android Studio's terminal solves this immediately.

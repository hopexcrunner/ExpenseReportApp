# 📺 Visual Guide: Where to Run the Script

## ❓ The Question

**"Where do I run `./diagnose_crash.sh`?"**

---

## ✅ THE ANSWER: Command Prompt or Terminal on Your PC

```
YOUR PC
├── 🖥️ Operating System (Windows/Mac/Linux)
│   ├── 📁 File Explorer / Finder
│   ├── 🎨 Web Browser (Chrome, Edge, etc.)
│   ├── 💻 Command Prompt / Terminal  ← RUN SCRIPT HERE! ✅
│   ├── 🔧 Android Studio (optional - NOT needed)
│   └── 📱 Connected: Google Pixel 6a (via USB)
```

---

## 🎯 Step-by-Step with Examples

### Step 1: Open Command Prompt/Terminal

#### Windows Users
```
Start Menu → Type "cmd" → Press Enter
```
You'll see something like:
```
Microsoft Windows [Version 10.0.xxxxx.xxxx]
(c) Microsoft Corporation. All rights reserved.

C:\Users\YourName>_
```

#### Mac Users
```
Applications → Utilities → Terminal
OR
Spotlight (⌘ + Space) → Type "terminal" → Press Enter
```
You'll see something like:
```
Last login: Mon Feb 17 09:00:00 on ttys001
YourName@MacBook ~ % _
```

#### Linux Users
```
Press Ctrl+Alt+T
```
You'll see something like:
```
yourname@computer:~$ _
```

---

### Step 2: Navigate to ExpenseReportApp Folder

#### Find Your Project Path

**Where is your ExpenseReportApp folder?**

Common locations:
- Windows: `C:\Users\YourName\Documents\ExpenseReportApp`
- Mac: `/Users/YourName/Documents/ExpenseReportApp`
- Linux: `/home/yourname/Documents/ExpenseReportApp`

**Pro Tip:** 
- In File Explorer (Windows) or Finder (Mac), right-click the ExpenseReportApp folder
- Choose "Copy path" or "Copy pathname"
- Paste it into the cd command below

#### Navigate There

**Windows:**
```cmd
cd C:\Users\YourName\Documents\ExpenseReportApp
```

**Mac/Linux:**
```bash
cd /Users/YourName/Documents/ExpenseReportApp
```

After running this, your prompt should show you're in that folder:
```
C:\Users\YourName\Documents\ExpenseReportApp>_
```

---

### Step 3: Verify You're in the Right Place

Type this command to list files:

**Windows:**
```cmd
dir
```

**Mac/Linux:**
```bash
ls
```

You should see files like:
```
diagnose_crash.sh
diagnose_crash.bat
build.gradle.kts
README.md
app/
```

If you see these files, you're in the right place! ✅

If not, you need to navigate to the correct folder. ❌

---

### Step 4: Run the Script

**Windows:**
```cmd
diagnose_crash.bat
```

**Mac/Linux:**
```bash
./diagnose_crash.sh
```

**If you get "permission denied" on Mac/Linux:**
```bash
chmod +x diagnose_crash.sh
./diagnose_crash.sh
```

---

## ❌ Where NOT to Run It

### NOT in Android Studio
```
Android Studio
├── Project Explorer (left sidebar)
├── Code Editor (center)
└── Terminal (bottom)  ← Don't use this one!
```

Why? Because Android Studio's terminal might have different environment settings.
Use your PC's native terminal instead.

### NOT on GitHub
```
GitHub.com
├── Repository page
├── Code tab
└── Files list  ← Can't run scripts here!
```

GitHub is just for viewing code. You need to run scripts on your PC.

### NOT in Web Browser
You can't run command-line scripts in Chrome, Edge, Firefox, etc.

---

## 🎬 What Should Happen When You Run It

### Successful Run:
```
================================================
ExpenseReportApp - Live Crash Diagnosis Tool
================================================

📱 Connected Device:
   Model: Pixel 6a
   Android: 16 (API 35)

What would you like to do?

1) Capture crash logs from device
2) Build, install app and monitor logs in real-time
3) Just install latest APK
4) Start live monitoring
5) Clear app data and reinstall
6) Get current app version info

Enter choice (1-6): _
```

### Device Not Connected:
```
❌ No device connected

Please ensure your Google Pixel 6a is connected via USB and:
1. USB debugging is enabled
2. You've accepted the 'Allow USB debugging?' prompt

Waiting for device connection...
```

---

## 🆘 Troubleshooting

### "command not found" or "is not recognized"

**Problem:** You're not in the ExpenseReportApp folder

**Solution:**
1. Use `cd` command to navigate there
2. Verify with `dir` (Windows) or `ls` (Mac/Linux)
3. You should see `diagnose_crash.bat` or `diagnose_crash.sh` in the list

### "permission denied" (Mac/Linux only)

**Problem:** Script doesn't have execute permission

**Solution:**
```bash
chmod +x diagnose_crash.sh
./diagnose_crash.sh
```

### "adb: command not found"

**Problem:** Android Debug Bridge not installed

**Solution:** The script will guide you, or install from:
https://developer.android.com/tools/releases/platform-tools

---

## 📝 Quick Reference Card

```
┌─────────────────────────────────────────────────┐
│  WHERE TO RUN DIAGNOSTIC SCRIPT                 │
├─────────────────────────────────────────────────┤
│  ✅ Windows Command Prompt                      │
│  ✅ Mac Terminal                                │
│  ✅ Linux Terminal                              │
│                                                  │
│  ❌ Android Studio                              │
│  ❌ GitHub website                              │
│  ❌ Web browser                                 │
├─────────────────────────────────────────────────┤
│  QUICK STEPS:                                   │
│  1. Open Command Prompt/Terminal                │
│  2. cd /path/to/ExpenseReportApp                │
│  3. Run: diagnose_crash.bat (Win) or            │
│          ./diagnose_crash.sh (Mac/Linux)        │
├─────────────────────────────────────────────────┤
│  NEED MORE HELP?                                │
│  → Read: QUICK_START_GUIDE.md                   │
│  → Read: DEVICE_CONNECTION_GUIDE.md             │
└─────────────────────────────────────────────────┘
```

---

## 🎓 Understanding the Difference

**Command Prompt / Terminal:**
- Built into your operating system
- Lets you run commands and scripts
- Direct access to your computer's functions
- Where developers run build tools, scripts, etc.

**Android Studio:**
- An application for writing Android apps
- Has its own embedded terminal
- Can run scripts, but better to use native terminal

**GitHub:**
- A website for hosting code
- You can view and download code
- But you can't run scripts there
- Need to download code to your PC first

---

## 💡 Summary

1. 🖥️ Open **Command Prompt** (Windows) or **Terminal** (Mac/Linux)
2. 📁 Navigate to **ExpenseReportApp** folder using `cd` command
3. 📱 Make sure your **Pixel 6a is connected** via USB
4. ▶️ Run the script:
   - Windows: `diagnose_crash.bat`
   - Mac/Linux: `./diagnose_crash.sh`

**That's it!** You're running it on your PC, not in any app or website.

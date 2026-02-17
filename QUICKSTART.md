# Quick Start Guide - Avant Expense Report App

## 🚀 Get Started in 5 Minutes

### Step 1: Prerequisites
- Install Android Studio: https://developer.android.com/studio
- Enable Developer Options on your Android device

### Step 2: Setup Project
```bash
# Extract the project files
# Place Avant_2026_Expense_Report_Form.xlsx in app/src/main/assets/
```

### Step 3: Open in Android Studio
1. Open Android Studio
2. File → Open → Select `ExpenseReportApp` folder
3. Wait for Gradle sync (may take 2-5 minutes first time)

### Step 4: Run
1. Connect Android phone via USB OR start Android Emulator
2. Click green Run button (▶️)
3. App installs and launches automatically

### Step 5: Use the App
1. **Grant Permissions**: Allow camera access when prompted
2. **Position Receipt**: Point camera at receipt, ensure text is readable
3. **Capture**: Tap "Capture Receipt" button
4. **Review Data**: Check extracted information in panel below
5. **Email**: App opens email with receipt + report attached
6. **Send**: Review and send email

## 📱 What the App Does

```
Receipt Photo → OCR Processing → Excel Report → Email Draft
     📷              🔍              📊              ✉️
```

1. **Camera captures** receipt image
2. **ML Kit OCR** extracts text from image
3. **Parser** identifies merchant, date, items, amounts
4. **Processor** fills Excel expense report template
5. **Email intent** creates draft with both files attached

## 🎯 Key Features

- ✅ Automatic data extraction (merchant, date, amount, items)
- ✅ Supports European receipts (€, IVA, Spanish dates)
- ✅ Pre-fills Excel expense report
- ✅ Email ready with attachments
- ✅ Preserves original receipt photo

## 📝 Receipt Requirements

For best OCR results:
- ✓ Well-lit environment
- ✓ Receipt flat and clear
- ✓ Text in focus
- ✓ Minimum blur
- ✓ Standard printed receipts

## 🔧 Troubleshooting

**Camera won't open**
- Check permissions in Settings → Apps → Avant Expense Report
- Restart app

**OCR not accurate**
- Retake photo with better lighting
- Hold camera steady
- Get closer to receipt
- Some values may need manual correction in Excel

**Email won't open**
- Install Gmail or other email app
- Check storage permissions

## 📂 File Locations

After capturing:
- Receipt photos: `Android/media/com.avant.expensereport/AvantExpenseReport/`
- Excel reports: Same folder
- Access via Files app on Android

## 🎨 Customization Points

### Change Default Category
Edit `ExpenseReportProcessor.kt` line 61:
```kotlin
setCellValue(sheet, row, 12, "8420 - Travel") // Change category
```

### Change Email Recipient
Edit `MainActivity.kt` line 192:
```kotlin
putExtra(Intent.EXTRA_EMAIL, arrayOf("yourfinance@company.com"))
```

## 💡 Tips

1. **Multiple Receipts**: Capture each receipt separately
2. **Review Excel**: Always review auto-filled data before submitting
3. **Keep Originals**: Physical receipts may still be required
4. **Lighting**: Natural lighting works best
5. **Angle**: Keep camera parallel to receipt

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Blurry capture | Hold phone steady, tap to focus |
| Wrong amount | Check OCR extracted data, edit Excel |
| No email app | Install Gmail or Email app |
| Build errors | File → Invalidate Caches → Restart |

## 📧 Getting Help

If you encounter issues:
1. Check the full README.md
2. Review code comments in source files
3. Check Android Studio error messages
4. Verify template file in assets folder

## 🔐 Permissions Required

- **Camera**: Capture receipt photos
- **Storage**: Save images and Excel files

Both permissions are requested on first launch.

---

**Time to first capture**: ~30 seconds after installation
**Average processing time**: 2-3 seconds per receipt

Ready to start? Open Android Studio and click Run! 🚀

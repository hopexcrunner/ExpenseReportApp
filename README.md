# Avant Expense Report Android App

An Android application that uses OCR (Optical Character Recognition) to automatically extract data from receipt photos and populate Excel expense reports. The app then creates an email draft with both the original receipt and completed expense report attached.

## 🚀 Quick Start - Testing on Your Device

**Are you trying to test the app on your Google Pixel 6a?**

👉 **[READ THIS FIRST: QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** 👈

This guide explains exactly WHERE and HOW to run the diagnostic scripts (spoiler: in your PC's Command Prompt/Terminal, not Android Studio!)

## Features

- **Camera Integration**: Capture receipt photos directly in the app
- **OCR Processing**: Automatically extract merchant name, date, amount, and line items from receipts using Google ML Kit
- **Excel Report Generation**: Fill out the Avant 2026 Expense Report form with extracted data
- **Email Draft Creation**: Generate email with both receipt image and Excel report attached
- **User-Friendly Interface**: Simple camera preview with real-time receipt information display

## Technical Stack

- **Language**: Kotlin
- **Minimum SDK**: Android 8.0 (API 26) - Updated for compatibility
- **Target SDK**: Android 14 (API 34)
- **Key Libraries**:
  - CameraX for camera functionality
  - Google ML Kit for text recognition
  - Apache POI for Excel file manipulation
  - Material Design Components for UI
  - Kotlin Coroutines for async operations

## Project Structure

```
ExpenseReportApp/
├── app/
│   ├── src/main/
│   │   ├── java/com/avant/expensereport/
│   │   │   ├── MainActivity.kt              # Main activity with camera & OCR
│   │   │   ├── ReceiptData.kt               # Data models
│   │   │   ├── ReceiptParser.kt             # OCR text parsing logic
│   │   │   └── ExpenseReportProcessor.kt    # Excel file manipulation
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   └── activity_main.xml        # Main UI layout
│   │   │   ├── values/
│   │   │   │   ├── strings.xml
│   │   │   │   ├── colors.xml
│   │   │   │   └── themes.xml
│   │   │   └── xml/
│   │   │       └── file_paths.xml           # FileProvider paths
│   │   ├── assets/
│   │   │   └── Avant_2026_Expense_Report_Form.xlsx  # Template file
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── build.gradle.kts
├── settings.gradle.kts
└── gradle.properties
```

## Setup Instructions

### Prerequisites

1. **Android Studio** (latest stable version recommended)
2. **JDK 8 or higher**
3. **Android device or emulator** with camera support

### Installation Steps

1. **Clone or download** this project

2. **Add the Excel template**:
   - Copy `Avant_2026_Expense_Report_Form.xlsx` to `app/src/main/assets/`
   - Create the `assets` folder if it doesn't exist:
     ```
     mkdir -p app/src/main/assets
     ```

3. **Open in Android Studio**:
   - File → Open → Select the `ExpenseReportApp` folder
   - Wait for Gradle sync to complete

4. **Build the project**:
   - Build → Make Project
   - Fix any dependency issues if prompted

5. **Run on device**:
   - Connect Android device via USB (enable USB debugging)
   - Or start an Android emulator
   - Click Run (▶️) button

### First Launch

The app will request the following permissions:
- **Camera**: Required to capture receipt photos
- **Storage**: Required to save images and Excel files

## How to Use

1. **Launch the app**: Camera preview will appear
2. **Position receipt**: Point camera at a receipt
3. **Capture**: Tap "Capture Receipt" button
4. **Review**: OCR-extracted data appears in the info panel
5. **Email draft**: App automatically creates email with:
   - Original receipt photo attached
   - Completed Excel expense report attached
   - Pre-filled subject and recipient
6. **Send**: Review and send the email from your email app

## Receipt Parser Details

The app extracts the following information:
- **Merchant name**: Usually first line of receipt
- **Address**: Street address and postal code
- **Date**: Various date formats supported
- **Line items**: Item descriptions with quantity × price
- **Total amount**: Final amount with currency
- **Tax amount**: VAT/IVA if present

### Supported Receipt Formats

The parser handles:
- European date formats (DD/MM/YYYY)
- US date formats (MM/DD/YYYY)
- Spanish receipts (IVA, etc.)
- Multiple currencies (€, $, etc.)
- Quantity × Price line items

## Excel Report Mapping

Data is populated in the Avant Expense Report as follows:

| Receipt Field | Excel Location | Notes |
|--------------|----------------|-------|
| Employee Name | Row 7, Column C | User can edit |
| Date Submitted | Row 7, Column G | Current date |
| Receipt Date | Row 42+, Column B | Per line item |
| Merchant | Row 42+, Column C | "From" field |
| Address | Row 42+, Column D | "To" field |
| Item Description | Row 42+, Column E | Purpose field |
| Amount | Row 42+, Column F | Local currency |
| Exchange Rate | Row 42+, Column G | Set to 1.0 |
| Account Code | Row 42+, Column M | Default: 8464 (Meals) |

## Customization

### Changing Default Account Code

Edit `ExpenseReportProcessor.kt`:
```kotlin
// Line 61 - Change account code
setCellValue(sheet, row, 12, "8420 - Travel") // or other code
```

### Adding More Receipt Patterns

Edit `ReceiptParser.kt` to add new regex patterns for:
- Different merchant name formats
- Additional date formats
- Currency variations
- Line item patterns

### Email Template

Edit `MainActivity.kt` (line 208) to customize:
- Default recipient email
- Email subject
- Email body text

## Troubleshooting

### Camera not working
- Ensure camera permissions granted
- Check device has working camera
- Try restarting the app

### OCR extraction errors
- Ensure receipt is well-lit
- Hold camera steady
- Receipt text should be clear and in focus
- Some receipts may require manual review

### Excel file not opening
- Ensure Apache POI dependencies are included
- Check that template file is in assets folder
- Verify file permissions

### Email not sending
- Ensure email app is installed
- Check file permissions for attachments
- Verify FileProvider configuration

## Dependencies

```gradle
// CameraX
implementation("androidx.camera:camera-core:1.3.1")
implementation("androidx.camera:camera-camera2:1.3.1")
implementation("androidx.camera:camera-lifecycle:1.3.1")
implementation("androidx.camera:camera-view:1.3.1")

// ML Kit OCR
implementation("com.google.mlkit:text-recognition:16.0.0")

// Apache POI for Excel
implementation("org.apache.poi:poi:5.2.5")
implementation("org.apache.poi:poi-ooxml:5.2.5")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
```

## Future Enhancements

Potential improvements:
- [ ] Multiple receipt processing in batch
- [ ] Cloud storage integration (Google Drive, Dropbox)
- [ ] Receipt categorization (meals, travel, supplies)
- [ ] Currency conversion API integration
- [ ] Historical receipt archive
- [ ] Offline mode with sync
- [ ] Multi-language support
- [ ] Receipt quality validation
- [ ] Duplicate detection
- [ ] Budget tracking

## Known Limitations

- OCR accuracy depends on receipt quality
- Some handwritten receipts may not parse correctly
- Unusual receipt formats may require manual entry
- Excel formulas are preserved but may need verification
- Limited to single currency per receipt

## License

Proprietary - Avant Ministries Internal Use

## Support

For issues or questions:
- Create an issue in the project repository
- Contact: it@avant.org

## Version History

- **v1.0.0** (2026-02-15): Initial release
  - Camera capture
  - OCR text recognition
  - Excel report generation
  - Email draft creation

---

**Note**: This app is designed specifically for Avant Ministries expense reporting workflow. The Excel template structure must match the Avant 2026 Expense Report Form.

# Architecture & Technical Documentation

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Camera   │  │ Preview  │  │ Info     │  │ Capture  │   │
│  │ Feed     │  │ Display  │  │ Panel    │  │ Button   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│                     (MainActivity.kt)                       │
│  • UI Event Handling                                        │
│  • Permission Management                                    │
│  • Lifecycle Management                                     │
│  • User Feedback                                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic                         │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │ ReceiptParser  │  │ ExpenseReport  │  │ Email        │ │
│  │                │  │ Processor      │  │ Composer     │ │
│  │ • Text Parse   │  │ • Excel Fill   │  │ • Draft      │ │
│  │ • Data Extract │  │ • Formula Gen  │  │ • Attach     │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ CameraX  │  │ ML Kit   │  │ Apache   │  │ Android  │  │
│  │          │  │ OCR      │  │ POI      │  │ FileAPI  │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Receipt  │  │ Excel    │  │ Images   │  │ Assets   │  │
│  │ Images   │  │ Files    │  │ Cache    │  │ Template │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. MainActivity.kt
**Responsibilities**:
- Camera lifecycle management
- Permission handling
- UI updates
- Orchestration of OCR and Excel processing
- Email intent creation

**Key Methods**:
```kotlin
startCamera()              // Initialize CameraX
takePhoto()                // Capture image
processImage()             // Trigger OCR pipeline
fillExpenseReport()        // Generate Excel
createEmailDraft()         // Compose email
```

**Dependencies**:
- CameraX (camera-core, camera-camera2, camera-lifecycle, camera-view)
- AndroidX (activity, lifecycle, core)
- Kotlin Coroutines

### 2. ReceiptParser.kt
**Responsibilities**:
- Parse raw OCR text
- Extract structured data
- Handle multiple receipt formats
- Validate extracted data

**Parsing Strategy**:
```kotlin
parseReceipt(text: String) -> ReceiptData {
    1. Split text into lines
    2. Extract merchant name (top of receipt)
    3. Find date pattern (regex matching)
    4. Extract line items (quantity × price pattern)
    5. Find total amount (TOTAL keyword + amount)
    6. Extract tax (IVA/VAT pattern)
    7. Return structured ReceiptData
}
```

**Regex Patterns**:
- Date: `\d{1,2}[/-]\d{1,2}[/-]\d{2,4}`
- Amount: `\d+[,.]\d{2}\s*€?`
- Line Item: `(.+?)\s+(\d+[,.]?\d*)\s*x\s*(\d+[,.]\d{2})`
- Tax: `(?:IVA|VAT|tax).*?(\d+[,.]\d{2})`

### 3. ExpenseReportProcessor.kt
**Responsibilities**:
- Load Excel template
- Map receipt data to Excel cells
- Preserve formulas
- Save modified workbook

**Cell Mapping**:
```kotlin
Row 7:  Header (name, date submitted)
Row 42+: Expense line items
  Column B: Date
  Column C: Merchant (From)
  Column D: Address (To)
  Column E: Description (Purpose)
  Column F: Amount (Local Currency)
  Column G: Exchange Rate
  Column H: Formula (USD Amount)
  Column M: Account Code
```

**Apache POI Usage**:
```kotlin
XSSFWorkbook        // Workbook container
Sheet               // Individual worksheet
Row                 // Row in sheet
Cell                // Individual cell
CellStyle           // Formatting
```

### 4. ReceiptData.kt
**Data Models**:
```kotlin
data class ReceiptData(
    merchantName: String,
    address: String,
    date: String,
    totalAmount: Double,
    items: List<LineItem>,
    taxAmount: Double,
    currency: String
)

data class LineItem(
    description: String,
    quantity: Double,
    unitPrice: Double,
    amount: Double
)
```

## Data Flow

### Receipt Processing Pipeline

```
1. Camera Capture
   └─> ImageCapture.takePicture()
       └─> JPG file saved to storage

2. Image to Bitmap
   └─> BitmapFactory.decodeFile()
       └─> Bitmap object

3. OCR Processing
   └─> ML Kit TextRecognizer
       └─> InputImage.fromBitmap()
       └─> recognizer.process()
       └─> Raw text string

4. Text Parsing
   └─> ReceiptParser.parseReceipt()
       └─> Regex pattern matching
       └─> ReceiptData object

5. Excel Generation
   └─> ExpenseReportProcessor.fillExpenseReport()
       └─> Load template from assets
       └─> Map data to cells
       └─> Save to storage
       └─> Excel file

6. Email Composition
   └─> Intent.ACTION_SEND_MULTIPLE
       └─> FileProvider URIs
       └─> Email draft with attachments
```

## Threading Model

### Main Thread (UI)
- UI updates
- User interactions
- Camera preview
- Activity lifecycle

### Background Thread (Coroutines)
- Image loading
- OCR processing
- Excel file I/O
- File operations

**Coroutine Structure**:
```kotlin
lifecycleScope.launch {
    // Main thread
    binding.tvStatus.text = "Processing..."
    
    // Switch to IO thread
    val result = withContext(Dispatchers.IO) {
        // Heavy work here
        processImage()
    }
    
    // Back to main thread
    binding.tvStatus.text = "Complete!"
}
```

## Memory Management

### Image Handling
- Capture at max quality
- Bitmap recycling after OCR
- File cleanup strategy
- Avoid memory leaks

### Excel Processing
- Stream-based reading for large files
- Close workbook after processing
- Input/output stream management

### Camera Resources
- Bind/unbind with lifecycle
- Release camera on pause
- Proper cleanup on destroy

## Error Handling

### Levels of Error Handling

**1. Permission Errors**
```kotlin
if (!checkPermissions()) {
    requestPermissions()
    return
}
```

**2. Camera Errors**
```kotlin
imageCapture.takePicture(
    ...,
    onError = { exc ->
        Toast.makeText("Capture failed")
        logError(exc)
    }
)
```

**3. OCR Errors**
```kotlin
try {
    val result = recognizer.process(image)
    // Success
} catch (e: Exception) {
    Toast.makeText("OCR failed")
    offerManualEntry()
}
```

**4. Excel Errors**
```kotlin
try {
    processor.fillExpenseReport()
} catch (e: IOException) {
    Toast.makeText("File error")
} catch (e: IllegalStateException) {
    Toast.makeText("Template issue")
}
```

**5. Email Errors**
```kotlin
try {
    startActivity(emailIntent)
} catch (e: ActivityNotFoundException) {
    Toast.makeText("No email app")
}
```

## Performance Optimization

### 1. Image Processing
- Use appropriate image size (not full resolution)
- Compress before OCR if needed
- Parallel processing where possible

### 2. OCR Optimization
- Process in background thread
- Show progress indicator
- Cache results if re-processing

### 3. Excel Operations
- Load template once
- Batch cell operations
- Avoid unnecessary reads

### 4. UI Responsiveness
- Debounce camera captures
- Use coroutines for async work
- Show loading states

## Security Considerations

### 1. File Access
```kotlin
// Use scoped storage (Android 10+)
getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS)

// FileProvider for sharing
FileProvider.getUriForFile(context, authority, file)
```

### 2. Permissions
```kotlin
// Request minimum necessary permissions
- CAMERA: Required
- WRITE_EXTERNAL_STORAGE: Only API < 29
```

### 3. Data Privacy
- No cloud uploads without consent
- Local-only processing
- Clear data policy

### 4. Intent Security
```kotlin
// Grant temporary URI permission
intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
```

## Testing Strategy

### Unit Tests
```kotlin
@Test
fun testReceiptParsing() {
    val text = "TOTAL 18,50 €"
    val result = ReceiptParser.extractTotal(listOf(text))
    assertEquals(18.50, result, 0.01)
}
```

### Integration Tests
```kotlin
@Test
fun testExcelGeneration() {
    val receiptData = createTestData()
    processor.fillExpenseReport(template, output, receiptData)
    val workbook = XSSFWorkbook(FileInputStream(output))
    assertEquals("Expected", workbook.getSheet(...).getRow(...).getCell(...).value)
}
```

### UI Tests
```kotlin
@Test
fun testCameraCapture() {
    onView(withId(R.id.btnCapture)).perform(click())
    // Verify image captured
}
```

## Logging & Debugging

### Debug Logging
```kotlin
private const val TAG = "MainActivity"

Log.d(TAG, "OCR text: $text")
Log.d(TAG, "Parsed data: $receiptData")
Log.e(TAG, "Error processing receipt", exception)
```

### Crashlytics Integration
```kotlin
FirebaseCrashlytics.getInstance().apply {
    setCustomKey("receipt_merchant", merchantName)
    setCustomKey("ocr_success", ocrSucceeded)
    recordException(exception)
}
```

## Configuration

### Build Variants
```kotlin
android {
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isDebuggable = true
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(...)
        }
    }
}
```

### Feature Flags
```kotlin
object Config {
    const val ENABLE_ANALYTICS = BuildConfig.DEBUG.not()
    const val ENABLE_CRASHLYTICS = BuildConfig.DEBUG.not()
    const val DEFAULT_CURRENCY = "EUR"
    const val MAX_RECEIPT_SIZE_MB = 5
}
```

## Future Enhancements

### Phase 2 (Short-term)
- Multiple currency support with live exchange rates
- Receipt history and archive
- Expense categories auto-detection
- Batch processing

### Phase 3 (Medium-term)
- Cloud sync (Google Drive, Dropbox)
- Receipt categorization ML model
- OCR accuracy improvements
- Multi-language support

### Phase 4 (Long-term)
- Web portal for expense management
- Manager approval workflow
- Budget tracking and alerts
- Advanced analytics

## Dependencies Version Management

### Keep Updated
```kotlin
// Check for updates regularly
- CameraX: Quarterly
- ML Kit: Quarterly  
- Apache POI: Semi-annually
- AndroidX: Monthly
```

### Breaking Changes
- Always test major version updates
- Review migration guides
- Update ProGuard rules
- Test on multiple API levels

---

**Last Updated**: February 15, 2026
**Architecture Version**: 1.0
**Maintained By**: Avant Development Team

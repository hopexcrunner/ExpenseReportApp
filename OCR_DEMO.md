# OCR Parsing Demonstration

This document demonstrates how the app would process the sample receipt (`sample_receipt.jpg`).

## Sample Receipt Details

**Image**: `sample_receipt.jpg`
**Establishment**: CAFE BAR LA PARADA (Burgos, Spain)

### Raw OCR Text (Simulated Output)
```
CAFE BAR LA PARADA
CAFE BAR LA PARADA
B42877647
CALLE MOLINO SALINAS N1
09007 Burgos
653537231

SUBTOTAL                           jacobo
( ORIGINAL )
08 feb. 2026 21:00                 Alexander

agua con gas
3.0 x 2,50 €                       7,50 €
Refrescos todos
5.0 x 2,20 €                       11,00 €

8 Articulos          TOTAL         18,50 €

Impuestos incluidos                Base    Cuota

                     IVA 21%    15,29 €   3,21 €
```

## Parsed Receipt Data

### ReceiptData Object
```kotlin
ReceiptData(
    merchantName = "CAFE BAR LA PARADA",
    address = "CALLE MOLINO SALINAS N1, 09007 Burgos",
    date = "08 feb. 2026",
    totalAmount = 18.50,
    currency = "EUR",
    taxAmount = 3.21,
    items = listOf(
        LineItem(
            description = "agua con gas",
            quantity = 3.0,
            unitPrice = 2.50,
            amount = 7.50
        ),
        LineItem(
            description = "Refrescos todos",
            quantity = 5.0,
            unitPrice = 2.20,
            amount = 11.00
        )
    )
)
```

## Excel Report Population

This data would populate the Avant Expense Report as follows:

### Header Section
- **Name** (C7): [To be filled by user]
- **Date Submitted** (G7): 02/15/2026 (current date)

### Expense Line Items Section (Starting Row 42)

**Row 42 (First Item)**
- Column A: 1
- Column B: 08/02/2026 (converted date)
- Column C: CAFE BAR LA PARADA
- Column D: CALLE MOLINO SALINAS N1, 09007 Burgos
- Column E: agua con gas
- Column F: 7.50 (local currency)
- Column G: 1.0 (exchange rate)
- Column H: =IF(F42>0,IF(G42>0, (F42*G42)...)) (formula calculates USD)
- Column M: 8464 - Meals & Entertainment

**Row 43 (Second Item)**
- Column A: 2
- Column B: 08/02/2026
- Column C: CAFE BAR LA PARADA
- Column D: CALLE MOLINO SALINAS N1, 09007 Burgos
- Column E: Refrescos todos
- Column F: 11.00
- Column G: 1.0
- Column H: [Formula]
- Column M: 8464 - Meals & Entertainment

### Totals
The Excel formulas will automatically calculate:
- Total USD Amount: €18.50
- Category totals in "Totals" sheet
- Balance due calculations

## Email Draft Content

**To**: finance@avant.org
**Subject**: Expense Report Submission
**Body**:
```
Please find attached:
1. Expense report
2. Original receipt

Merchant: CAFE BAR LA PARADA
Date: 08/02/2026
Amount: €18.50
Location: Burgos, Spain

Items:
- agua con gas (3.0 x €2.50): €7.50
- Refrescos todos (5.0 x €2.20): €11.00

Total: €18.50 (including €3.21 IVA)
```

**Attachments**:
1. `receipt_20260215_143022.jpg` (original photo)
2. `expense_report_20260215_143025.xlsx` (completed form)

## Parser Logic Breakdown

### Merchant Name Extraction
- **Pattern**: First non-numeric line at top of receipt
- **Extracted**: "CAFE BAR LA PARADA"
- **Confidence**: High (clear text at top)

### Date Extraction
- **Pattern**: `dd MMM yyyy` format detection
- **Input**: "08 feb. 2026"
- **Output**: "08/02/2026"
- **Confidence**: High (standard Spanish date format)

### Total Amount Extraction
- **Pattern**: "TOTAL" keyword followed by amount
- **Input**: "TOTAL 18,50 €"
- **Output**: 18.50
- **Confidence**: High (clear total line)

### Line Items Extraction
- **Pattern**: `description quantity x price amount`
- **Input Lines**:
  - "agua con gas 3.0 x 2,50 € 7,50 €"
  - "Refrescos todos 5.0 x 2,20 € 11,00 €"
- **Confidence**: High (standard format)

### Tax Extraction
- **Pattern**: "IVA" followed by percentage and amount
- **Input**: "IVA 21% 15,29 € 3,21 €"
- **Extracted**: 3.21
- **Confidence**: High (standard Spanish tax format)

## Accuracy Notes

### What Works Well
✓ Clear printed text
✓ Standard receipt format
✓ Good lighting in photo
✓ Flat receipt surface
✓ Standard quantity × price format

### Potential Issues
- Handwritten amounts would be less accurate
- Creased or folded receipts may have OCR errors
- Very faded receipts might not scan well
- Non-standard formats may need manual review

## User Workflow

1. **Capture**: User takes photo of receipt
2. **Processing**: 2-3 seconds for OCR + parsing
3. **Review**: User sees extracted data on screen
4. **Excel Generation**: Automatic population (1-2 seconds)
5. **Email Draft**: Ready to send
6. **Total Time**: ~5-10 seconds from capture to email

## Data Validation

The app performs basic validation:
- ✓ Date is valid format
- ✓ Amounts are numeric
- ✓ Total matches sum of items (within tolerance)
- ✓ Currency is recognized
- ⚠️ User should verify accuracy before sending

## Next Steps After Email

1. User reviews email draft
2. User can edit Excel file if needed
3. User sends email to finance department
4. Finance team receives:
   - Completed expense report
   - Original receipt for verification
   - All data pre-filled and ready to process

---

**Note**: This is a simulation based on the sample receipt. Actual OCR results may vary slightly based on image quality, lighting, and Google ML Kit's recognition accuracy.

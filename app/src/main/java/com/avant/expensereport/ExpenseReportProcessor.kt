package com.avant.expensereport

import org.apache.poi.ss.usermodel.*
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

class ExpenseReportProcessor {
    
    fun fillExpenseReport(templateFile: File, outputFile: File, receiptData: ReceiptData) {
        val inputStream = FileInputStream(templateFile)
        val workbook = XSSFWorkbook(inputStream)
        val sheet = workbook.getSheet("Expense Report")
        
        // Fill header information
        // Name field (C7)
        setCellValue(sheet, 6, 2, "Employee Name") // Row 7, Column C
        
        // Date submitted (G7)
        val currentDate = SimpleDateFormat("MM/dd/yyyy", Locale.US).format(Date())
        setCellValue(sheet, 6, 6, currentDate)
        
        // Add expense line item
        // The template has expense items starting at row 42 (index 41)
        // We'll add items in the "Travel" section or appropriate category
        
        val startRow = 41 // Row 42 in Excel (0-indexed)
        
        receiptData.items.forEachIndexed { index, item ->
            val row = startRow + index
            if (row < 129) { // Stay within the expense area (rows 42-129)
                // Date (Column B)
                setCellValue(sheet, row, 1, receiptData.date)
                
                // From/To/Purpose (Columns C, D, E)
                setCellValue(sheet, row, 2, receiptData.merchantName)
                setCellValue(sheet, row, 3, receiptData.address)
                setCellValue(sheet, row, 4, item.description)
                
                // Cost in Local Currency (Column F)
                setCellValue(sheet, row, 5, item.amount)
                
                // Exchange Rate (Column G) - 1.0 for same currency
                setCellValue(sheet, row, 6, 1.0)
                
                // USD amount will be calculated by formula in column H
                
                // Account Code (Column M) - Default to "8464 - Meals & Entertainment"
                // User can change this in Excel
                setCellValue(sheet, row, 12, "8464 - Meals & Entertainment")
            }
        }
        
        // Save the modified workbook
        val outputStream = FileOutputStream(outputFile)
        workbook.write(outputStream)
        outputStream.close()
        workbook.close()
        inputStream.close()
    }
    
    private fun setCellValue(sheet: Sheet, rowIndex: Int, columnIndex: Int, value: Any) {
        var row = sheet.getRow(rowIndex)
        if (row == null) {
            row = sheet.createRow(rowIndex)
        }
        
        var cell = row.getCell(columnIndex)
        if (cell == null) {
            cell = row.createCell(columnIndex)
        }
        
        when (value) {
            is String -> cell.setCellValue(value)
            is Double -> cell.setCellValue(value)
            is Int -> cell.setCellValue(value.toDouble())
            is Date -> {
                cell.setCellValue(value)
                val workbook = sheet.workbook
                val dateCellStyle = workbook.createCellStyle()
                val dateFormat = workbook.createDataFormat()
                dateCellStyle.dataFormat = dateFormat.getFormat("mm/dd/yyyy")
                cell.cellStyle = dateCellStyle
            }
        }
    }
}

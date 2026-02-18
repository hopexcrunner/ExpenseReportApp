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
        var inputStream: FileInputStream? = null
        var workbook: XSSFWorkbook? = null
        var outputStream: FileOutputStream? = null
        
        try {
            // Validate template file
            if (!templateFile.exists()) {
                throw IllegalArgumentException("Template file does not exist: ${templateFile.absolutePath}")
            }
            if (templateFile.length() == 0L) {
                throw IllegalArgumentException("Template file is empty")
            }
            
            // Validate receipt data
            if (receiptData.items.isEmpty()) {
                throw IllegalArgumentException("Receipt has no items to process")
            }
            
            inputStream = FileInputStream(templateFile)
            workbook = XSSFWorkbook(inputStream)
            
            // Validate workbook has sheets
            if (workbook.numberOfSheets == 0) {
                throw IllegalStateException("Excel template has no sheets")
            }
            
            // Try to get the sheet by name, fall back to first sheet if not found
            val sheet = workbook.getSheet("Expense Report") ?: workbook.getSheetAt(0)
                ?: throw IllegalStateException("No sheets found in Excel template")
            
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
            val maxRows = 129  // Maximum row in expense area
            var itemsProcessed = 0
            
            receiptData.items.forEachIndexed { index, item ->
                val row = startRow + index
                if (row < maxRows) {
                    try {
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
                        
                        itemsProcessed++
                    } catch (e: Exception) {
                        // Log error but continue with other items
                        System.err.println("Error processing item $index: ${e.message}")
                    }
                } else {
                    System.err.println("Warning: Exceeded maximum rows. ${receiptData.items.size - itemsProcessed} items not added.")
                    return@forEachIndexed
                }
            }
            
            if (itemsProcessed == 0) {
                throw IllegalStateException("No items were successfully added to the expense report")
            }
            
            // Ensure output directory exists
            outputFile.parentFile?.mkdirs()
            
            // Save the modified workbook
            outputStream = FileOutputStream(outputFile)
            workbook.write(outputStream)
            outputStream.flush()
            
        } catch (e: Exception) {
            // Re-throw with more context
            throw RuntimeException("Failed to create expense report: ${e.message}", e)
        } finally {
            // Ensure all resources are closed properly
            try {
                outputStream?.close()
            } catch (e: Exception) {
                System.err.println("Error closing output stream: ${e.message}")
            }
            try {
                workbook?.close()
            } catch (e: Exception) {
                System.err.println("Error closing workbook: ${e.message}")
            }
            try {
                inputStream?.close()
            } catch (e: Exception) {
                System.err.println("Error closing input stream: ${e.message}")
            }
        }
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

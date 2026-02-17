package com.avant.expensereport

import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

object ReceiptParser {
    
    fun parseReceipt(text: String): ReceiptData {
        val lines = text.split("\n").map { it.trim() }.filter { it.isNotEmpty() }
        
        // Extract merchant name (usually first few lines)
        val merchantName = extractMerchantName(lines)
        
        // Extract address
        val address = extractAddress(lines)
        
        // Extract date
        val date = extractDate(lines)
        
        // Extract total amount
        val totalAmount = extractTotal(lines)
        
        // Extract line items
        val items = extractLineItems(lines)
        
        // Extract tax
        val taxAmount = extractTax(lines)
        
        return ReceiptData(
            merchantName = merchantName,
            address = address,
            date = date,
            totalAmount = totalAmount,
            items = items,
            taxAmount = taxAmount
        )
    }
    
    private fun extractMerchantName(lines: List<String>): String {
        // Usually the first non-empty line or lines with establishment name
        for (line in lines.take(5)) {
            if (line.length > 5 && !line.contains(Regex("\\d{5,}"))) {
                return line
            }
        }
        return lines.firstOrNull() ?: "Unknown"
    }
    
    private fun extractAddress(lines: List<String>): String {
        // Look for address patterns (street, postal code, city)
        val addressPattern = Pattern.compile(
            ".*(calle|street|st\\.|avenue|ave\\.|road|rd\\.).*",
            Pattern.CASE_INSENSITIVE
        )
        
        for (line in lines.take(10)) {
            if (addressPattern.matcher(line).matches() || 
                line.matches(Regex(".*\\d{5}.*"))) {
                return line
            }
        }
        return ""
    }
    
    private fun extractDate(lines: List<String>): String {
        // Look for date patterns
        val datePatterns = listOf(
            Pattern.compile("(\\d{1,2}[/\\-.]\\d{1,2}[/\\-.]\\d{2,4})"),
            Pattern.compile("(\\d{1,2}\\s+(?:ene|feb|mar|abr|may|jun|jul|ago|sep|oct|nov|dic)\\.?\\s+\\d{4})", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(\\d{1,2}\\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\\.?\\s+\\d{4})", Pattern.CASE_INSENSITIVE)
        )
        
        for (line in lines) {
            for (pattern in datePatterns) {
                val matcher = pattern.matcher(line)
                if (matcher.find()) {
                    return matcher.group(1) ?: line
                }
            }
        }
        
        // Fallback: use current date
        return SimpleDateFormat("dd/MM/yyyy", Locale.US).format(Date())
    }
    
    private fun extractTotal(lines: List<String>): Double {
        // Look for TOTAL keyword followed by amount
        val totalPattern = Pattern.compile(
            "(?:total|suma|amount).*?(\\d+[,.]\\d{2})\\s*€?",
            Pattern.CASE_INSENSITIVE
        )
        
        // Start from the end as total is usually at the bottom
        for (line in lines.reversed().take(15)) {
            val matcher = totalPattern.matcher(line)
            if (matcher.find()) {
                val amountStr = matcher.group(1)?.replace(",", ".") ?: "0.0"
                return amountStr.toDoubleOrNull() ?: 0.0
            }
        }
        
        // Fallback: look for largest amount
        var maxAmount = 0.0
        val amountPattern = Pattern.compile("(\\d+[,.]\\d{2})\\s*€")
        
        for (line in lines) {
            val matcher = amountPattern.matcher(line)
            while (matcher.find()) {
                val amount = matcher.group(1)?.replace(",", ".")?.toDoubleOrNull() ?: 0.0
                if (amount > maxAmount) {
                    maxAmount = amount
                }
            }
        }
        
        return maxAmount
    }
    
    private fun extractLineItems(lines: List<String>): List<LineItem> {
        val items = mutableListOf<LineItem>()
        
        // Pattern: description followed by quantity x price = amount
        val itemPattern = Pattern.compile(
            "(.+?)\\s+(\\d+[,.]?\\d*)\\s*x\\s*(\\d+[,.]\\d{2})\\s*€?\\s*(\\d+[,.]\\d{2})?\\s*€?",
            Pattern.CASE_INSENSITIVE
        )
        
        for (line in lines) {
            val matcher = itemPattern.matcher(line)
            if (matcher.find()) {
                val description = matcher.group(1)?.trim() ?: continue
                val quantity = matcher.group(2)?.replace(",", ".")?.toDoubleOrNull() ?: 1.0
                val unitPrice = matcher.group(3)?.replace(",", ".")?.toDoubleOrNull() ?: 0.0
                val amount = matcher.group(4)?.replace(",", ".")?.toDoubleOrNull() 
                    ?: (quantity * unitPrice)
                
                items.add(
                    LineItem(
                        description = description,
                        quantity = quantity,
                        unitPrice = unitPrice,
                        amount = amount
                    )
                )
            }
        }
        
        // If no items found, create a default item with the total amount
        if (items.isEmpty()) {
            items.add(
                LineItem(
                    description = "Receipt items",
                    quantity = 1.0,
                    unitPrice = 0.0,
                    amount = 0.0
                )
            )
        }
        
        return items
    }
    
    private fun extractTax(lines: List<String>): Double {
        val taxPattern = Pattern.compile(
            "(?:IVA|VAT|tax).*?(\\d+[,.]\\d{2})\\s*€?",
            Pattern.CASE_INSENSITIVE
        )
        
        for (line in lines.reversed().take(10)) {
            val matcher = taxPattern.matcher(line)
            if (matcher.find()) {
                val amountStr = matcher.group(1)?.replace(",", ".") ?: "0.0"
                return amountStr.toDoubleOrNull() ?: 0.0
            }
        }
        
        return 0.0
    }
}

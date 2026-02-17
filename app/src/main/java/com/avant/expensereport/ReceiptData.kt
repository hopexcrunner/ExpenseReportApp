package com.avant.expensereport

data class ReceiptData(
    val merchantName: String,
    val address: String,
    val date: String,
    val totalAmount: Double,
    val items: List<LineItem>,
    val taxAmount: Double = 0.0,
    val currency: String = "EUR"
)

data class LineItem(
    val description: String,
    val quantity: Double,
    val unitPrice: Double,
    val amount: Double
)

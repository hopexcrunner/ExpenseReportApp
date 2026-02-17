package com.avant.expensereport

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.lifecycle.lifecycleScope
import com.avant.expensereport.databinding.ActivityMainBinding
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private var imageCapture: ImageCapture? = null
    private lateinit var outputDirectory: File
    private var capturedImageFile: File? = null
    
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        if (permissions[Manifest.permission.CAMERA] == true) {
            startCamera()
        } else {
            Toast.makeText(this, "Camera permission required", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        outputDirectory = getOutputDirectory()
        
        if (checkPermissions()) {
            startCamera()
        } else {
            requestPermissions()
        }
        
        binding.btnCapture.setOnClickListener {
            takePhoto()
        }
    }
    
    private fun checkPermissions(): Boolean {
        val cameraPermission = ContextCompat.checkSelfPermission(
            this, Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        
        // For Android 13+ (API 33+), we don't need storage permissions for our use case
        // because we're using app-specific directories (getExternalFilesDir, filesDir)
        return cameraPermission
    }
    
    private fun requestPermissions() {
        val permissionsToRequest = mutableListOf(Manifest.permission.CAMERA)
        
        // Only request storage permissions on Android 12 and below
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2) {
            permissionsToRequest.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                permissionsToRequest.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            }
        }
        
        requestPermissionLauncher.launch(permissionsToRequest.toTypedArray())
    }
    
    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            
            val preview = Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(binding.viewFinder.surfaceProvider)
                }
            
            imageCapture = ImageCapture.Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
                .build()
            
            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
            
            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this, cameraSelector, preview, imageCapture
                )
            } catch (e: Exception) {
                Toast.makeText(this, "Camera binding failed: ${e.message}", 
                    Toast.LENGTH_SHORT).show()
            }
        }, ContextCompat.getMainExecutor(this))
    }
    
    private fun takePhoto() {
        val imageCapture = imageCapture ?: return
        
        val photoFile = File(
            outputDirectory,
            "receipt_${SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US)
                .format(System.currentTimeMillis())}.jpg"
        )
        
        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()
        
        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    capturedImageFile = photoFile
                    processImage(photoFile)
                }
                
                override fun onError(exc: ImageCaptureException) {
                    Toast.makeText(
                        this@MainActivity,
                        "Photo capture failed: ${exc.message}",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
        )
    }
    
    private fun processImage(imageFile: File) {
        binding.tvStatus.text = "Processing receipt..."
        
        lifecycleScope.launch {
            try {
                // Verify the file exists and is readable
                if (!imageFile.exists()) {
                    throw Exception("Image file does not exist: ${imageFile.absolutePath}")
                }
                
                // Decode bitmap on IO thread to avoid StrictMode violations on Android 13+
                // Also optimize bitmap size to prevent OutOfMemoryError
                val bitmap = withContext(Dispatchers.IO) {
                    val options = BitmapFactory.Options().apply {
                        // First decode to get dimensions
                        inJustDecodeBounds = true
                    }
                    BitmapFactory.decodeFile(imageFile.absolutePath, options)
                    
                    // Calculate inSampleSize to reduce memory usage
                    // Max dimension for OCR: 2048px is sufficient
                    val maxDimension = 2048
                    options.inSampleSize = calculateInSampleSize(options, maxDimension, maxDimension)
                    options.inJustDecodeBounds = false
                    
                    // Now decode the actual bitmap
                    BitmapFactory.decodeFile(imageFile.absolutePath, options)
                }
                
                if (bitmap == null) {
                    throw Exception("Failed to decode image file")
                }
                
                val receiptData = extractTextFromImage(bitmap)
                
                // Clean up bitmap to free memory
                bitmap.recycle()
                
                withContext(Dispatchers.Main) {
                    binding.tvStatus.text = "Receipt processed!"
                    displayReceiptData(receiptData)
                    
                    // Copy template and fill it
                    fillExpenseReport(receiptData, imageFile)
                }
            } catch (e: Exception) {
                e.printStackTrace() // Log to logcat
                withContext(Dispatchers.Main) {
                    binding.tvStatus.text = "Error: ${e.message}"
                    Toast.makeText(
                        this@MainActivity,
                        "Processing failed: ${e.message}",
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }
    
    private fun calculateInSampleSize(
        options: BitmapFactory.Options,
        reqWidth: Int,
        reqHeight: Int
    ): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1
        
        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            
            while (halfHeight / inSampleSize >= reqHeight && 
                   halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        
        return inSampleSize
    }
    
    private suspend fun extractTextFromImage(bitmap: Bitmap): ReceiptData = 
        withContext(Dispatchers.IO) {
            try {
                val image = InputImage.fromBitmap(bitmap, 0)
                val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                
                val result = com.google.android.gms.tasks.Tasks.await(
                    recognizer.process(image)
                )
                
                val text = result.text
                
                if (text.isBlank()) {
                    throw Exception("No text detected in image. Please try again with better lighting.")
                }
                
                ReceiptParser.parseReceipt(text)
            } catch (e: com.google.android.gms.common.api.ApiException) {
                // ML Kit specific error
                throw Exception("ML Kit error: ${e.message}. Please ensure Google Play Services is updated.")
            } catch (e: Exception) {
                // Re-throw with more context
                throw Exception("Text extraction failed: ${e.message}", e)
            }
        }
    
    private fun displayReceiptData(data: ReceiptData) {
        val info = buildString {
            append("Merchant: ${data.merchantName}\n")
            append("Date: ${data.date}\n")
            append("Amount: €${data.totalAmount}\n")
            append("\nItems:\n")
            data.items.forEach { item ->
                append("- ${item.description}: €${item.amount}\n")
            }
        }
        binding.tvReceiptInfo.text = info
    }
    
    private fun fillExpenseReport(receiptData: ReceiptData, receiptImage: File) {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                // Copy template from assets
                val templateFile = File(filesDir, "expense_template.xlsx")
                
                // Check if asset exists
                val assetList = assets.list("") ?: emptyArray()
                if (!assetList.contains("Avant_2026_Expense_Report_Form.xlsx")) {
                    throw Exception("Template file not found in assets")
                }
                
                assets.open("Avant_2026_Expense_Report_Form.xlsx").use { input ->
                    FileOutputStream(templateFile).use { output ->
                        input.copyTo(output)
                    }
                }
                
                val outputFile = File(
                    outputDirectory,
                    "expense_report_${SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US)
                        .format(System.currentTimeMillis())}.xlsx"
                )
                
                val processor = ExpenseReportProcessor()
                processor.fillExpenseReport(templateFile, outputFile, receiptData)
                
                withContext(Dispatchers.Main) {
                    binding.tvStatus.text = "Expense report created!"
                    createEmailDraft(receiptImage, outputFile)
                }
            } catch (e: Exception) {
                e.printStackTrace() // Log to logcat
                withContext(Dispatchers.Main) {
                    binding.tvStatus.text = "Error creating report: ${e.message}"
                    Toast.makeText(
                        this@MainActivity,
                        "Failed to create report: ${e.message}",
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }
    
    private fun createEmailDraft(receiptImage: File, expenseReport: File) {
        val receiptUri = FileProvider.getUriForFile(
            this,
            "${packageName}.fileprovider",
            receiptImage
        )
        
        val reportUri = FileProvider.getUriForFile(
            this,
            "${packageName}.fileprovider",
            expenseReport
        )
        
        val emailIntent = Intent(Intent.ACTION_SEND_MULTIPLE).apply {
            type = "message/rfc822"
            putExtra(Intent.EXTRA_EMAIL, arrayOf("finance@avant.org"))
            putExtra(Intent.EXTRA_SUBJECT, "Expense Report Submission")
            putExtra(Intent.EXTRA_TEXT, buildString {
                append("Please find attached:\n")
                append("1. Expense report\n")
                append("2. Original receipt\n\n")
                append("Merchant: ${binding.tvReceiptInfo.text}\n")
            })
            
            val attachments = ArrayList<Uri>()
            attachments.add(receiptUri)
            attachments.add(reportUri)
            putParcelableArrayListExtra(Intent.EXTRA_STREAM, attachments)
            
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        
        try {
            startActivity(Intent.createChooser(emailIntent, "Send expense report via:"))
        } catch (e: Exception) {
            Toast.makeText(
                this,
                "No email app found",
                Toast.LENGTH_SHORT
            ).show()
        }
    }
    
    private fun getOutputDirectory(): File {
        // Use app-specific directory that doesn't require storage permissions
        // This works on all Android versions including Android 13+
        val mediaDir = getExternalFilesDir(null)?.let {
            File(it, resources.getString(R.string.app_name)).apply { mkdirs() }
        }
        return if (mediaDir != null && mediaDir.exists()) mediaDir else filesDir
    }
}

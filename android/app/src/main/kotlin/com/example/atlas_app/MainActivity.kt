package com.example.atlas_app

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.avif_converter"  // Match exactly with Dart side
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Configuring Flutter engine and setting up AVIF converter channel")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "convertToAvif" -> {
                    val inputPath = call.argument<String>("inputPath")
                    val outputPath = call.argument<String>("outputPath")
                    val quality = call.argument<Int>("quality") ?: 70
                    
                    Log.d(TAG, "Received convertToAvif call: input=$inputPath, output=$outputPath, quality=$quality")
                    
                    if (inputPath == null || outputPath == null) {
                        Log.e(TAG, "Invalid arguments: input or output path is null")
                        result.error("INVALID_ARGUMENTS", "Input path and output path must not be null", null)
                        return@setMethodCallHandler
                    }
                    
                    // Check if the input file exists
                    val inputFile = java.io.File(inputPath)
                    if (!inputFile.exists()) {
                        Log.e(TAG, "Input file does not exist: $inputPath")
                        result.error("FILE_NOT_FOUND", "Input file does not exist", null)
                        return@setMethodCallHandler
                    }
                    
                    GlobalScope.launch {
                        try {
                            val converter = AvifConverter(context)
                            val success = converter.convertToAvif(inputPath, outputPath, quality)
                            
                            withContext(Dispatchers.Main) {
                                if (success && java.io.File(outputPath).exists()) {
                                    Log.d(TAG, "AVIF conversion successful")
                                    result.success(true)
                                } else {
                                    Log.e(TAG, "AVIF conversion failed or output file doesn't exist")
                                    result.success(false)  // Return false to allow fallback
                                }
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Exception during AVIF conversion: ${e.message}", e)
                            withContext(Dispatchers.Main) {
                                result.success(false)  // Return false to allow fallback
                            }
                        }
                    }
                }
                else -> {
                    Log.d(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
}
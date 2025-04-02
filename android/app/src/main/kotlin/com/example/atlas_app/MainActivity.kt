package com.example.atlas_app

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.avif_converter"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "convertToAvif" -> {
                    val inputPath = call.argument<String>("inputPath")
                    val outputPath = call.argument<String>("outputPath")
                    val quality = call.argument<Int>("quality") ?: 70

                    if (inputPath == null || outputPath == null) {
                        result.error("INVALID_ARGUMENTS", "Input path and output path must not be null", null)
                        return@setMethodCallHandler
                    }

                    GlobalScope.launch {
                        try {
                            val converter = AvifConverter(context)
                            val success = converter.convertToAvif(inputPath, outputPath, quality)
                            withContext(Dispatchers.Main) {
                                result.success(success)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("CONVERSION_FAILED", "Failed to convert image to AVIF: ${e.message}", null)
                            }
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
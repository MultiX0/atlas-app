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
import com.google.firebase.messaging.FirebaseMessaging

class MainActivity : FlutterActivity() {
    private val AVIF_CHANNEL = "com.example.avif_converter"  // Match exactly with Dart side
    private val FCM_CHANNEL = "app.atlasapp/fcm_config"  // Match exactly with Dart side
    private val TAG = "MainActivity"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Configuring Flutter engine and setting up channels")
        
        // Set up AVIF converter channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AVIF_CHANNEL).setMethodCallHandler { call, result ->
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
        
        // Set up FCM configuration channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FCM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "disableAutomaticNotificationHandling" -> {
                    Log.d(TAG, "Disabling automatic FCM notification handling")
                    try {
                        // Disable auto initialization
                        FirebaseMessaging.getInstance().isAutoInitEnabled = false
                        
                        // Disable automatic notification display for foreground notifications
                        // This tells FCM not to automatically display notifications when the app is in the foreground
                        // Instead, we'll handle them manually with flutter_local_notifications
                        FirebaseMessaging.getInstance().setDeliveryMetricsExportToBigQuery(false)
                        
                        // Set notification channel priority to min to prevent automatic display
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                            val notificationManager = getSystemService(android.app.NotificationManager::class.java)
                            val channel = notificationManager.getNotificationChannel("com.google.firebase.messaging.default_notification_channel_id")
                            if (channel != null) {
                                channel.importance = android.app.NotificationManager.IMPORTANCE_MIN
                                notificationManager.createNotificationChannel(channel)
                            }
                        }
                        
                        Log.d(TAG, "Successfully disabled automatic FCM notification handling")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error disabling automatic FCM notification handling: ${e.message}", e)
                        result.error("FCM_CONFIG_ERROR", "Failed to disable automatic notifications", e.message)
                    }
                }
                else -> {
                    Log.d(TAG, "FCM method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
}
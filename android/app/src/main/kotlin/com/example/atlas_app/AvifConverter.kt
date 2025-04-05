package com.example.atlas_app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.radzivon.bartoshyk.avif.coder.HeifCoder // Correct import
import java.io.File

class AvifConverter(private val context: Context) {
    private val TAG = "AvifConverter"

    fun convertToAvif(inputPath: String, outputPath: String, quality: Int): Boolean {
        try {
            Log.d(TAG, "Starting AVIF conversion: $inputPath -> $outputPath")

            // Load the bitmap from the input file
            val options = BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
            }
            val bitmap = BitmapFactory.decodeFile(inputPath, options)
            if (bitmap == null) {
                Log.e(TAG, "Failed to decode bitmap from $inputPath")
                return false
            }

            Log.d(TAG, "Bitmap loaded: ${bitmap.width}x${bitmap.height}")

            // Create the output directory if it doesn’t exist
            val outputFile = File(outputPath)
            outputFile.parentFile?.mkdirs()

            // Encode to AVIF using HeifCoder
            val heifCoder = HeifCoder()
            val avifBytes = heifCoder.encodeAvif(bitmap, quality = quality) // Use quality parameter
            if (avifBytes.isEmpty()) {
                Log.e(TAG, "AVIF encoding failed: empty byte array")
                bitmap.recycle()
                return false
            }

            // Write the encoded bytes to the output file
            outputFile.writeBytes(avifBytes)

            Log.d(TAG, "AVIF conversion completed successfully")
            bitmap.recycle()
            return outputFile.exists()
        } catch (e: Exception) {
            Log.e(TAG, "Error converting to AVIF: ${e.message}", e)
            return false
        }
    }
}
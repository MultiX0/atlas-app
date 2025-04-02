package com.example.atlas_app
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class AvifConverter(private val context: Context) {
    @Throws(IOException::class)
    fun convertToAvif(inputPath: String, outputPath: String, quality: Int): Boolean {
        try {
            // Load the image
            val bitmap = BitmapFactory.decodeFile(inputPath)
                ?: throw IOException("Failed to decode input image")
                
            // Create output directory if it doesn't exist
            val outputFile = File(outputPath)
            outputFile.parentFile?.mkdirs()
            
            // Use the class by its fully-qualified name
            val heifCoderClass = Class.forName("com.awxkee.avifcoder.HeifCoder")
            val heifCoder = heifCoderClass.getDeclaredConstructor().newInstance()
            
            // Get the encodeAvif method
            val encodeMethod = heifCoderClass.getMethod("encodeAvif", Bitmap::class.java, Int::class.java)
            val avifData = encodeMethod.invoke(heifCoder, bitmap, quality) as ByteArray
            
            // Save the AVIF data to file
            FileOutputStream(outputFile).use { fos ->
                fos.write(avifData)
            }
            
            // Clean up
            bitmap.recycle()
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }
}
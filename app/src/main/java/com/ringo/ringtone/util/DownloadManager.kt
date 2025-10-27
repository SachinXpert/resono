package com.ringo.ringtone.util

import android.content.Context
import android.os.Environment
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.net.URL

class DownloadManager {
    companion object {
        private const val TAG = "DownloadManager"
        
        fun downloadRingtone(
            context: Context,
            ringtoneUrl: String,
            title: String,
            onProgress: (Int) -> Unit,
            onComplete: (Boolean, String?) -> Unit
        ) {
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    // Create directory for ringtones if it doesn't exist
                    val directory = File(context.getExternalFilesDir(Environment.DIRECTORY_RINGTONES), "Ringo")
                    if (!directory.exists()) {
                        directory.mkdirs()
                    }
                    
                    // Create file
                    val fileName = "$title.mp3"
                    val file = File(directory, fileName)
                    
                    // Download the file
                    val url = URL(ringtoneUrl)
                    val connection = url.openConnection()
                    val contentLength = connection.contentLength
                    
                    connection.getInputStream().use { input ->
                        FileOutputStream(file).use { output ->
                            val buffer = ByteArray(1024)
                            var totalBytesRead = 0
                            var bytesRead: Int
                            
                            while (input.read(buffer).also { bytesRead = it } != -1) {
                                output.write(buffer, 0, bytesRead)
                                totalBytesRead += bytesRead
                                
                                // Calculate progress
                                if (contentLength > 0) {
                                    val progress = (totalBytesRead * 100) / contentLength
                                    withContext(Dispatchers.Main) {
                                        onProgress(progress)
                                    }
                                }
                            }
                        }
                    }
                    
                    withContext(Dispatchers.Main) {
                        onComplete(true, file.absolutePath)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error downloading ringtone", e)
                    withContext(Dispatchers.Main) {
                        onComplete(false, e.message)
                    }
                }
            }
        }
    }
}
package com.dd.resono

import android.content.ContentValues
import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import java.nio.ByteBuffer

import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "ringo/ringtone_manager"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setRingtone") {
                val path = call.argument<String>("path")
                val type = call.argument<String>("type")
                if (path != null && type != null) {
                    val success = setRingtone(path, type)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "Path or Type is null", null)
                }
            } else if (call.method == "setRingtoneForContact") {
                val path = call.argument<String>("path")
                val contactUri = call.argument<String>("contactUri")
                if (path != null && contactUri != null) {
                    val success = setRingtoneForContact(path, contactUri)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "Path or ContactUri is null", null)
                }
            } else if (call.method == "saveToMusic") {
                val path = call.argument<String>("path")
                val title = call.argument<String>("title")
                if (path != null && title != null) {
                     val savedPath = saveToMusic(path, title)
                     if (savedPath != null) {
                         result.success(savedPath)
                     } else {
                         result.error("SAVE_FAILED", "Failed to save to Music", null)
                     }
                } else {
                     result.error("INVALID_ARGUMENT", "Path or Title is null", null)
                }
            } else if (call.method == "trimAudio") {
                val path = call.argument<String>("inputPath")
                val outPath = call.argument<String>("outputPath")
                val start = call.argument<Double>("start")
                val end = call.argument<Double>("end")
                if (path != null && outPath != null && start != null && end != null) {
                    try {
                        val res = trimAudio(path, outPath, start, end)
                        result.success(res)
                    } catch (e: Exception) {
                         result.error("TRIM_FAILED", e.message, null)
                    }
                } else {
                    result.error("ARGS", "Missing args", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // Throws Exception on failure
    private fun trimAudio(inputPath: String, outputPath: String, startSec: Double, endSec: Double): String {
        val file = File(inputPath)
        if (!file.exists()) {
             throw Exception("Input file does not exist: $inputPath")
        }

        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(file.absolutePath)
        } catch (e: IOException) {
            throw Exception("Failed to set data source: ${e.message}")
        }

        val trackCount = extractor.trackCount
        var audioTrackIndex = -1
        var mimeType = ""
        
        for (i in 0 until trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME)
            if (mime?.startsWith("audio/") == true) {
                audioTrackIndex = i
                mimeType = mime
                extractor.selectTrack(audioTrackIndex)
                break 
            }
        }

        if (audioTrackIndex == -1) {
            extractor.release()
            throw Exception("No audio track found in file")
        }

        val startUs = (startSec * 1000000).toLong()
        val endUs = (endSec * 1000000).toLong()
        
        extractor.seekTo(startUs, MediaExtractor.SEEK_TO_PREVIOUS_SYNC)

        // logic branching based on MIME
        // MP3 (audio/mpeg) cannot be muxed into MP4 by standard MediaMuxer reliably on all devices 
        // without re-encoding or strict profile checks. 
        // But MP3 is streamable, so we can just write raw bytes.

        val isMp3 = mimeType == "audio/mpeg"
        
        var muxer: MediaMuxer? = null
        var trackIndex = -1
        var fos: java.io.FileOutputStream? = null
        
        if (isMp3) {
            // RAW WRITE STRATEGY
            fos = java.io.FileOutputStream(outputPath)
        } else {
            // MUXER STRATEGY (e.g. AAC inside MP4 container)
            muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            try {
               trackIndex = muxer.addTrack(extractor.getTrackFormat(audioTrackIndex))
            } catch(e: Exception) {
               extractor.release()
               throw Exception("Muxer addTrack failed: ${e.message}. Format not supported.")
            }
            muxer.start()
        }

        val buffer = ByteBuffer.allocate(2 * 1024 * 1024) 
        val bufferInfo = MediaCodec.BufferInfo()

        var firstSampleTimeUs: Long = -1
        var framesWritten = 0

        try {
            val byteBufferArray = ByteArray(buffer.capacity())

            while (true) {
                 bufferInfo.size = extractor.readSampleData(buffer, 0)
                 if (bufferInfo.size < 0) {
                     break
                 }

                 bufferInfo.presentationTimeUs = extractor.sampleTime
                 bufferInfo.flags = extractor.sampleFlags

                 if (bufferInfo.presentationTimeUs > endUs) {
                     break
                 }

                 if (bufferInfo.presentationTimeUs >= startUs) {
                     if (firstSampleTimeUs == -1L) {
                         firstSampleTimeUs = bufferInfo.presentationTimeUs
                     }
                     
                     if (isMp3) {
                         // Direct write
                         // Read bytes from buffer
                         buffer.get(byteBufferArray, 0, bufferInfo.size)
                         fos?.write(byteBufferArray, 0, bufferInfo.size)
                         buffer.clear() // Ready for next read
                     } else {
                         // Muxer write
                         bufferInfo.presentationTimeUs -= firstSampleTimeUs
                         if (bufferInfo.presentationTimeUs < 0) bufferInfo.presentationTimeUs = 0
                         muxer?.writeSampleData(trackIndex, buffer, bufferInfo)
                     }
                     framesWritten++
                 }

                 extractor.advance()
            }
        } catch (e: Exception) {
             try { muxer?.stop(); muxer?.release() } catch (e:Exception) {}
             try { fos?.close() } catch (e:Exception) {}
             extractor.release()
             throw Exception("Muxing/Writing loop failed: ${e.message}")
        }

        try {
            if (isMp3) {
                fos?.flush()
                fos?.close()
            } else {
                if (framesWritten > 0) {
                    muxer?.stop()
                }
                muxer?.release()
            }
        } catch (e: Exception) {
            extractor.release()
            throw Exception("Finalizing output failed: ${e.message}")
        }
        
        extractor.release()

        if (framesWritten == 0) throw Exception("No frames written. Check start/end times.")
        
        return outputPath
    }

    private fun saveToMusic(path: String, title: String): String? {
        val file = File(path)
        if (!file.exists()) return null

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, title)
            put(MediaStore.MediaColumns.MIME_TYPE, "audio/mpeg")
            put(MediaStore.Audio.Media.IS_MUSIC, true)
            // Save to "Music/Ringo Ringtones"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_MUSIC + "/Ringo Ringtones")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }
        
        var newUri: Uri? = null
        try {
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }
            
            newUri = context.contentResolver.insert(collection, values)
            
            if (newUri != null) {
                context.contentResolver.openOutputStream(newUri).use { os ->
                    FileInputStream(file).use { `is` ->
                        if (os != null) {
                            `is`.copyTo(os)
                        }
                    }
                }
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    values.clear()
                    values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                    context.contentResolver.update(newUri, values, null, null)
                }
                
                // Return the real path if possible, or just the URI string
                // Ideally return the path so we can show it, but for MediaStore URIs paths are tricky.
                // We'll return a user-friendly string.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    return Environment.DIRECTORY_MUSIC + "/Ringo Ringtones/" + title
                } else {
                     // For older versions, we probably saved it directly or need to query _DATA.
                     // But let's return a success message or the relative path.
                     return "/Music/Ringo Ringtones/" + title
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
        return null
    }

    private fun setRingtoneForContact(path: String, contactUriString: String): Boolean {
         if (!Settings.System.canWrite(context)) {
             // Request permission
             val intent = android.content.Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
             intent.data = Uri.parse("package:$packageName")
             intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
             context.startActivity(intent)
             return false
        }

        val file = File(path)
        if (!file.exists()) return false
        
        // 1. Copy to MediaStore to get a content:// URI
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
            put(MediaStore.MediaColumns.MIME_TYPE, "audio/mpeg")
            put(MediaStore.Audio.Media.IS_RINGTONE, true)
            put(MediaStore.Audio.Media.IS_MUSIC, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }

        var newUri: Uri? = null
        try {
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }
            newUri = context.contentResolver.insert(collection, values)
            
            if (newUri != null) {
                context.contentResolver.openOutputStream(newUri).use { os ->
                    FileInputStream(file).use { `is` ->
                        if (os != null) {
                            `is`.copyTo(os)
                        }
                    }
                }
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    values.clear()
                    values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                    context.contentResolver.update(newUri, values, null, null)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
        
        if (newUri == null) return false

        // 2. Set as Custom Ringtone for Contact
        try {
            val contactUri = Uri.parse(contactUriString)
            val valuesContact = ContentValues()
            valuesContact.put(android.provider.ContactsContract.Contacts.CUSTOM_RINGTONE, newUri.toString())
            
            // We need to update the contact
            // Note: contactUri usually looks like content://com.android.contacts/contacts/lookup/xxxx/id
            // We can try updating it directly.
            
            val rowsUpdated = context.contentResolver.update(contactUri, valuesContact, null, null)
            return rowsUpdated > 0
            
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun setRingtone(path: String, typeIdx: String): Boolean {
        if (!Settings.System.canWrite(context)) {
             val intent = android.content.Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
             intent.data = Uri.parse("package:$packageName")
             intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
             context.startActivity(intent)
             return false
        }

        val file = File(path)
        if (!file.exists()) return false

        try {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
                put(MediaStore.MediaColumns.MIME_TYPE, "audio/mpeg")
                put(MediaStore.Audio.Media.IS_RINGTONE, typeIdx == "ringtone")
                put(MediaStore.Audio.Media.IS_NOTIFICATION, typeIdx == "notification")
                put(MediaStore.Audio.Media.IS_ALARM, typeIdx == "alarm")
                put(MediaStore.Audio.Media.IS_MUSIC, true)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
            }

            // Insert into MediaStore
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }

            val newUri = context.contentResolver.insert(collection, values) ?: return false

            // Copy file content
            context.contentResolver.openOutputStream(newUri).use { os ->
                FileInputStream(file).use { `is` ->
                    if (os != null) {
                        `is`.copyTo(os)
                    }
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                context.contentResolver.update(newUri, values, null, null)
            }

            // Set as Ringtone
            val ringtoneType = when (typeIdx) {
                "ringtone" -> RingtoneManager.TYPE_RINGTONE
                "notification" -> RingtoneManager.TYPE_NOTIFICATION
                "alarm" -> RingtoneManager.TYPE_ALARM
                else -> RingtoneManager.TYPE_RINGTONE
            }
            RingtoneManager.setActualDefaultRingtoneUri(context, ringtoneType, newUri)
            return true

        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }
}

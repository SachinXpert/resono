package com.ringo.ringtone.util

import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.net.URL

class RingtoneManager {
    companion object {
        private const val TAG = "RingtoneManager"
        
        fun setAsRingtone(context: Context, ringtoneUrl: String, title: String) {
            try {
                // Download the ringtone file
                val fileName = "$title.mp3"
                val file = File(context.getExternalFilesDir(null), fileName)
                
                // Download the file
                URL(ringtoneUrl).openStream().use { input ->
                    FileOutputStream(file).use { output ->
                        input.copyTo(output)
                    }
                }
                
                // Set as ringtone
                val uri = Uri.fromFile(file)
                val values = android.content.ContentValues().apply {
                    put(android.provider.MediaStore.MediaColumns.DATA, file.absolutePath)
                    put(android.provider.MediaStore.MediaColumns.TITLE, title)
                    put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "audio/mp3")
                    put(android.provider.MediaStore.Audio.Media.ARTIST, "Ringo")
                    put(android.provider.MediaStore.Audio.Media.IS_RINGTONE, true)
                    put(android.provider.MediaStore.Audio.Media.IS_NOTIFICATION, true)
                    put(android.provider.MediaStore.Audio.Media.IS_ALARM, true)
                }
                
                val contentResolver = context.contentResolver
                val newUri = contentResolver.insert(android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
                
                // Set as default ringtone
                RingtoneManager.setActualDefaultRingtoneUri(context, RingtoneManager.TYPE_RINGTONE, newUri)
                
                Log.d(TAG, "Ringtone set successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error setting ringtone", e)
            }
        }
        
        fun setAsNotification(context: Context, ringtoneUrl: String, title: String) {
            try {
                // Download the ringtone file
                val fileName = "$title.mp3"
                val file = File(context.getExternalFilesDir(null), fileName)
                
                // Download the file
                URL(ringtoneUrl).openStream().use { input ->
                    FileOutputStream(file).use { output ->
                        input.copyTo(output)
                    }
                }
                
                // Set as notification sound
                val uri = Uri.fromFile(file)
                val values = android.content.ContentValues().apply {
                    put(android.provider.MediaStore.MediaColumns.DATA, file.absolutePath)
                    put(android.provider.MediaStore.MediaColumns.TITLE, title)
                    put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "audio/mp3")
                    put(android.provider.MediaStore.Audio.Media.ARTIST, "Ringo")
                    put(android.provider.MediaStore.Audio.Media.IS_RINGTONE, true)
                    put(android.provider.MediaStore.Audio.Media.IS_NOTIFICATION, true)
                    put(android.provider.MediaStore.Audio.Media.IS_ALARM, true)
                }
                
                val contentResolver = context.contentResolver
                val newUri = contentResolver.insert(android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
                
                // Set as default notification sound
                RingtoneManager.setActualDefaultRingtoneUri(context, RingtoneManager.TYPE_NOTIFICATION, newUri)
                
                Log.d(TAG, "Notification sound set successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error setting notification sound", e)
            }
        }
        
        fun setAsAlarm(context: Context, ringtoneUrl: String, title: String) {
            try {
                // Download the ringtone file
                val fileName = "$title.mp3"
                val file = File(context.getExternalFilesDir(null), fileName)
                
                // Download the file
                URL(ringtoneUrl).openStream().use { input ->
                    FileOutputStream(file).use { output ->
                        input.copyTo(output)
                    }
                }
                
                // Set as alarm sound
                val uri = Uri.fromFile(file)
                val values = android.content.ContentValues().apply {
                    put(android.provider.MediaStore.MediaColumns.DATA, file.absolutePath)
                    put(android.provider.MediaStore.MediaColumns.TITLE, title)
                    put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "audio/mp3")
                    put(android.provider.MediaStore.Audio.Media.ARTIST, "Ringo")
                    put(android.provider.MediaStore.Audio.Media.IS_RINGTONE, true)
                    put(android.provider.MediaStore.Audio.Media.IS_NOTIFICATION, true)
                    put(android.provider.MediaStore.Audio.Media.IS_ALARM, true)
                }
                
                val contentResolver = context.contentResolver
                val newUri = contentResolver.insert(android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
                
                // Set as default alarm sound
                RingtoneManager.setActualDefaultRingtoneUri(context, RingtoneManager.TYPE_ALARM, newUri)
                
                Log.d(TAG, "Alarm sound set successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error setting alarm sound", e)
            }
        }
    }
}
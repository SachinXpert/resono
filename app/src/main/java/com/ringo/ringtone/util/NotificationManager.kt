package com.ringo.ringtone.util

import android.app.NotificationChannel
import android.app.NotificationManager as AndroidNotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.ringo.ringtone.R

class NotificationManager private constructor() {
    companion object {
        private const val CHANNEL_ID = "ringtone_channel"
        private const val CHANNEL_NAME = "Ringtone Notifications"
        private const val CHANNEL_DESCRIPTION = "Notifications for ringtone downloads and updates"
        private var instance: NotificationManager? = null
        
        fun getInstance(context: Context): NotificationManager {
            if (instance == null) {
                createNotificationChannel(context)
                instance = NotificationManager()
            }
            return instance!!
        }
        
        private fun createNotificationChannel(context: Context) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as AndroidNotificationManager
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    AndroidNotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = CHANNEL_DESCRIPTION
                }
                notificationManager.createNotificationChannel(channel)
            }
        }
    }
    
    fun showDownloadNotification(context: Context, title: String, progress: Int = 0) {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground) // Replace with actual icon
            .setContentTitle("Downloading Ringtone")
            .setContentText(title)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setProgress(100, progress, progress == 0)
        
        with(NotificationManagerCompat.from(context)) {
            notify(1, builder.build())
        }
    }
    
    fun showDownloadCompleteNotification(context: Context, title: String) {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground) // Replace with actual icon
            .setContentTitle("Download Complete")
            .setContentText("$title has been downloaded")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
        
        with(NotificationManagerCompat.from(context)) {
            notify(2, builder.build())
        }
    }
    
    fun showAdNotification(context: Context) {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground) // Replace with actual icon
            .setContentTitle("Ad Display")
            .setContentText("Showing advertisement before download")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
        
        with(NotificationManagerCompat.from(context)) {
            notify(3, builder.build())
        }
    }
}
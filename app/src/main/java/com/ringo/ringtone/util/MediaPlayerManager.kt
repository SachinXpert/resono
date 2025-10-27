package com.ringo.ringtone.util

import android.content.Context
import android.media.MediaPlayer
import android.net.Uri
import android.util.Log
import java.util.concurrent.ConcurrentHashMap

class MediaPlayerManager private constructor() {
    companion object {
        private const val TAG = "MediaPlayerManager"
        private var instance: MediaPlayerManager? = null
        
        fun getInstance(): MediaPlayerManager {
            if (instance == null) {
                instance = MediaPlayerManager()
            }
            return instance!!
        }
    }
    
    private val mediaPlayers = ConcurrentHashMap<String, MediaPlayer>()
    
    fun playRingtone(context: Context, ringtoneUrl: String, onCompletion: (() -> Unit)? = null) {
        try {
            // Stop any currently playing ringtone
            stopAll()
            
            val mediaPlayer = MediaPlayer().apply {
                setDataSource(ringtoneUrl)
                prepareAsync()
                setOnPreparedListener { mp ->
                    mp.start()
                }
                setOnCompletionListener { mp ->
                    onCompletion?.invoke()
                    releaseMediaPlayer(ringtoneUrl)
                }
            }
            
            mediaPlayers[ringtoneUrl] = mediaPlayer
        } catch (e: Exception) {
            Log.e(TAG, "Error playing ringtone", e)
        }
    }
    
    fun stopRingtone(ringtoneUrl: String) {
        mediaPlayers[ringtoneUrl]?.let { mediaPlayer ->
            if (mediaPlayer.isPlaying) {
                mediaPlayer.stop()
            }
            mediaPlayer.release()
            mediaPlayers.remove(ringtoneUrl)
        }
    }
    
    fun stopAll() {
        mediaPlayers.forEach { (_, mediaPlayer) ->
            try {
                if (mediaPlayer.isPlaying) {
                    mediaPlayer.stop()
                }
                mediaPlayer.release()
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping media player", e)
            }
        }
        mediaPlayers.clear()
    }
    
    fun isPlaying(ringtoneUrl: String): Boolean {
        return mediaPlayers[ringtoneUrl]?.isPlaying ?: false
    }
    
    private fun releaseMediaPlayer(ringtoneUrl: String) {
        mediaPlayers.remove(ringtoneUrl)?.release()
    }
}
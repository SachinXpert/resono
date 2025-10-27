package com.ringo.ringtone.util

import android.content.Context
import android.util.Log
import java.io.File

class CacheManager {
    companion object {
        private const val TAG = "CacheManager"
        
        fun clearCache(context: Context) {
            try {
                // Clear app cache
                val cacheDir = context.cacheDir
                deleteDir(cacheDir)
                
                // Clear external cache if available
                context.externalCacheDir?.let { externalCacheDir ->
                    deleteDir(externalCacheDir)
                }
                
                Log.d(TAG, "Cache cleared successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error clearing cache", e)
            }
        }
        
        private fun deleteDir(dir: File?): Boolean {
            if (dir != null && dir.isDirectory) {
                val children = dir.list()
                if (children != null) {
                    for (child in children) {
                        val success = deleteDir(File(dir, child))
                        if (!success) {
                            return false
                        }
                    }
                }
                return dir.delete()
            } else if (dir != null && dir.isFile) {
                return dir.delete()
            }
            return false
        }
        
        fun getCacheSize(context: Context): Long {
            val cacheDir = context.cacheDir
            val externalCacheDir = context.externalCacheDir
            
            var size = getDirSize(cacheDir)
            if (externalCacheDir != null) {
                size += getDirSize(externalCacheDir)
            }
            
            return size
        }
        
        private fun getDirSize(dir: File?): Long {
            var size: Long = 0
            if (dir != null && dir.isDirectory) {
                val children = dir.list()
                if (children != null) {
                    for (child in children) {
                        size += getDirSize(File(dir, child))
                    }
                }
            } else if (dir != null && dir.isFile) {
                size = dir.length()
            }
            return size
        }
    }
}
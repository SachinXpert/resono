package com.ringo.ringtone.util

import android.content.Context
import android.content.SharedPreferences
import com.ringo.ringtone.data.Ringtone
import org.json.JSONArray
import org.json.JSONObject

class DataManager private constructor() {
    companion object {
        private const val PREFS_NAME = "ringo_prefs"
        private const val KEY_FAVORITES = "favorites"
        private var instance: DataManager? = null
        
        fun getInstance(): DataManager {
            if (instance == null) {
                instance = DataManager()
            }
            return instance!!
        }
    }
    
    private var sharedPreferences: SharedPreferences? = null
    
    fun initialize(context: Context) {
        sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    fun saveFavorite(ringtone: Ringtone) {
        val prefs = sharedPreferences ?: return
        val favoritesJson = prefs.getString(KEY_FAVORITES, "[]") ?: "[]"
        val favoritesArray = JSONArray(favoritesJson)
        
        // Check if already exists
        for (i in 0 until favoritesArray.length()) {
            val item = favoritesArray.getJSONObject(i)
            if (item.getString("id") == ringtone.id) {
                // Already exists, update it
                favoritesArray.put(i, ringtoneToJson(ringtone))
                prefs.edit().putString(KEY_FAVORITES, favoritesArray.toString()).apply()
                return
            }
        }
        
        // Add new favorite
        favoritesArray.put(ringtoneToJson(ringtone))
        prefs.edit().putString(KEY_FAVORITES, favoritesArray.toString()).apply()
    }
    
    fun removeFavorite(ringtoneId: String) {
        val prefs = sharedPreferences ?: return
        val favoritesJson = prefs.getString(KEY_FAVORITES, "[]") ?: "[]"
        val favoritesArray = JSONArray(favoritesJson)
        
        // Find and remove
        for (i in 0 until favoritesArray.length()) {
            val item = favoritesArray.getJSONObject(i)
            if (item.getString("id") == ringtoneId) {
                favoritesArray.remove(i)
                prefs.edit().putString(KEY_FAVORITES, favoritesArray.toString()).apply()
                return
            }
        }
    }
    
    fun getFavorites(): List<Ringtone> {
        val prefs = sharedPreferences ?: return emptyList()
        val favoritesJson = prefs.getString(KEY_FAVORITES, "[]") ?: "[]"
        val favoritesArray = JSONArray(favoritesJson)
        val favorites = mutableListOf<Ringtone>()
        
        for (i in 0 until favoritesArray.length()) {
            val item = favoritesArray.getJSONObject(i)
            favorites.add(jsonToRingtone(item))
        }
        
        return favorites
    }
    
    fun isFavorite(ringtoneId: String): Boolean {
        val prefs = sharedPreferences ?: return false
        val favoritesJson = prefs.getString(KEY_FAVORITES, "[]") ?: "[]"
        val favoritesArray = JSONArray(favoritesJson)
        
        for (i in 0 until favoritesArray.length()) {
            val item = favoritesArray.getJSONObject(i)
            if (item.getString("id") == ringtoneId) {
                return true
            }
        }
        
        return false
    }
    
    private fun ringtoneToJson(ringtone: Ringtone): JSONObject {
        return JSONObject().apply {
            put("id", ringtone.id)
            put("title", ringtone.title)
            put("url", ringtone.url)
            put("duration", ringtone.duration)
            put("category", ringtone.category)
            put("isFavorite", ringtone.isFavorite)
            put("isDownloaded", ringtone.isDownloaded)
        }
    }
    
    private fun jsonToRingtone(json: JSONObject): Ringtone {
        return Ringtone(
            id = json.getString("id"),
            title = json.getString("title"),
            url = json.getString("url"),
            duration = json.getString("duration"),
            category = json.getString("category"),
            isFavorite = json.getBoolean("isFavorite"),
            isDownloaded = json.getBoolean("isDownloaded")
        )
    }
}
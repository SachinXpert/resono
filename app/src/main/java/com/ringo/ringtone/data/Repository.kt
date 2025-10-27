package com.ringo.ringtone.data

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.URL
import java.net.UnknownHostException

class Repository {
    companion object {
        private const val TAG = "Repository"
        private const val BASE_URL = "https://api.github.com/repos/SachinXpert/Ringo/contents"
        
        suspend fun fetchCategories(): List<Category> = withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Fetching categories from $BASE_URL")
                val url = URL(BASE_URL)
                val jsonString = url.readText()
                Log.d(TAG, "Received categories JSON: $jsonString")
                val jsonArray = JSONArray(jsonString)
                
                val categories = mutableListOf<Category>()
                
                for (i in 0 until jsonArray.length()) {
                    val jsonObject = jsonArray.getJSONObject(i)
                    if (jsonObject.getString("type") == "dir") {
                        val name = jsonObject.getString("name")
                        Log.d(TAG, "Found category: $name")
                        // For now, we'll set a dummy count. In a real app, we would fetch the actual count.
                        categories.add(Category(id = name.lowercase(), name = name, ringtoneCount = 0))
                    }
                }
                
                Log.d(TAG, "Total categories found: ${categories.size}")
                categories
            } catch (e: UnknownHostException) {
                Log.e(TAG, "No internet connection", e)
                throw Exception("No internet connection. Please check your network settings.")
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching categories", e)
                throw Exception("Failed to fetch categories. Please try again later.")
            }
        }
        
        suspend fun fetchRingtonesByCategory(category: String): List<Ringtone> = withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Fetching ringtones for category: $category")
                val url = URL("$BASE_URL/$category")
                val jsonString = url.readText()
                Log.d(TAG, "Received ringtones JSON for category $category: $jsonString")
                val jsonArray = JSONArray(jsonString)
                
                val ringtones = mutableListOf<Ringtone>()
                
                for (i in 0 until jsonArray.length()) {
                    val jsonObject = jsonArray.getJSONObject(i)
                    if (jsonObject.getString("type") == "file" && jsonObject.getString("name").endsWith(".mp3")) {
                        val name = jsonObject.getString("name")
                        val downloadUrl = jsonObject.getString("download_url")
                        
                        // Extract title by removing the file extension and cleaning up the name
                        val title = name.substringBeforeLast(".mp3")
                            .replace("-", " ")
                            .replace("  ", " ")
                        
                        Log.d(TAG, "Found ringtone: $title")
                        ringtones.add(
                            Ringtone(
                                id = jsonObject.getString("sha"),
                                title = title,
                                url = downloadUrl,
                                duration = "0:30", // Dummy duration, in a real app we would extract this from the file
                                category = category,
                                isFavorite = false,
                                isDownloaded = false
                            )
                        )
                    }
                }
                
                Log.d(TAG, "Total ringtones found for category $category: ${ringtones.size}")
                ringtones
            } catch (e: UnknownHostException) {
                Log.e(TAG, "No internet connection", e)
                throw Exception("No internet connection. Please check your network settings.")
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching ringtones for category: $category", e)
                throw Exception("Failed to fetch ringtones for category $category. Please try again later.")
            }
        }
        
        suspend fun searchRingtones(query: String): List<Ringtone> = withContext(Dispatchers.IO) {
            // In a real implementation, this would search across all categories
            // For now, we'll return an empty list
            try {
                // This is a placeholder implementation
                emptyList()
            } catch (e: UnknownHostException) {
                Log.e(TAG, "No internet connection", e)
                throw Exception("No internet connection. Please check your network settings.")
            } catch (e: Exception) {
                Log.e(TAG, "Error searching ringtones", e)
                throw Exception("Failed to search ringtones. Please try again later.")
            }
        }
    }
}
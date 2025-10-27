package com.ringo.ringtone.viewmodel

import android.content.Context
import android.util.Log
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ringo.ringtone.data.Category
import com.ringo.ringtone.data.Ringtone
import com.ringo.ringtone.data.Repository
import com.ringo.ringtone.util.DataManager
import kotlinx.coroutines.launch

class MainViewModel : ViewModel() {
    companion object {
        private const val TAG = "MainViewModel"
    }
    
    private val _ringtones = mutableStateOf<List<Ringtone>>(emptyList())
    val ringtones: State<List<Ringtone>> = _ringtones
    
    private val _categories = mutableStateOf<List<Category>>(emptyList())
    val categories: State<List<Category>> = _categories
    
    private val _favoriteRingtones = mutableStateOf<List<Ringtone>>(emptyList())
    val favoriteRingtones: State<List<Ringtone>> = _favoriteRingtones
    
    private var context: Context? = null
    
    fun setContext(context: Context) {
        this.context = context
        // Load favorites from DataManager
        _favoriteRingtones.value = DataManager.getInstance().getFavorites()
    }
    
    private val _isLoading = mutableStateOf(false)
    val isLoading: State<Boolean> = _isLoading
    
    private val _error = mutableStateOf<String?>(null)
    val error: State<String?> = _error
    
    fun fetchCategories() {
        Log.d(TAG, "Fetching categories")
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val categories = Repository.fetchCategories()
                _categories.value = categories
                Log.d(TAG, "Categories fetched: ${categories.size}")
                // After fetching categories, fetch all ringtones
                fetchAllRingtones()
                _error.value = null
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching categories", e)
                _error.value = e.message
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun fetchAllRingtones() {
        Log.d(TAG, "Fetching all ringtones")
        viewModelScope.launch {
            _isLoading.value = true
            try {
                // Fetch ringtones from all categories
                val allRingtones = mutableListOf<Ringtone>()
                
                for (category in _categories.value) {
                    Log.d(TAG, "Fetching ringtones for category: ${category.name}")
                    val ringtones = Repository.fetchRingtonesByCategory(category.name)
                    allRingtones.addAll(ringtones)
                    Log.d(TAG, "Ringtones fetched for category ${category.name}: ${ringtones.size}")
                }
                
                _ringtones.value = allRingtones
                Log.d(TAG, "Total ringtones fetched: ${allRingtones.size}")
                _error.value = null
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching ringtones", e)
                _error.value = e.message
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun fetchRingtonesByCategory(category: String) {
        Log.d(TAG, "Fetching ringtones for category: $category")
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val ringtones = Repository.fetchRingtonesByCategory(category)
                _ringtones.value = ringtones
                Log.d(TAG, "Ringtones fetched for category $category: ${ringtones.size}")
                _error.value = null
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching ringtones for category: $category", e)
                _error.value = e.message
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun searchRingtones(query: String) {
        Log.d(TAG, "Searching ringtones for query: $query")
        viewModelScope.launch {
            _isLoading.value = true
            try {
                // In a real implementation, this would search across all categories
                // For now, we'll just filter the current ringtones
                val filteredRingtones = _ringtones.value.filter { 
                    it.title.contains(query, ignoreCase = true) 
                }
                _ringtones.value = filteredRingtones
                Log.d(TAG, "Search completed, found ${filteredRingtones.size} ringtones")
                _error.value = null
            } catch (e: Exception) {
                Log.e(TAG, "Error searching ringtones", e)
                _error.value = e.message
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun searchRingtonesOnline(query: String) {
        Log.d(TAG, "Searching ringtones online for query: $query")
        viewModelScope.launch {
            _isLoading.value = true
            try {
                // In a real implementation, this would search across all categories online
                // For now, we'll just use the local search
                searchRingtones(query)
                _error.value = null
            } catch (e: Exception) {
                Log.e(TAG, "Error searching ringtones online", e)
                _error.value = e.message
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun toggleFavorite(ringtone: Ringtone) {
        Log.d(TAG, "Toggling favorite for ringtone: ${ringtone.title}")
        val updatedRingtones = _ringtones.value.map { 
            if (it.id == ringtone.id) {
                val toggledRingtone = ringtone.copy(isFavorite = !ringtone.isFavorite)
                // Save to DataManager
                if (toggledRingtone.isFavorite) {
                    DataManager.getInstance().saveFavorite(toggledRingtone)
                } else {
                    DataManager.getInstance().removeFavorite(toggledRingtone.id)
                }
                toggledRingtone
            } else it
        }
        _ringtones.value = updatedRingtones
        
        // Update favorite list
        val favorites = updatedRingtones.filter { it.isFavorite }
        _favoriteRingtones.value = favorites
        Log.d(TAG, "Favorite toggled, now ${favorites.size} favorites")
    }
    
    fun downloadRingtone(ringtone: Ringtone) {
        Log.d(TAG, "Downloading ringtone: ${ringtone.title}")
        // In a real implementation, this would download the ringtone
        // For now, we'll just update the state
        val updatedRingtones = _ringtones.value.map { 
            if (it.id == ringtone.id) ringtone.copy(isDownloaded = true) else it
        }
        _ringtones.value = updatedRingtones
        Log.d(TAG, "Ringtone marked as downloaded: ${ringtone.title}")
    }
    
    fun clearError() {
        _error.value = null
    }
}
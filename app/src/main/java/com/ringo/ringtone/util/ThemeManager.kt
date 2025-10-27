package com.ringo.ringtone.util

import android.content.Context
import android.content.SharedPreferences

class ThemeManager private constructor() {
    companion object {
        private const val PREFS_NAME = "theme_prefs"
        private const val KEY_THEME = "selected_theme"
        private const val KEY_DYNAMIC_COLOR = "dynamic_color"
        private var instance: ThemeManager? = null
        
        fun getInstance(): ThemeManager {
            if (instance == null) {
                instance = ThemeManager()
            }
            return instance!!
        }
    }
    
    private lateinit var sharedPreferences: SharedPreferences
    
    fun initialize(context: Context) {
        sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    fun getSelectedTheme(): String {
        return sharedPreferences.getString(KEY_THEME, "system") ?: "system"
    }
    
    fun setSelectedTheme(theme: String) {
        sharedPreferences.edit().putString(KEY_THEME, theme).apply()
    }
    
    fun isDynamicColorEnabled(): Boolean {
        return sharedPreferences.getBoolean(KEY_DYNAMIC_COLOR, true)
    }
    
    fun setDynamicColorEnabled(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_DYNAMIC_COLOR, enabled).apply()
    }
}
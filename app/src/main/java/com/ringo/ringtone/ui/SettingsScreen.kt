package com.ringo.ringtone.ui

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.ringo.ringtone.util.CacheManager
import com.ringo.ringtone.util.ThemeManager

@Composable
fun SettingsScreen(navController: NavController) {
    var feedbackText by remember { mutableStateOf("") }
    var selectedTheme by remember { mutableStateOf(ThemeManager.getInstance().getSelectedTheme()) }
    var dynamicColor by remember { mutableStateOf(ThemeManager.getInstance().isDynamicColorEnabled()) }
    val context = LocalContext.current
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Text("Settings", style = androidx.compose.material3.MaterialTheme.typography.headlineMedium)
        
        // Theme settings
        Text("Theme", style = androidx.compose.material3.MaterialTheme.typography.headlineSmall)
        
        // Theme selection
        Button(
            onClick = { 
                selectedTheme = when (selectedTheme) {
                    "system" -> "light"
                    "light" -> "dark"
                    else -> "system"
                }
                ThemeManager.getInstance().setSelectedTheme(selectedTheme)
            }
        ) {
            Text(when (selectedTheme) {
                "system" -> "System Default"
                "light" -> "Light Theme"
                else -> "Dark Theme"
            })
        }
        
        // Dynamic color toggle
        Button(
            onClick = { 
                dynamicColor = !dynamicColor
                ThemeManager.getInstance().setDynamicColorEnabled(dynamicColor)
            }
        ) {
            Text(if (dynamicColor) "Disable Dynamic Color" else "Enable Dynamic Color")
        }
        
        // Links
        Text("Links", style = androidx.compose.material3.MaterialTheme.typography.headlineSmall)
        Button(onClick = { 
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com"))
            context.startActivity(intent)
        }) {
            Text("Twitter")
        }
        Button(onClick = { 
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://telegram.org"))
            context.startActivity(intent)
        }) {
            Text("Telegram")
        }
        
        // Feedback
        Text("Feedback", style = androidx.compose.material3.MaterialTheme.typography.headlineSmall)
        TextField(
            value = feedbackText,
            onValueChange = { feedbackText = it },
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            label = { Text("Your feedback") }
        )
        Button(onClick = { 
            // Send feedback
            // In a real implementation, this would send the feedback to a server
            feedbackText = "" // Clear the feedback text
        }) {
            Text("Send Feedback")
        }
        
        // Other options
        Button(onClick = { 
            CacheManager.clearCache(context)
        }) {
            Text("Clear Cache")
        }
        Button(onClick = { 
            navController.navigate("privacy_policy")
        }) {
            Text("Privacy Policy")
        }
        Button(onClick = { /* Open about screen */ }) {
            Text("About")
        }
    }
}
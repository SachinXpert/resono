package com.ringo.ringtone.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.ringo.ringtone.data.Category
import com.ringo.ringtone.viewmodel.MainViewModel

@Composable
fun CategoryScreen(
    category: Category,
    viewModel: MainViewModel = viewModel()
) {
    // Fetch ringtones for this category
    viewModel.fetchRingtonesByCategory(category.name)
    
    val ringtones by viewModel.ringtones
    val isLoading by viewModel.isLoading
    val error by viewModel.error
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Text(
            text = category.name,
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium
        )
        
        if (isLoading) {
            Text("Loading ringtones...")
        } else if (error != null) {
            Text("Error: $error")
        } else {
            LazyColumn {
                items(ringtones) { ringtone ->
                    RingtoneItem(
                        ringtone = ringtone,
                        onPlayClick = { /* Handle play click */ },
                        onFavoriteClick = { viewModel.toggleFavorite(it) },
                        onDownloadClick = { viewModel.downloadRingtone(it) }
                    )
                }
            }
        }
    }
}
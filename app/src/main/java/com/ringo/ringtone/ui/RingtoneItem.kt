package com.ringo.ringtone.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.ringo.ringtone.data.Ringtone

@Composable
fun RingtoneItem(
    ringtone: Ringtone,
    onPlayClick: (Ringtone) -> Unit,
    onFavoriteClick: (Ringtone) -> Unit,
    onDownloadClick: (Ringtone) -> Unit
) {
    var isFavorite by remember { mutableStateOf(ringtone.isFavorite) }
    var showMenu by remember { mutableStateOf(false) }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .height(100.dp), // Fixed height for the card
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Play button
            IconButton(
                onClick = { onPlayClick(ringtone) },
                modifier = Modifier
                    .background(
                        color = androidx.compose.material3.MaterialTheme.colorScheme.primary,
                        shape = CircleShape
                    )
                    .padding(5.dp)
            ) {
                Icon(
                    imageVector = Icons.Filled.PlayArrow,
                    contentDescription = "Play",
                    tint = androidx.compose.material3.MaterialTheme.colorScheme.onPrimary
                )
            }
            
            // Ringtone info
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 16.dp)
            ) {
                Text(
                    text = ringtone.title,
                    style = androidx.compose.material3.MaterialTheme.typography.titleMedium,
                    maxLines = 2, // Limit to 2 lines
                    overflow = TextOverflow.Ellipsis // Add ellipsis for overflow
                )
                Text(
                    text = "${ringtone.duration} • ${ringtone.category}",
                    style = androidx.compose.material3.MaterialTheme.typography.bodySmall,
                    color = androidx.compose.material3.MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            // Menu button (3 dots)
            IconButton(onClick = { showMenu = true }) {
                Icon(
                    imageVector = Icons.Filled.MoreVert,
                    contentDescription = "More options"
                )
                
                // Dropdown menu
                DropdownMenu(
                    expanded = showMenu,
                    onDismissRequest = { showMenu = false }
                ) {
                    DropdownMenuItem(
                        text = { 
                            Text(
                                if (isFavorite) "Remove from favorites" else "Add to favorites"
                            ) 
                        },
                        onClick = {
                            isFavorite = !isFavorite
                            onFavoriteClick(ringtone.copy(isFavorite = isFavorite))
                            showMenu = false
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Download") },
                        onClick = {
                            onDownloadClick(ringtone)
                            showMenu = false
                        }
                    )
                }
            }
        }
    }
}
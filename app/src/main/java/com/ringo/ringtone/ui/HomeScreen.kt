package com.ringo.ringtone.ui

import android.content.Context
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.ringo.ringtone.viewmodel.MainViewModel

@Composable
fun HomeScreen(context: Context) {
    val viewModel: MainViewModel = viewModel()
    viewModel.setContext(context)
    
    // Initialize the view model
    LaunchedEffect(Unit) {
        viewModel.fetchCategories()
    }
    
    var selectedTab by remember { mutableStateOf(0) }
    
    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.Home, contentDescription = "Home") },
                    label = { Text("Home") },
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.Favorite, contentDescription = "Favorites") },
                    label = { Text("Favorites") },
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.Search, contentDescription = "Search") },
                    label = { Text("Search") },
                    selected = selectedTab == 2,
                    onClick = { selectedTab = 2 }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.Settings, contentDescription = "Settings") },
                    label = { Text("Settings") },
                    selected = selectedTab == 3,
                    onClick = { selectedTab = 3 }
                )
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 16.dp) // Add padding only to left and right
        ) {
            when (selectedTab) {
                0 -> HomeTab(viewModel)
                1 -> FavoritesTab(viewModel)
                2 -> SearchTab(viewModel)
                3 -> SettingsTab()
            }
        }
    }
}

@Composable
fun HomeTab(viewModel: MainViewModel) {
    val ringtones by viewModel.ringtones
    val categories by viewModel.categories
    val isLoading by viewModel.isLoading
    val error by viewModel.error
    
    // State for the inner tabs (All/Categories)
    var selectedInnerTab by remember { mutableStateOf(0) }
    
    // Lazy list state for scroll detection
    val listState = rememberLazyListState()
    
    // State to control visibility of tab bar
    var showTabBar by remember { mutableStateOf(true) }
    var lastScrollIndex by remember { mutableStateOf(0) }
    var lastScrollOffset by remember { mutableStateOf(0) }
    
    // Detect scroll direction
    LaunchedEffect(listState) {
        listState.interactionSource.interactions.collect { interaction ->
            val currentIndex = listState.firstVisibleItemIndex
            val currentOffset = listState.firstVisibleItemScrollOffset
            
            // Show tab bar when scrolling up, hide when scrolling down
            if (currentIndex > lastScrollIndex || (currentIndex == lastScrollIndex && currentOffset > lastScrollOffset)) {
                // Scrolling down
                showTabBar = false
            } else if (currentIndex < lastScrollIndex || (currentIndex == lastScrollIndex && currentOffset < lastScrollOffset)) {
                // Scrolling up
                showTabBar = true
            }
            
            lastScrollIndex = currentIndex
            lastScrollOffset = currentOffset
        }
    }
    
    Column {
        // Header
        Text(
            "Ring Tones", 
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp, bottom = 8.dp)
        )
        
        // Inner tabs (All/Categories) with collapse/expand animation
        AnimatedVisibility(
            visible = showTabBar,
            enter = expandVertically(),
            exit = shrinkVertically()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            ) {
                // All tab
                Button(
                    onClick = { selectedInnerTab = 0 },
                    modifier = Modifier
                        .weight(1f)
                        .padding(end = 4.dp),
                    shape = RoundedCornerShape(50.dp), // Full rounded corners
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (selectedInnerTab == 0) 
                            androidx.compose.material3.MaterialTheme.colorScheme.primary 
                        else 
                            androidx.compose.material3.MaterialTheme.colorScheme.secondaryContainer,
                        contentColor = if (selectedInnerTab == 0) 
                            androidx.compose.material3.MaterialTheme.colorScheme.onPrimary 
                        else 
                            androidx.compose.material3.MaterialTheme.colorScheme.onSecondaryContainer
                    )
                ) {
                    Text("All")
                }
                
                // Categories tab
                Button(
                    onClick = { selectedInnerTab = 1 },
                    modifier = Modifier
                        .weight(1f)
                        .padding(start = 4.dp),
                    shape = RoundedCornerShape(50.dp), // Full rounded corners
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (selectedInnerTab == 1) 
                            androidx.compose.material3.MaterialTheme.colorScheme.primary 
                        else 
                            androidx.compose.material3.MaterialTheme.colorScheme.secondaryContainer,
                        contentColor = if (selectedInnerTab == 1) 
                            androidx.compose.material3.MaterialTheme.colorScheme.onPrimary 
                        else 
                            androidx.compose.material3.MaterialTheme.colorScheme.onSecondaryContainer
                    )
                ) {
                    Text("Categories")
                }
            }
        }
        
        // Content based on selected inner tab
        LazyColumn(state = listState) {
            when (selectedInnerTab) {
                0 -> {
                    // All ringtones
                    if (isLoading) {
                        item {
                            Text("Loading ringtones...")
                        }
                    } else if (error != null) {
                        item {
                            Text("Error: $error")
                        }
                    } else {
                        items(ringtones) { ringtone ->
                            RingtoneItem(
                                ringtone = ringtone,
                                onPlayClick = { /* Handle play */ },
                                onFavoriteClick = { viewModel.toggleFavorite(it) },
                                onDownloadClick = { viewModel.downloadRingtone(it) }
                            )
                        }
                    }
                }
                1 -> {
                    // Categories
                    if (isLoading) {
                        item {
                            Text("Loading categories...")
                        }
                    } else if (error != null) {
                        item {
                            Text("Error: $error")
                        }
                    } else {
                        items(categories) { category ->
                            Text(
                                text = category.name,
                                style = androidx.compose.material3.MaterialTheme.typography.titleLarge,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FavoritesTab(viewModel: MainViewModel) {
    val favoriteRingtones by viewModel.favoriteRingtones
    val isLoading by viewModel.isLoading
    val error by viewModel.error
    
    Column {
        Text(
            "Favorite Ringtones", 
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp, bottom = 8.dp)
        )
        
        if (isLoading) {
            Text("Loading favorites...")
        } else if (error != null) {
            Text("Error: $error")
        } else {
            if (favoriteRingtones.isEmpty()) {
                Text("No favorite ringtones yet")
            } else {
                LazyColumn {
                    items(favoriteRingtones) { ringtone ->
                        RingtoneItem(
                            ringtone = ringtone,
                            onPlayClick = { /* Handle play */ },
                            onFavoriteClick = { viewModel.toggleFavorite(it) },
                            onDownloadClick = { viewModel.downloadRingtone(it) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun SearchTab(viewModel: MainViewModel) {
    val ringtones by viewModel.ringtones
    val isLoading by viewModel.isLoading
    val error by viewModel.error
    
    Column {
        Text(
            "Search Ringtones", 
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp, bottom = 8.dp)
        )
        
        // Search input would go here
        
        if (isLoading) {
            Text("Searching...")
        } else if (error != null) {
            Text("Error: $error")
        } else {
            LazyColumn {
                items(ringtones) { ringtone ->
                    RingtoneItem(
                        ringtone = ringtone,
                        onPlayClick = { /* Handle play */ },
                        onFavoriteClick = { viewModel.toggleFavorite(it) },
                        onDownloadClick = { viewModel.downloadRingtone(it) }
                    )
                }
            }
        }
    }
}

@Composable
fun SettingsTab() {
    Column {
        Text(
            "Settings", 
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp, bottom = 8.dp)
        )
        Text("Theme settings")
        Text("Links to Twitter and Telegram")
        Text("Clear cache option")
        Text("Feedback form")
        Text("Privacy policy")
    }
}
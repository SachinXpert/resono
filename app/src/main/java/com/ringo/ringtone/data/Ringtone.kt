package com.ringo.ringtone.data

data class Ringtone(
    val id: String,
    val title: String,
    val url: String,
    val duration: String,
    val category: String,
    val isFavorite: Boolean = false,
    val isDownloaded: Boolean = false
)
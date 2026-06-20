package com.coffeecall.app.core.design

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.automirrored.rounded.Chat
import androidx.compose.material.icons.automirrored.rounded.Send
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.Brush
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.DirectionsWalk
import androidx.compose.material.icons.rounded.Event
import androidx.compose.material.icons.rounded.Explore
import androidx.compose.material.icons.rounded.FavoriteBorder
import androidx.compose.material.icons.rounded.FitnessCenter
import androidx.compose.material.icons.rounded.Group
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.LocalCafe
import androidx.compose.material.icons.rounded.LocationOn
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.Map
import androidx.compose.material.icons.rounded.MenuBook
import androidx.compose.material.icons.rounded.Movie
import androidx.compose.material.icons.rounded.MusicNote
import androidx.compose.material.icons.rounded.NorthEast
import androidx.compose.material.icons.rounded.NotificationsNone
import androidx.compose.material.icons.rounded.Person
import androidx.compose.material.icons.rounded.Restaurant
import androidx.compose.material.icons.rounded.Schedule
import androidx.compose.material.icons.rounded.SelfImprovement
import androidx.compose.material.icons.rounded.SettingsInputAntenna
import androidx.compose.material.icons.rounded.SportsEsports
import androidx.compose.material.icons.rounded.Tune
import androidx.compose.material.icons.rounded.ViewAgenda
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material.icons.rounded.Search
import androidx.compose.material.icons.rounded.Shield
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.automirrored.rounded.Logout
import androidx.compose.ui.graphics.vector.ImageVector

/**
 * Central icon map so Android renders real vector icons (matching the Figma
 * lucide-react set) instead of text symbols. Keep parity with the iOS SF Symbol
 * choices in AppIcons.swift.
 */
object CoffeeIcons {
    // Navigation chrome
    val around: ImageVector = Icons.Rounded.SettingsInputAntenna
    val drifts: ImageVector = Icons.Rounded.Event
    val create: ImageVector = Icons.Rounded.Add
    val chats: ImageVector = Icons.AutoMirrored.Rounded.Chat
    val profile: ImageVector = Icons.Rounded.Person

    // UI / actions
    val search: ImageVector = Icons.Rounded.Search
    val filter: ImageVector = Icons.Rounded.Tune
    val bell: ImageVector = Icons.Rounded.NotificationsNone
    val map: ImageVector = Icons.Rounded.Map
    val location: ImageVector = Icons.Rounded.LocationOn
    val clock: ImageVector = Icons.Rounded.Schedule
    val calendar: ImageVector = Icons.Rounded.Event
    val antenna: ImageVector = Icons.Rounded.SettingsInputAntenna

    val people: ImageVector = Icons.Rounded.Group
    val heart: ImageVector = Icons.Rounded.FavoriteBorder
    val arrowUpRight: ImageVector = Icons.Rounded.NorthEast
    val back: ImageVector = Icons.AutoMirrored.Rounded.ArrowBack
    val send: ImageVector = Icons.AutoMirrored.Rounded.Send
    val chevronRight: ImageVector = Icons.Rounded.ChevronRight
    val bolt: ImageVector = Icons.Rounded.Bolt
    val check: ImageVector = Icons.Rounded.Check
    val close: ImageVector = Icons.Rounded.Close
    val refresh: ImageVector = Icons.Rounded.Refresh
    val lock: ImageVector = Icons.Rounded.Lock
    val shield: ImageVector = Icons.Rounded.Shield
    val logout: ImageVector = Icons.AutoMirrored.Rounded.Logout
    val settings: ImageVector = Icons.Rounded.Settings
    val info: ImageVector = Icons.Rounded.Info

    /** Maps a Drift category (lowercase string) to its activity icon. */
    fun category(category: String): ImageVector = when (category.lowercase().trim()) {
        "coffee" -> Icons.Rounded.LocalCafe
        "walk", "walks" -> Icons.Rounded.DirectionsWalk
        "movie", "movies" -> Icons.Rounded.Movie
        "food" -> Icons.Rounded.Restaurant
        "study", "books" -> Icons.Rounded.MenuBook
        "gaming", "games" -> Icons.Rounded.SportsEsports
        "music" -> Icons.Rounded.MusicNote
        "yoga", "fitness" -> Icons.Rounded.SelfImprovement
        "workout" -> Icons.Rounded.FitnessCenter
        "creative" -> Icons.Rounded.Brush
        "event" -> Icons.Rounded.Event
        else -> Icons.Rounded.Bolt
    }
}

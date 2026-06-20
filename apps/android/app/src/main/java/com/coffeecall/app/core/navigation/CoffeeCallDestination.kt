package com.coffeecall.app.core.navigation

import androidx.compose.ui.graphics.vector.ImageVector
import com.coffeecall.app.core.design.CoffeeIcons

data class CoffeeCallDestination(
    val route: String,
    val label: String,
    val icon: ImageVector,
    val subtitle: String
)

object CoffeeCallRoutes {
    const val DISCOVERY = "discovery"
    const val DRIFTS = "drifts"
    const val CHAT = "chat"
    const val PROFILE = "profile"
    const val DRIFT_DETAIL = "drift_detail/{postId}"
    const val CHAT_THREAD = "chat_thread/{threadId}"
    const val PROFILE_EDIT = "profile_edit"
}

val CoffeeCallDestinations = listOf(
    CoffeeCallDestination(CoffeeCallRoutes.DISCOVERY, "Around", CoffeeIcons.around, "People nearby are open to plans"),
    CoffeeCallDestination(CoffeeCallRoutes.DRIFTS, "Drifts", CoffeeIcons.drifts, "Plans happening around you"),
    CoffeeCallDestination(CoffeeCallRoutes.CHAT, "Chats", CoffeeIcons.chats, "Drift rooms"),
    CoffeeCallDestination(CoffeeCallRoutes.PROFILE, "You", CoffeeIcons.profile, "Your profile")
)

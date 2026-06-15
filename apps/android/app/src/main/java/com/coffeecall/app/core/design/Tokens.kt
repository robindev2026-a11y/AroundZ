package com.coffeecall.app.core.design

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp

object CoffeeSpacing {
    val xxs = 4.dp
    val xs = 8.dp
    val sm = 12.dp
    val md = 16.dp
    val lg = 20.dp
    val xl = 24.dp
    val xxl = 36.dp
    val screen = 20.dp
    val minTouchTarget = 44.dp
    val primaryButtonHeight = 56.dp
    val bottomNavHeight = 72.dp
    val bottomNavBottomPadding = 20.dp
    val screenBottomSpacer = 120.dp
}

object CoffeeShapes {
    val tiny = RoundedCornerShape(6.dp)
    val small = RoundedCornerShape(12.dp)
    val medium = RoundedCornerShape(16.dp)
    val large = RoundedCornerShape(20.dp)
    val xlarge = RoundedCornerShape(24.dp)
    // Figma "Social Refresh" uses very large radii (28–40dp). Tasteful native
    // equivalents shared across redesigned components.
    val xxlarge = RoundedCornerShape(28.dp)  // standard photo cards
    val hero = RoundedCornerShape(32.dp)     // hero surfaces / modals
    val immersive = RoundedCornerShape(40.dp) // full-bleed feed cards
    val sheet = RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp)
}

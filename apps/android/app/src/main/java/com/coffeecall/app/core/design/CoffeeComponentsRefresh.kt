package com.coffeecall.app.core.design

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage

/**
 * Refreshed shared components matching the Figma "Social Refresh" design.
 * Additive to the legacy components in Components.kt; screens migrate to these
 * per their own batch.
 */

// MARK: - Buttons -------------------------------------------------------------

enum class CoffeeButtonVariant { Primary, Accent, Peach, Secondary, Ghost }

@Composable
fun CoffeeButton(
    title: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: CoffeeButtonVariant = CoffeeButtonVariant.Primary,
    enabled: Boolean = true,
    fullWidth: Boolean = true,
    leadingIcon: ImageVector? = null,
    trailingIcon: ImageVector? = null,
    height: Dp = 52.dp
) {
    val container = when (variant) {
        CoffeeButtonVariant.Primary -> CoffeePrimary
        CoffeeButtonVariant.Accent -> CoffeePurple
        CoffeeButtonVariant.Peach -> CoffeePeach
        CoffeeButtonVariant.Secondary -> CoffeeSurfaceSecondary
        CoffeeButtonVariant.Ghost -> Color.Transparent
    }
    val content = when (variant) {
        CoffeeButtonVariant.Secondary -> CoffeeInk
        CoffeeButtonVariant.Ghost -> CoffeeMuted
        else -> CoffeeTextOnBrand
    }
    val widthModifier = if (fullWidth) Modifier.fillMaxWidth() else Modifier

    Row(
        modifier = modifier
            .then(widthModifier)
            .heightIn(min = height)
            .then(
                if (variant != CoffeeButtonVariant.Ghost && enabled) {
                    Modifier.shadow(
                        elevation = 12.dp,
                        shape = CoffeeShapes.medium,
                        ambientColor = container.copy(alpha = 0.30f),
                        spotColor = container.copy(alpha = 0.36f)
                    )
                } else Modifier
            )
            .clip(CoffeeShapes.medium)
            .background(if (enabled) container else CoffeeMuted.copy(alpha = 0.24f))
            .clickable(enabled = enabled, onClick = onClick)
            .padding(horizontal = CoffeeSpacing.lg, vertical = CoffeeSpacing.sm),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (leadingIcon != null) {
            Icon(leadingIcon, contentDescription = null, tint = content, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(CoffeeSpacing.xs))
        }
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            color = if (enabled) content else CoffeeTextOnBrand.copy(alpha = 0.72f),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
        if (trailingIcon != null) {
            Spacer(Modifier.width(CoffeeSpacing.xs))
            Icon(trailingIcon, contentDescription = null, tint = content, modifier = Modifier.size(20.dp))
        }
    }
}

// MARK: - Avatar --------------------------------------------------------------

@Composable
fun CoffeeAvatar(
    name: String,
    modifier: Modifier = Modifier,
    imageUrl: String? = null,
    size: Dp = 40.dp,
    background: Color = CoffeePrimary,
    ringColor: Color? = CoffeeTextOnBrand
) {
    val base = modifier
        .size(size)
        .clip(CircleShape)
        .then(if (ringColor != null) Modifier.border(2.dp, ringColor, CircleShape) else Modifier)

    if (!imageUrl.isNullOrBlank()) {
        AsyncImage(
            model = imageUrl,
            contentDescription = name,
            contentScale = ContentScale.Crop,
            modifier = base.background(background)
        )
    } else {
        Box(modifier = base.background(background), contentAlignment = Alignment.Center) {
            Text(
                text = name.initials(),
                style = MaterialTheme.typography.labelMedium,
                color = CoffeeTextOnBrand
            )
        }
    }
}

private fun String.initials(): String =
    split(" ", limit = 2)
        .mapNotNull { it.firstOrNull()?.uppercase() }
        .joinToString("")
        .take(2)
        .ifBlank { "?" }

// MARK: - Glass badge ---------------------------------------------------------

@Composable
fun CoffeeGlassBadge(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    showLiveDot: Boolean = false,
    containerColor: Color = Color.White.copy(alpha = 0.18f),
    contentColor: Color = Color.White
) {
    Row(
        modifier = modifier
            .clip(CircleShape)
            .background(containerColor)
            .border(1.dp, Color.White.copy(alpha = 0.30f), CircleShape)
            .padding(horizontal = 10.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        if (showLiveDot) {
            Box(
                modifier = Modifier
                    .size(6.dp)
                    .clip(CircleShape)
                    .background(CoffeePrimary)
            )
        }
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = contentColor, modifier = Modifier.size(12.dp))
        }
        Text(
            text = title,
            style = MaterialTheme.typography.labelSmall,
            color = contentColor,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

// MARK: - Immersive Drift card (Photo-forward) --------------------------------

/**
 * Photo-forward Drift card used in immersive feeds.
 */
@Composable
fun CoffeeDriftCardImmersive(
    title: String,
    hostName: String,
    category: String,
    distanceText: String,
    timeText: String,
    onJoin: () -> Unit,
    modifier: Modifier = Modifier,
    imageUrl: String? = null,
    hostImageUrl: String? = null,
    statusLabel: String? = null,
    vibe: String? = null,
    peopleGoing: Int = 1,
    isFeatured: Boolean = false,
    actionLabel: String = "I'm in",
    actionColor: Color = CoffeePrimary,
    onClick: (() -> Unit)? = null
) {
    val height: Dp = if (isFeatured) 320.dp else 280.dp
    val accent = categoryAccent(category)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .shadow(16.dp, CoffeeShapes.xxlarge, ambientColor = CoffeeDarkOverlay.copy(alpha = 0.10f), spotColor = CoffeeDarkOverlay.copy(alpha = 0.16f))
            .clip(CoffeeShapes.xxlarge)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
    ) {
        // Image / fallback
        if (!imageUrl.isNullOrBlank()) {
            AsyncImage(
                model = imageUrl,
                contentDescription = title,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        } else {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        Brush.linearGradient(listOf(accent, accent.copy(alpha = 0.55f)))
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    CoffeeIcons.category(category),
                    contentDescription = null,
                    tint = Color.White.copy(alpha = 0.18f),
                    modifier = Modifier.size(72.dp)
                )
            }
        }

        // Legibility gradient
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        0.45f to Color.Transparent,
                        0.75f to CoffeeDarkOverlay.copy(alpha = 0.35f),
                        1f to CoffeeDarkOverlay.copy(alpha = 0.92f)
                    )
                )
        )

        // Top badges
        Row(
            modifier = Modifier
                .align(Alignment.TopStart)
                .fillMaxWidth()
                .padding(CoffeeSpacing.screen),
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
            verticalAlignment = Alignment.Top
        ) {
            if (isFeatured) {
                CoffeeGlassBadge(title = "BEST MATCH", icon = CoffeeIcons.bolt)
            }
            if (statusLabel != null) {
                CoffeeGlassBadge(title = statusLabel.uppercase(), showLiveDot = true)
            }
            Spacer(Modifier.weight(1f))
            if (vibe != null) {
                CoffeeGlassBadge(
                    title = vibe.uppercase(),
                    containerColor = CoffeePurple,
                    contentColor = CoffeeTextOnBrand
                )
            }
        }

        // Bottom content
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .padding(CoffeeSpacing.screen),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
                CoffeeAvatar(name = hostName, imageUrl = hostImageUrl, size = 36.dp, background = accent)
                Text(
                    text = hostName,
                    style = MaterialTheme.typography.titleMedium,
                    color = CoffeeTextOnBrand,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                if (peopleGoing > 1) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(CircleShape)
                            .background(CoffeeTextOnBrand),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("+${peopleGoing - 1}", style = MaterialTheme.typography.labelSmall, color = CoffeeInk)
                    }
                }
            }

            Text(
                text = title,
                style = MaterialTheme.typography.headlineMedium,
                color = CoffeeTextOnBrand,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md), verticalAlignment = Alignment.CenterVertically) {
                CoffeeMetaItem(icon = CoffeeIcons.location, tint = CoffeePrimary, text = distanceText)
                CoffeeMetaItem(icon = CoffeeIcons.clock, tint = CoffeePurple, text = timeText)
            }

            CoffeeButton(
                title = actionLabel,
                onClick = onJoin,
                variant = CoffeeButtonVariant.Primary,
                trailingIcon = CoffeeIcons.arrowUpRight,
                height = 48.dp,
                modifier = Modifier.padding(top = CoffeeSpacing.xxs)
            )
        }
    }
}

// MARK: - Light Drift card (Standard) ------------------------------------------

/**
 * Standard Light Drift card matching the refreshed iOS "Drifts" tab design.
 */
@Composable
fun CoffeeDriftCard(
    title: String,
    location: String,
    timeText: String,
    distanceText: String,
    category: String,
    onAction: () -> Unit,
    modifier: Modifier = Modifier,
    statusLabel: String? = "OPEN",
    isBestMatch: Boolean = false,
    participants: List<String> = emptyList(),
    participantSummary: String? = null,
    actionLabel: String = "I'm in",
    actionColor: Color = CoffeePrimary,
    onClick: (() -> Unit)? = null
) {
    val accent = categoryAccent(category)

    Surface(
        modifier = modifier
            .fillMaxWidth()
            .shadow(8.dp, CoffeeShapes.large, ambientColor = Color.Black.copy(alpha = 0.04f), spotColor = Color.Black.copy(alpha = 0.06f))
            .clip(CoffeeShapes.large)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier),
        color = Color.White,
        shape = CoffeeShapes.large
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Category Icon
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(accent.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = CoffeeIcons.category(category),
                        contentDescription = null,
                        tint = accent,
                        modifier = Modifier.size(24.dp)
                    )
                }

                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        if (isBestMatch) {
                            Surface(
                                color = CoffeePurple.copy(alpha = 0.12f),
                                shape = CircleShape
                            ) {
                                Text(
                                    text = "BEST MATCH",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = CoffeePurple,
                                    fontWeight = FontWeight.Black,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                        } else {
                            Spacer(Modifier.width(1.dp))
                        }

                        if (statusLabel != null) {
                            Text(
                                text = statusLabel.uppercase(),
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeePrimary,
                                fontWeight = FontWeight.Black,
                                modifier = Modifier
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(CoffeePrimary.copy(alpha = 0.1f))
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }

                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleLarge,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Black,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )

                    Text(
                        text = location,
                        style = MaterialTheme.typography.bodyMedium,
                        color = CoffeeMuted,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Text(
                        text = "$timeText • $distanceText",
                        style = MaterialTheme.typography.labelMedium,
                        color = CoffeeMuted,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (participants.isNotEmpty()) {
                        CoffeeParticipantOverlap(initials = participants)
                        Spacer(modifier = Modifier.width(8.dp))
                    }
                    if (participantSummary != null) {
                        Text(
                            text = participantSummary,
                            style = MaterialTheme.typography.labelMedium,
                            color = CoffeeMuted,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }

                Surface(
                    onClick = onAction,
                    color = actionColor,
                    shape = CircleShape
                ) {
                    Text(
                        text = actionLabel,
                        style = MaterialTheme.typography.labelMedium,
                        color = Color.White,
                        fontWeight = FontWeight.Black,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun CoffeeParticipantOverlap(initials: List<String>) {
    Row(horizontalArrangement = Arrangement.spacedBy((-8).dp)) {
        initials.take(3).forEach { initial ->
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(categoryAccent("")) // fallback color
                    .border(1.5.dp, Color.White, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = initial.take(1),
                    style = MaterialTheme.typography.labelSmall.copy(fontSize = 10.sp),
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
private fun CoffeeMetaItem(icon: ImageVector, tint: Color, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(16.dp))
        Text(
            text = text,
            style = MaterialTheme.typography.labelMedium,
            color = CoffeeTextOnBrand.copy(alpha = 0.9f),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

/** Brand accent used for a category's fallback gradient + avatar. */
fun categoryAccent(category: String): Color = when (category.lowercase().trim()) {
    "coffee", "study", "yoga", "fitness", "walk", "walks" -> CoffeePrimary
    "food", "gaming", "games", "event" -> CoffeePeach
    "movie", "movies", "music", "creative" -> CoffeePurple
    else -> CoffeePrimary
}

@Preview(showBackground = true, widthDp = 390)
@Composable
private fun CoffeeDriftCardPreview() {
    CoffeeCallTheme {
        Column(
            modifier = Modifier
                .background(CoffeeBackground)
                .padding(CoffeeSpacing.screen),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.lg)
        ) {
            CoffeeDriftCard(
                title = "Sunset walk and easy conversation",
                location = "Cubbon Park",
                distanceText = "1.4 km",
                timeText = "6:30 PM",
                category = "walk",
                statusLabel = "Starting Soon",
                participants = listOf("R", "G"),
                participantSummary = "3g • 1s • Relaxed",
                actionLabel = "Join Moment",
                onAction = {}
            )
            CoffeeButton(title = "Continue", onClick = {}, trailingIcon = CoffeeIcons.arrowUpRight)
            CoffeeButton(title = "Maybe later", onClick = {}, variant = CoffeeButtonVariant.Ghost)
        }
    }
}

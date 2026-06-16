package com.coffeecall.app.core.design

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun CoffeePrimaryButton(
    title: String,
    modifier: Modifier = Modifier,
    trailingSymbol: String? = null,
    enabled: Boolean = true,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = CoffeeSpacing.primaryButtonHeight)
            .shadow(
                elevation = if (enabled) 14.dp else 0.dp,
                shape = CoffeeShapes.medium,
                ambientColor = CoffeePrimary.copy(alpha = 0.18f),
                spotColor = CoffeePrimary.copy(alpha = 0.24f)
            ),
        shape = CoffeeShapes.medium,
        colors = ButtonDefaults.buttonColors(
            containerColor = CoffeePrimary,
            contentColor = CoffeeTextOnBrand,
            disabledContainerColor = CoffeeMuted.copy(alpha = 0.24f),
            disabledContentColor = CoffeeTextOnBrand.copy(alpha = 0.72f)
        ),
        border = BorderStroke(1.dp, CoffeeTextOnBrand.copy(alpha = if (enabled) 0.12f else 0.08f)),
        contentPadding = ButtonDefaults.ButtonWithIconContentPadding
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis
        )
        if (trailingSymbol != null) {
            Spacer(modifier = Modifier.width(CoffeeSpacing.xs))
            Text(
                text = trailingSymbol,
                style = MaterialTheme.typography.labelLarge
            )
        }
    }
}

@Composable
fun CoffeePillBadge(
    title: String,
    modifier: Modifier = Modifier,
    symbol: String? = null,
    containerColor: Color = CoffeePrimaryDark.copy(alpha = 0.92f),
    contentColor: Color = CoffeeTextOnBrand
) {
    Row(
        modifier = modifier
            .clip(CircleShape)
            .background(containerColor)
            .border(1.dp, CoffeeTextOnBrand.copy(alpha = 0.14f), CircleShape)
            .padding(horizontal = CoffeeSpacing.sm, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        if (symbol != null) {
            Text(text = symbol, style = MaterialTheme.typography.labelSmall, color = contentColor)
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

@Composable
fun CoffeeCategoryChip(
    title: String,
    selected: Boolean,
    modifier: Modifier = Modifier,
    symbol: String? = null,
    icon: ImageVector? = null,
    count: Int? = null,
    onClick: () -> Unit
) {
    val container = if (selected) CoffeePrimary else CoffeeSurface
    val content = if (selected) CoffeeTextOnBrand else CoffeeInk

    Row(
        modifier = modifier
            .heightIn(min = CoffeeSpacing.minTouchTarget)
            .clip(CircleShape)
            .background(container)
            .border(1.dp, if (selected) Color.Transparent else CoffeeBorder, CircleShape)
            .clickable(onClick = onClick)
            .padding(horizontal = 18.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = content, modifier = Modifier.size(16.dp))
        } else if (symbol != null) {
            Text(text = symbol, style = MaterialTheme.typography.labelMedium, color = content)
        }
        Text(
            text = title,
            style = MaterialTheme.typography.labelMedium,
            color = content,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
        if (count != null) {
            Text(
                text = count.toString(),
                style = MaterialTheme.typography.labelSmall,
                color = content,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(if (selected) CoffeeTextOnBrand.copy(alpha = 0.20f) else CoffeePrimary.copy(alpha = 0.10f))
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            )
        }
    }
}

@Composable
fun CoffeeActivityChip(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    symbol: String,
    accent: Color = CoffeePrimary
) {
    Surface(
        modifier = modifier,
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder),
        shadowElevation = 5.dp
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(accent.copy(alpha = 0.16f)),
                contentAlignment = Alignment.Center
            ) {
                Text(text = symbol, style = MaterialTheme.typography.titleMedium, color = accent)
            }
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    color = CoffeeInk,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeMuted,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

@Composable
fun CoffeeDriftCardPlaceholder(
    title: String,
    location: String,
    timeAndDistance: String,
    modifier: Modifier = Modifier,
    status: String = "OPEN",
    categorySymbol: String = "C",
    hook: String? = null,
    participants: List<String> = listOf("RG", "AM", "JL"),
    actionLabel: String = "I'm in"
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        shadowElevation = 8.dp
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                verticalAlignment = Alignment.Top
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(CoffeePrimary.copy(alpha = 0.16f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = categorySymbol,
                        style = MaterialTheme.typography.titleMedium,
                        color = CoffeePrimary
                    )
                }
                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        CoffeePillBadge(
                            title = "BEST MATCH",
                            containerColor = CoffeePurple.copy(alpha = 0.12f),
                            contentColor = CoffeePurple
                        )
                        Spacer(modifier = Modifier.weight(1f))
                        Text(
                            text = status,
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeeSuccess,
                            modifier = Modifier
                                .clip(CoffeeShapes.tiny)
                                .background(CoffeeSuccess.copy(alpha = 0.10f))
                                .padding(horizontal = 6.dp, vertical = 3.dp)
                        )
                    }
                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleLarge,
                        color = CoffeeInk,
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
                        text = timeAndDistance,
                        style = MaterialTheme.typography.labelMedium,
                        color = CoffeeMuted,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            if (!hook.isNullOrBlank()) {
                Text(
                    text = hook,
                    style = MaterialTheme.typography.labelMedium,
                    color = CoffeeInk,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(CoffeeShapes.small)
                        .background(CoffeePeach.copy(alpha = 0.10f))
                        .padding(horizontal = CoffeeSpacing.sm, vertical = 10.dp),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                Row(horizontalArrangement = Arrangement.spacedBy((-8).dp)) {
                    participants.take(3).forEach { initials ->
                        Box(
                            modifier = Modifier
                                .size(28.dp)
                                .clip(CircleShape)
                                .background(CoffeePrimary)
                                .border(1.5.dp, CoffeeTextOnBrand, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = initials.take(2),
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeTextOnBrand
                            )
                        }
                    }
                }
                Text(
                    text = "  3 going • 2 spots left",
                    style = MaterialTheme.typography.labelMedium,
                    color = CoffeeMuted,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )
                Text(
                    text = actionLabel,
                    style = MaterialTheme.typography.labelMedium,
                    color = CoffeeTextOnBrand,
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(CoffeePrimary)
                        .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs)
                )
            }
        }
    }
}

@Composable
fun CoffeeLoadingState(
    label: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(CoffeeSpacing.xl),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
    ) {
        CircularProgressIndicator(color = CoffeePrimary)
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = CoffeeMuted
        )
    }
}

@Composable
fun CoffeeEmptyState(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    symbol: String = "CC",
    icon: ImageVector? = null,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = CoffeeShapes.xlarge,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.xl),
            horizontalAlignment = Alignment.Start,
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(CoffeePurple.copy(alpha = 0.14f)),
                contentAlignment = Alignment.Center
            ) {
                if (icon != null) {
                    Icon(icon, contentDescription = null, tint = CoffeePurple, modifier = Modifier.size(26.dp))
                } else {
                    Text(text = symbol, style = MaterialTheme.typography.titleMedium, color = CoffeePurple)
                }
            }
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge,
                color = CoffeeInk
            )
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodyLarge,
                color = CoffeeMuted
            )
            if (actionLabel != null && onAction != null) {
                CoffeePrimaryButton(title = actionLabel, trailingSymbol = "+", onClick = onAction)
            }
        }
    }
}

@Composable
fun CoffeeTopAppBar(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = CoffeeSpacing.screen, vertical = CoffeeSpacing.sm),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = title,
                style = MaterialTheme.typography.headlineMedium,
                color = CoffeeInk,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
        }
        if (actionLabel != null && onAction != null) {
            Spacer(modifier = Modifier.width(CoffeeSpacing.md))
            Text(
                text = actionLabel,
                style = MaterialTheme.typography.labelMedium,
                color = CoffeePrimaryDark,
                modifier = Modifier
                    .heightIn(min = CoffeeSpacing.minTouchTarget)
                    .clip(CircleShape)
                    .background(CoffeeSurface)
                    .border(1.dp, CoffeeBorder, CircleShape)
                    .clickable(onClick = onAction)
                    .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm)
            )
        }
    }
}

@Composable
fun CoffeeHeroActivityCard(
    title: String,
    host: String,
    meta: String,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(4f / 5f)
            .clip(RoundedCornerShape(32.dp))
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        CoffeePeach.copy(alpha = 0.78f),
                        CoffeePurple.copy(alpha = 0.84f),
                        CoffeeDarkOverlay.copy(alpha = 0.92f)
                    )
                )
            )
            .border(1.dp, CoffeeBorder, RoundedCornerShape(32.dp))
            .padding(CoffeeSpacing.lg)
    ) {
        Row(
            modifier = Modifier.align(Alignment.TopStart),
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
        ) {
            CoffeePillBadge(title = "OPEN NOW", symbol = "•")
            CoffeePillBadge(title = "WALKS", containerColor = CoffeePurple)
        }
        Column(
            modifier = Modifier.align(Alignment.BottomStart),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Text(text = host, style = MaterialTheme.typography.titleMedium, color = CoffeeTextOnBrand)
            Text(
                text = title,
                style = MaterialTheme.typography.headlineLarge,
                color = CoffeeTextOnBrand,
                maxLines = 3,
                overflow = TextOverflow.Ellipsis
            )
            Text(text = meta, style = MaterialTheme.typography.labelMedium, color = CoffeeTextOnBrand.copy(alpha = 0.88f))
            CoffeePrimaryButton(title = "Join Moment", trailingSymbol = "↗", onClick = {})
        }
    }
}

@Preview(showBackground = true, widthDp = 320)
@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun CoffeeComponentsPreviewSmall() {
    CoffeeCallTheme {
        Column(
            modifier = Modifier
                .background(CoffeeBackground)
                .padding(CoffeeSpacing.screen),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            CoffeeTopAppBar(title = "Around", subtitle = "People nearby are open to plans") // kept for preview parity but main header is implemented in DiscoveryScreen as a pill Surface
            CoffeePrimaryButton(title = "Find meetups nearby", trailingSymbol = "↗", onClick = {})
            FlowRow(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
                CoffeeCategoryChip(title = "Coffee", selected = true, symbol = "C", count = 8, onClick = {})
                CoffeeCategoryChip(title = "Walks", selected = false, symbol = "W", onClick = {})
            }
            CoffeeDriftCardPlaceholder(
                title = "Evening walk through the park",
                location = "Cubbon Park",
                timeAndDistance = "Today 6:30 PM • 1.2 km",
                hook = "Bring a coffee, I will bring a ridiculous conversation starter."
            )
            CoffeeEmptyState(
                title = "No Drifts yet",
                subtitle = "Create a small plan and let nearby people join the moment.",
                actionLabel = "Create Drift",
                onAction = {}
            )
        }
    }
}

@Preview(showBackground = true, widthDp = 390)
@Composable
private fun CoffeeHeroPreview() {
    CoffeeCallTheme {
        CoffeeHeroActivityCard(
            title = "Sunset walk and easy conversation",
            host = "Hosted by Robin",
            meta = "1.4 km away • Starts at 6:30 PM",
            modifier = Modifier
                .background(CoffeeBackground)
                .padding(CoffeeSpacing.screen)
        )
    }
}

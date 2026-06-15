package com.coffeecall.app.core.design

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.verticalScroll

@Composable
fun PlaceholderScreen(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    eyebrow: String = "COFFEECALL BETA",
    primaryActionLabel: String? = null,
    featuredTitle: String = "Sunset walk and easy conversation",
    featuredMeta: String = "1.4 km away • Starts at 6:30 PM",
    showHero: Boolean = false,
    showDriftCard: Boolean = true,
    emptyTitle: String = "Nothing here yet",
    emptySubtitle: String = "This native Android screen is waiting for its feature batch."
) {
    Surface(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(
                    PaddingValues(
                        start = CoffeeSpacing.screen,
                        top = 112.dp,
                        end = CoffeeSpacing.screen,
                        bottom = CoffeeSpacing.screenBottomSpacer
                    )
                )
        ) {
            CoffeePillBadge(
                title = eyebrow,
                symbol = "•",
                containerColor = CoffeePrimaryDark.copy(alpha = 0.92f)
            )
            Text(
                text = title,
                modifier = Modifier.padding(top = CoffeeSpacing.md),
                style = MaterialTheme.typography.headlineLarge,
                color = CoffeeInk
            )
            Text(
                text = subtitle,
                modifier = Modifier.padding(top = CoffeeSpacing.xs),
                style = MaterialTheme.typography.bodyLarge,
                color = CoffeeMuted
            )
            if (primaryActionLabel != null) {
                CoffeePrimaryButton(
                    title = primaryActionLabel,
                    trailingSymbol = "↗",
                    modifier = Modifier.padding(top = CoffeeSpacing.lg),
                    onClick = {}
                )
            }

            if (showHero) {
                CoffeeHeroActivityCard(
                    title = featuredTitle,
                    host = "Hosted by CoffeeCall",
                    meta = featuredMeta,
                    modifier = Modifier.padding(top = CoffeeSpacing.xl)
                )
            }

            if (showDriftCard) {
                CoffeeDriftCardPlaceholder(
                    title = featuredTitle,
                    location = "Indiranagar, Bengaluru",
                    timeAndDistance = featuredMeta,
                    hook = "Exact details unlock after joining. Chat stays tied to the Drift.",
                    modifier = Modifier.padding(top = CoffeeSpacing.xl)
                )
            }

            CoffeeEmptyState(
                title = emptyTitle,
                subtitle = emptySubtitle,
                symbol = title.take(2).uppercase(),
                modifier = Modifier.padding(top = CoffeeSpacing.md)
            )

            CoffeeLoadingState(
                label = "Preparing native Android placeholders...",
                modifier = Modifier.padding(top = CoffeeSpacing.md)
            )

            Spacer(modifier = Modifier.padding(bottom = CoffeeSpacing.md))
        }
    }
}

@Preview(showBackground = true, widthDp = 320)
@Composable
private fun PlaceholderScreenPreview() {
    CoffeeCallTheme {
        PlaceholderScreen(
            title = "Around",
            subtitle = "People nearby are open to plans",
            primaryActionLabel = "Start Drift",
            showHero = true
        )
    }
}

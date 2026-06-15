package com.coffeecall.app.feature.drifts

import android.app.Application
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.*
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus

@Composable
fun DriftsScreen(
    onDriftClick: (String) -> Unit = {}
) {
    val context = LocalContext.current
    val application = context.applicationContext as Application
    val viewModel: DriftsViewModel = viewModel(
        factory = DriftsViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()

    var selectedTab by remember { mutableStateOf(0) } // 0 = Joined, 1 = Hosting

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = CoffeeSpacing.screen)
            .padding(top = 104.dp, bottom = CoffeeSpacing.screenBottomSpacer),
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
    ) {
        if (uiState.isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = CoffeePrimary)
            }
        } else if (uiState.error != null) {
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = CoffeeShapes.medium,
                color = CoffeeSurface,
                border = BorderStroke(1.dp, CoffeeBorder)
            ) {
                Column(
                    modifier = Modifier.padding(CoffeeSpacing.md),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                ) {
                    Text(text = "⚠️", fontSize = 24.sp)
                    Text(text = "Failed to load plans", fontWeight = FontWeight.Bold, color = CoffeeInk)
                    Text(text = uiState.error ?: "", color = CoffeeMuted, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
                    Button(
                        onClick = { viewModel.loadDrifts() },
                        colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary)
                    ) {
                        Text("Retry")
                    }
                }
            }
        } else {
            // Tab switchers
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                TabButton(
                    title = "Joined",
                    isSelected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    modifier = Modifier.weight(1f)
                )
                TabButton(
                    title = "Hosting",
                    isSelected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(2.dp))

            val currentList = if (selectedTab == 0) uiState.joinedDrifts else uiState.hostedDrifts

            if (currentList.isEmpty()) {
                val emptyTitle = if (selectedTab == 0) "No joined Drifts yet" else "No hosted Drifts yet"
                val emptySubtitle = if (selectedTab == 0) {
                    "Browse nearby plans or request to join a coffee meetup to see it here."
                } else {
                    "Host your own meetup: share what you're up for and let others join."
                }
                CoffeeEmptyState(
                    title = emptyTitle,
                    subtitle = emptySubtitle,
                    symbol = if (selectedTab == 0) "J" else "H",
                    actionLabel = null,
                    onAction = {}
                )
            } else {
                currentList.forEach { drift ->
                    DriftCard(drift = drift, onClick = { onDriftClick(drift.id) })
                }
            }
        }
    }
}

@Composable
private fun TabButton(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val backgroundColor = if (isSelected) CoffeePrimary else CoffeeSurface
    val contentColor = if (isSelected) CoffeeTextOnBrand else CoffeeInk
    val borderColor = if (isSelected) Color.Transparent else CoffeeBorder

    Surface(
        onClick = onClick,
        shape = CoffeeShapes.small,
        color = backgroundColor,
        border = BorderStroke(1.dp, borderColor),
        modifier = modifier.height(40.dp)
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(
                text = title,
                color = contentColor,
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun DriftCard(
    drift: DriftPost,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder),
        shadowElevation = 8.dp
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                // Category Icon
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(categoryColor(drift.category).copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = categorySymbol(drift.category),
                        style = MaterialTheme.typography.titleMedium,
                        color = categoryColor(drift.category)
                    )
                }

                // Info
                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        CoffeePillBadge(
                            title = drift.status.firestoreValue,
                            containerColor = CoffeePrimary.copy(alpha = 0.12f),
                            contentColor = CoffeePrimaryDark
                        )
                    }

                    Text(
                        text = drift.title.ifBlank { "Untitled Drift" },
                        style = MaterialTheme.typography.titleLarge,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Bold,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )

                    Text(
                        text = "${drift.date} • ${drift.time} at ${drift.location}",
                        style = MaterialTheme.typography.bodyMedium,
                        color = CoffeeMuted,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            if (drift.hook.isNotBlank()) {
                Text(
                    text = drift.hook,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeInk,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(CoffeeShapes.small)
                        .background(CoffeePeach.copy(alpha = 0.10f))
                        .padding(CoffeeSpacing.sm),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                // Participants initials
                Row(horizontalArrangement = Arrangement.spacedBy((-6).dp)) {
                    drift.participantInitials.take(3).forEach { initials ->
                        Box(
                            modifier = Modifier
                                .size(24.dp)
                                .clip(CircleShape)
                                .background(CoffeePrimary)
                                .border(1.5.dp, CoffeeTextOnBrand, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = initials.take(2),
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeTextOnBrand,
                                fontSize = 10.sp
                            )
                        }
                    }
                }
                val goingLabel = if (drift.participantCount == 1) "1 going" else "${drift.participantCount} going"
                val spotsLabel = if (drift.spotsLeft == 1) "1 spot left" else "${drift.spotsLeft} spots left"
                Text(
                    text = "  $goingLabel • $spotsLabel",
                    style = MaterialTheme.typography.labelMedium,
                    color = CoffeeMuted,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

private fun categorySymbol(cat: DriftCategory): String =
    when (cat) {
        DriftCategory.Coffee -> "☕"
        DriftCategory.Walk -> "🚶"
        DriftCategory.Movie -> "🎬"
        DriftCategory.Food -> "🍔"
        DriftCategory.Study -> "📖"
        DriftCategory.Gaming -> "🎮"
        DriftCategory.Music -> "🎵"
        DriftCategory.Yoga -> "🧘"
        DriftCategory.Event -> "🎟️"
    }

private fun categoryColor(cat: DriftCategory): Color =
    when (cat) {
        DriftCategory.Coffee -> CoffeePrimary
        DriftCategory.Walk -> CoffeePeach
        DriftCategory.Movie -> CoffeePurple
        else -> CoffeePrimary
    }

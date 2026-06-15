package com.coffeecall.app.feature.profile

import android.app.Application
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.coffeecall.app.core.design.*
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ProfileScreen(
    onEditClick: () -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as Application
    val viewModel: ProfileViewModel = viewModel(
        factory = ProfileViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()

    var selectedTab by remember { mutableStateOf(0) } // 0 = Hosted, 1 = Joined

    LaunchedEffect(Unit) {
        viewModel.loadProfile()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = CoffeeSpacing.screen)
        ) {
            Spacer(modifier = Modifier.height(104.dp)) // Header bar padding

            if (uiState.isLoading && uiState.user == null) {
                Box(modifier = Modifier.fillMaxWidth().height(300.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = CoffeePrimary)
                }
            } else {
                val user = uiState.user
                if (user != null) {
                    // Profile Card Details
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = CoffeeShapes.large,
                        color = CoffeeSurface,
                        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder),
                        shadowElevation = 4.dp
                    ) {
                        Column(
                            modifier = Modifier.padding(CoffeeSpacing.md),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            // Avatar
                            Box(
                                modifier = Modifier
                                    .size(100.dp)
                                    .clip(RoundedCornerShape(32.dp))
                                    .background(CoffeeSurfaceSecondary),
                                contentAlignment = Alignment.Center
                            ) {
                                if (user.profilePhotoUrl.isNotBlank()) {
                                    AsyncImage(
                                        model = user.profilePhotoUrl,
                                        contentDescription = "Profile Photo",
                                        modifier = Modifier.fillMaxSize(),
                                        contentScale = ContentScale.Crop
                                    )
                                } else {
                                    Box(
                                        modifier = Modifier
                                            .fillMaxSize()
                                            .background(CoffeePurple.copy(alpha = 0.16f)),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = user.initials.ifBlank { "U" },
                                            fontSize = 28.sp,
                                            color = CoffeePurple,
                                            fontWeight = FontWeight.Black
                                        )
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(CoffeeSpacing.sm))

                            Text(
                                text = user.name.ifBlank { "User" },
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = CoffeeInk
                            )

                            if (user.location.isNotBlank()) {
                                Text(
                                    text = "📍 ${user.location}",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = CoffeeMuted,
                                    modifier = Modifier.padding(vertical = 2.dp)
                                )
                            }

                            if (user.bio.isNotBlank()) {
                                Text(
                                    text = user.bio,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = CoffeeInk.copy(alpha = 0.72f),
                                    modifier = Modifier.padding(top = CoffeeSpacing.xs),
                                    lineHeight = 18.sp
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(CoffeeSpacing.md))

                    // Stats Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                    ) {
                        StatCard(
                            count = uiState.driftsHosted.toString(),
                            label = "Hosted",
                            modifier = Modifier.weight(1f)
                        )
                        StatCard(
                            count = uiState.driftsJoined.toString(),
                            label = "Joined",
                            modifier = Modifier.weight(1f)
                        )
                        StatCard(
                            count = (uiState.driftsHosted + uiState.driftsJoined).toString(),
                            label = "Total Drifts",
                            modifier = Modifier.weight(1f)
                        )
                    }

                    Spacer(modifier = Modifier.height(CoffeeSpacing.md))

                    // Availability & Interests
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = CoffeeShapes.medium,
                        color = CoffeeSurface,
                        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
                    ) {
                        Column(modifier = Modifier.padding(CoffeeSpacing.md), verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                            // Availability
                            val availabilityList = mutableListOf<String>()
                            if (user.availabilityWeekdayEvenings) availabilityList.add("Weekday Evenings")
                            if (user.availabilityWeekends) availabilityList.add("Weekends")
                            if (user.availabilityDaytime) availabilityList.add("Daytime")
                            val availabilitySummary = if (availabilityList.isEmpty()) "Not set" else availabilityList.joinToString(", ")

                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("📅", fontSize = 16.sp)
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = "Availability: $availabilitySummary",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = CoffeeInk,
                                    fontWeight = FontWeight.SemiBold
                                )
                            }

                            // Interests tags
                            if (user.interests.isNotEmpty()) {
                                FlowRow(
                                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                                    modifier = Modifier.padding(top = 4.dp)
                                ) {
                                    user.interests.forEach { interest ->
                                        Surface(
                                            shape = CircleShape,
                                            color = CoffeeSurfaceSecondary,
                                            border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder),
                                            modifier = Modifier.height(28.dp)
                                        ) {
                                            Box(
                                                modifier = Modifier.padding(horizontal = CoffeeSpacing.sm),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Text(
                                                    text = interest.replaceFirstChar { it.uppercase() },
                                                    color = CoffeePrimaryDark,
                                                    style = MaterialTheme.typography.labelSmall,
                                                    fontWeight = FontWeight.Bold
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(CoffeeSpacing.md))

                    // History Section Header/Tabs
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                    ) {
                        HistoryTabButton(
                            title = "Hosted History",
                            isSelected = selectedTab == 0,
                            onClick = { selectedTab = 0 },
                            modifier = Modifier.weight(1f)
                        )
                        HistoryTabButton(
                            title = "Joined History",
                            isSelected = selectedTab == 1,
                            onClick = { selectedTab = 1 },
                            modifier = Modifier.weight(1f)
                        )
                    }

                    Spacer(modifier = Modifier.height(CoffeeSpacing.sm))

                    // Drifts History List
                    val historyPosts = uiState.historyDrifts.filter {
                        if (selectedTab == 0) it.creatorId == user.uid else it.creatorId != user.uid
                    }

                    if (historyPosts.isEmpty()) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = CoffeeSpacing.xxl),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = if (selectedTab == 0) "No hosted drifts yet." else "No joined drifts yet.",
                                style = MaterialTheme.typography.bodyMedium,
                                color = CoffeeMuted
                            )
                        }
                    } else {
                        Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                            historyPosts.forEach { drift ->
                                HistoryDriftCard(drift = drift)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(132.dp)) // Floating Bottom Navigation spacer
        }

        // Edit button overlay top right
        Box(
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(top = 20.dp, end = CoffeeSpacing.screen)
                .height(56.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Edit",
                color = CoffeePrimary,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Black,
                modifier = Modifier
                    .clickable(onClick = onEditClick)
                    .padding(8.dp)
            )
        }
    }
}

@Composable
private fun StatCard(
    count: String,
    label: String,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier,
        shape = CoffeeShapes.medium,
        color = CoffeeSurface,
        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
    ) {
        Column(
            modifier = Modifier.padding(vertical = CoffeeSpacing.sm, horizontal = CoffeeSpacing.xs),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = count,
                fontSize = 24.sp,
                fontWeight = FontWeight.Black,
                color = CoffeeInk
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = label,
                fontSize = 10.sp,
                color = CoffeeMuted,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun HistoryTabButton(
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
        border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
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
private fun HistoryDriftCard(
    drift: DriftPost
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.medium,
        color = CoffeeSurface,
        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            // Category Symbol
            val emoji = when (drift.category) {
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
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(CoffeePrimary.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Text(text = emoji, fontSize = 20.sp)
            }

            // Title & Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = drift.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = CoffeeInk,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "📍 ${drift.location}",
                    style = MaterialTheme.typography.bodySmall,
                    color = CoffeeMuted,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

package com.coffeecall.app.feature.drifts

import android.app.Application
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Apps
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.*
import com.coffeecall.app.core.navigation.NavigationManager
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus

@Composable
fun DriftsScreen(
    onDriftClick: (String) -> Unit = {},
    onNavigateToChat: (String) -> Unit = {}
) {
    val context = LocalContext.current
    val application = context.applicationContext as Application
    val viewModel: DriftsViewModel = viewModel(
        factory = DriftsViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()

    val navManager = remember { NavigationManager.getInstance() }
    val activeInterestFilter by navManager.activeInterestFilter.collectAsState()

    var selectedTab by remember { mutableStateOf(0) } // 0 = Discover, 1 = Mine
    var selectedFilter by remember { mutableStateOf("All") }
    var selectedInterestFilter by remember { mutableStateOf(activeInterestFilter) }
    var isSearchActive by remember { mutableStateOf(false) }
    var searchQuery by remember { mutableStateOf("") }

    LaunchedEffect(activeInterestFilter) {
        selectedInterestFilter = activeInterestFilter
    }

    val currentList = if (selectedTab == 1) {
        uiState.hostedDrifts
    } else {
        uiState.joinedDrifts
    }

    val visibleList = remember(currentList, selectedInterestFilter, selectedFilter, searchQuery, isSearchActive) {
        var filtered = currentList
        if (selectedInterestFilter != null) {
            filtered = filtered.filter { it.category.matchesInterest(selectedInterestFilter!!) }
        }
        when (selectedFilter) {
            "Open now" -> filtered = filtered.filter { it.status == DriftStatus.Open }
            "Starting soon" -> filtered = filtered.filter { it.status == DriftStatus.StartingSoon }
            "Tonight" -> filtered = filtered.filter { it.status == DriftStatus.Tonight }
        }
        if (isSearchActive && searchQuery.isNotBlank()) {
            val query = searchQuery.trim().lowercase()
            filtered = filtered.filter { drift ->
                drift.title.lowercase().contains(query) ||
                    drift.description.lowercase().contains(query) ||
                    drift.location.lowercase().contains(query) ||
                    drift.category.firestoreValue.lowercase().contains(query)
            }
        }
        filtered
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .verticalScroll(rememberScrollState())
            .padding(bottom = CoffeeSpacing.screenBottomSpacer),
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
    ) {
        // 1. Refreshed Header Card
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs),
            shape = RoundedCornerShape(32.dp),
            color = Color.White,
            shadowElevation = 8.dp
        ) {
            Row(
                modifier = Modifier.padding(horizontal = CoffeeSpacing.xl, vertical = CoffeeSpacing.lg),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Drifts",
                        style = MaterialTheme.typography.headlineLarge,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        text = if (selectedTab == 0) "Plans happening around you" else "Your active plans",
                        style = MaterialTheme.typography.bodyMedium,
                        color = CoffeeMuted,
                        fontWeight = FontWeight.Medium
                    )
                }

                Row(
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    HeaderIcon(icon = CoffeeIcons.bell)
                    HeaderIcon(icon = CoffeeIcons.search) {
                        isSearchActive = !isSearchActive
                        if (!isSearchActive) searchQuery = ""
                    }
                    HeaderIcon(icon = CoffeeIcons.filter)
                }
            }
        }

        if (isSearchActive) {
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = CoffeeSpacing.md),
                singleLine = true,
                leadingIcon = {
                    Icon(imageVector = CoffeeIcons.search, contentDescription = null, tint = CoffeeMuted)
                },
                trailingIcon = {
                    if (searchQuery.isNotBlank()) {
                        Icon(
                            imageVector = CoffeeIcons.close,
                            contentDescription = "Clear search",
                            tint = CoffeeMuted,
                            modifier = Modifier.clickable { searchQuery = "" }
                        )
                    }
                },
                placeholder = { Text("Search Drifts...") },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White,
                    focusedBorderColor = CoffeePrimary,
                    unfocusedBorderColor = CoffeeBorder
                )
            )
        }

        // 2. Discover | Mine Tab Switcher
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = CoffeeSpacing.md)
                .height(48.dp)
                .background(CoffeeBackground.copy(alpha = 0.5f), RoundedCornerShape(12.dp))
                .border(1.dp, CoffeeBorder.copy(alpha = 0.3f), RoundedCornerShape(12.dp)),
            verticalAlignment = Alignment.CenterVertically
        ) {
            DriftTabButton(
                title = "Discover",
                isSelected = selectedTab == 0,
                onClick = { selectedTab = 0 },
                modifier = Modifier.weight(1f)
            )
            DriftTabButton(
                title = "Mine",
                isSelected = selectedTab == 1,
                onClick = { selectedTab = 1 },
                modifier = Modifier.weight(1f)
            )
        }

        // 3. Filter Chips Row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = CoffeeSpacing.md),
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
            verticalAlignment = Alignment.CenterVertically
        ) {
            DriftFilterChip(
                label = "All",
                icon = null,
                isSelected = selectedFilter == "All",
                onClick = { selectedFilter = "All" }
            )
            DriftFilterChip(
                label = "Open now",
                icon = CoffeeIcons.bolt,
                isSelected = selectedFilter == "Open now",
                onClick = { selectedFilter = "Open now" }
            )
            DriftFilterChip(
                label = "Starting soon",
                icon = CoffeeIcons.clock,
                isSelected = selectedFilter == "Starting soon",
                onClick = { selectedFilter = "Starting soon" }
            )
            DriftFilterChip(
                label = "Tonight",
                icon = CoffeeIcons.clock,
                isSelected = selectedFilter == "Tonight",
                onClick = { selectedFilter = "Tonight" }
            )
        }

        // 4. Content Area
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = CoffeeSpacing.md),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            if (uiState.isLoading) {
                Box(modifier = Modifier.fillMaxWidth().height(200.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = CoffeePrimary)
                }
            } else if (uiState.error != null) {
                Text(text = "Error: ${uiState.error}", color = Color.Red, modifier = Modifier.padding(CoffeeSpacing.md))
            } else if (visibleList.isEmpty()) {
                CoffeeEmptyState(
                    title = "No drifts found",
                    subtitle = "Adjust your filters or try creating a new plan yourself.",
                    icon = CoffeeIcons.drifts,
                    actionLabel = "Create Drift",
                    onAction = { /* Navigate to create or show modal */ }
                )
            } else {
                val auth = remember { com.google.firebase.auth.FirebaseAuth.getInstance() }
                val currentUserId = auth.currentUser?.uid
                visibleList.forEach { drift ->
                    val isHost = currentUserId == drift.creatorId
                    CoffeeDriftCard(
                        title = drift.title.ifBlank { "Untitled Drift" },
                        location = drift.location,
                        timeText = drift.time,
                        distanceText = "0.0 km", // Mock distance
                        category = drift.category.name,
                        onAction = { onDriftClick(drift.id) },
                        statusLabel = drift.status.firestoreValue,
                        isBestMatch = drift.participantCount >= 2,
                        participants = drift.participantInitials,
                        participantSummary = "${drift.participantCount}g • 1s • Focused",
                    actionLabel = if (isHost || selectedTab == 1) "Manage" else "Joined",
                    actionColor = if (isHost || selectedTab == 1) CoffeePurple else CoffeePrimary,
                    onClick = { onDriftClick(drift.id) }
                )
            }
            }
        }
    }
}

@Composable
private fun HeaderIcon(icon: ImageVector, onClick: () -> Unit = {}) {
    Box(
        modifier = Modifier
            .size(CoffeeSpacing.minTouchTarget)
            .clip(CircleShape)
            .background(CoffeeBackground)
            .border(1.dp, CoffeeBorder.copy(alpha = 0.5f), CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(icon, contentDescription = null, tint = CoffeeInk.copy(alpha = 0.7f), modifier = Modifier.size(CoffeeSpacing.lg))
    }
}

@Composable
private fun DriftTabButton(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxHeight()
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier.fillMaxHeight(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelLarge,
                color = if (isSelected) CoffeePrimary else CoffeeMuted,
                fontWeight = if (isSelected) FontWeight.Black else FontWeight.Bold
            )
            if (isSelected) {
                Spacer(Modifier.height(CoffeeSpacing.xxs))
                Box(
                    modifier = Modifier
                        .width(40.dp)
                        .height(3.dp)
                        .clip(CircleShape)
                        .background(CoffeePrimary)
                )
            }
        }
    }
}

@Composable
private fun DriftFilterChip(
    label: String,
    icon: ImageVector?,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(12.dp),
        color = if (isSelected) CoffeePrimary else Color.White,
        border = BorderStroke(1.dp, if (isSelected) Color.Transparent else CoffeeBorder.copy(alpha = 0.5f)),
        modifier = Modifier.height(40.dp)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = CoffeeSpacing.sm),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
        ) {
            if (label == "All") {
                Icon(
                    imageVector = Icons.Rounded.Apps,
                    contentDescription = null,
                    tint = if (isSelected) Color.White else CoffeeMuted,
                    modifier = Modifier.size(CoffeeSpacing.md)
                )
            } else if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = if (isSelected) Color.White else CoffeeMuted,
                    modifier = Modifier.size(CoffeeSpacing.md)
                )
            }
            Text(
                text = label,
                style = MaterialTheme.typography.labelMedium,
                color = if (isSelected) Color.White else CoffeeInk,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

private fun DriftCategory.matchesInterest(interest: String): Boolean {
    val normalizedInterest = interest.normalizeInterest()
    val categoryNames = listOf(name, firestoreValue).map { it.normalizeInterest() }
    val aliases = when (this) {
        DriftCategory.Walk -> listOf("walk", "walks")
        DriftCategory.Movie -> listOf("movie", "movies")
        DriftCategory.Study -> listOf("study", "books", "book")
        DriftCategory.Yoga -> listOf("yoga", "workout", "fitness")
        DriftCategory.Event -> listOf("event", "events")
        else -> emptyList()
    }
    return normalizedInterest in categoryNames || normalizedInterest in aliases
}

private fun String.normalizeInterest(): String =
    trim().lowercase().removeSuffix("s")

private fun String.toDisplayInterest(): String =
    trim().ifBlank { "selected" }.replaceFirstChar { it.uppercase() }

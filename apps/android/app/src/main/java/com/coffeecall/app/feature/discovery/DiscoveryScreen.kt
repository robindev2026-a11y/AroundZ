package com.coffeecall.app.feature.discovery

import android.Manifest
import android.app.Application
import android.content.Context
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Canvas
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
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.CoffeeAvatar
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeButton
import com.coffeecall.app.core.design.CoffeeButtonVariant
import com.coffeecall.app.core.design.CoffeeCallTheme
import com.coffeecall.app.core.design.CoffeeDriftCard
import com.coffeecall.app.core.design.CoffeeEmptyState
import com.coffeecall.app.core.design.CoffeeError
import com.coffeecall.app.core.design.CoffeeGlassBadge
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePeach
import com.coffeecall.app.core.design.CoffeePillBadge
import com.coffeecall.app.core.design.CoffeePrimary
import com.coffeecall.app.core.design.CoffeePrimaryDark
import com.coffeecall.app.core.design.CoffeePurple
import com.coffeecall.app.core.design.CoffeeShapes
import com.coffeecall.app.core.design.CoffeeSpacing
import com.coffeecall.app.core.design.CoffeeSurface
import com.coffeecall.app.core.design.CoffeeSurfaceSecondary
import com.coffeecall.app.core.design.CoffeeTextOnBrand
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.core.location.AndroidLocationProvider
import com.coffeecall.app.core.location.CoffeeLocation
import com.coffeecall.app.core.location.GeoHash
import com.coffeecall.app.core.location.LocationState
import com.coffeecall.app.core.location.haversineDistanceKm
import com.coffeecall.app.core.permissions.LocationPermissionState
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.data.repository.FirebaseUserRepository
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.GeoLocation
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.domain.repository.UserRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun DiscoveryScreen(
    onDriftClick: (String) -> Unit = {},
    onNavigateToCreate: () -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as Application
    val viewModel: DiscoveryViewModel = viewModel(
        factory = DiscoveryViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions()
    ) { grants ->
        val granted = grants[Manifest.permission.ACCESS_FINE_LOCATION] == true ||
            grants[Manifest.permission.ACCESS_COARSE_LOCATION] == true
        viewModel.onPermissionResult(granted)
    }

    LaunchedEffect(Unit) {
        viewModel.refreshIfPermissionAlreadyGranted()
    }

    val context = LocalContext.current
    var searchQuery by remember { mutableStateOf("") }
    var activeFilter by remember { mutableStateOf("all") }
    var showAcceptModal by remember { mutableStateOf(false) }
    var showMatchModal by remember { mutableStateOf(false) }
    var selectedDrift by remember { mutableStateOf<DriftPost?>(null) }
    var isMapView by remember { mutableStateOf(false) }

    // Client-side filtering
    val filteredDrifts = uiState.nearbyDrifts.filter { drift ->
        val matchesFilter = activeFilter == "all" || 
            drift.category.firestoreValue.equals(activeFilter, ignoreCase = true) ||
            (activeFilter == "walks" && drift.category == DriftCategory.Walk)
        val matchesSearch = drift.title.contains(searchQuery, ignoreCase = true) ||
            drift.hook.contains(searchQuery, ignoreCase = true) ||
            drift.location.contains(searchQuery, ignoreCase = true) ||
            drift.creatorName.contains(searchQuery, ignoreCase = true)
        matchesFilter && matchesSearch
    }

    Box(modifier = Modifier.fillMaxSize()) {
        if (isMapView) {
            // Full Screen Map / Radar view Mode
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(CoffeeBackground)
                    .statusBarsPadding()
                    .padding(CoffeeSpacing.screen),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Header for Map mode
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Around Radar",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Black,
                            color = CoffeeInk,
                            modifier = Modifier.weight(1f)
                        )
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .shadow(2.dp, CoffeeShapes.medium)
                                .clip(CoffeeShapes.medium)
                                .background(Color.White)
                                .border(1.dp, CoffeeBorder, CoffeeShapes.medium)
                                .clickable { isMapView = false },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.close,
                                contentDescription = "Close Map",
                                tint = CoffeeInk,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    }

                    // Render Radar
                    Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                        when (uiState.locationState) {
                            LocationState.Denied -> PermissionCard {
                                permissionLauncher.launch(
                                    arrayOf(
                                        Manifest.permission.ACCESS_FINE_LOCATION,
                                        Manifest.permission.ACCESS_COARSE_LOCATION
                                    )
                                )
                            }
                            LocationState.Unavailable -> MessageCard(
                                title = "Location unavailable",
                                body = "We could not resolve your current area.",
                                actionLabel = "Try again",
                                onAction = { viewModel.refresh(forceLocationWrite = true) }
                            )
                            LocationState.Loading -> LoadingRadar()
                            is LocationState.Available -> AroundRadar(uiState.radarPeople)
                        }
                    }

                    CoffeeButton(
                        title = "Show List View",
                        onClick = { isMapView = false },
                        variant = CoffeeButtonVariant.Secondary
                    )
                }
            }
        } else {
            // Scrollable List Feed
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .background(CoffeeBackground)
                    .statusBarsPadding()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = CoffeeSpacing.screen)
                    .padding(top = CoffeeSpacing.md, bottom = CoffeeSpacing.screenBottomSpacer),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
            ) {
                // Top Header Section
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Hey ${uiState.currentUserName.ifBlank { "there" }}",
                            style = MaterialTheme.typography.headlineLarge,
                            color = CoffeeInk,
                            fontWeight = FontWeight.Black
                        )
                        Text(
                            text = "${filteredDrifts.size} meetups happening nearby",
                            style = MaterialTheme.typography.bodyMedium,
                            color = CoffeeMuted,
                            fontWeight = FontWeight.Medium
                        )
                    }

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Notifications button
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .shadow(elevation = 2.dp, shape = CoffeeShapes.medium)
                                .clip(CoffeeShapes.medium)
                                .background(Color.White)
                                .border(1.dp, CoffeeBorder, CoffeeShapes.medium)
                                .clickable {
                                    Toast.makeText(context, "No new notifications", Toast.LENGTH_SHORT).show()
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.bell,
                                contentDescription = "Notifications",
                                tint = CoffeePurple,
                                modifier = Modifier.size(20.dp)
                            )
                            // Notification dot
                            Box(
                                modifier = Modifier
                                    .align(Alignment.TopEnd)
                                    .padding(top = 12.dp, end = 12.dp)
                                    .size(8.dp)
                                    .clip(CircleShape)
                                    .background(CoffeePrimary)
                                    .border(1.dp, Color.White, CircleShape)
                            )
                        }

                        // Map view mode toggle
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .shadow(elevation = 2.dp, shape = CoffeeShapes.medium)
                                .clip(CoffeeShapes.medium)
                                .background(Color.White)
                                .border(1.dp, CoffeeBorder, CoffeeShapes.medium)
                                .clickable { isMapView = true },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.map,
                                contentDescription = "Map view",
                                tint = CoffeePrimary,
                                modifier = Modifier.size(20.dp)
                            )
                        }

                        // Avatar
                        CoffeeAvatar(
                            name = uiState.currentUserName,
                            imageUrl = uiState.currentUserPhotoUrl,
                            size = 48.dp,
                            ringColor = CoffeePrimary.copy(alpha = 0.2f)
                        )
                    }
                }

                // Floating Search Bar
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .shadow(elevation = 4.dp, shape = CoffeeShapes.large)
                        .background(Color.White, CoffeeShapes.large)
                        .border(1.dp, CoffeeBorder, CoffeeShapes.large)
                        .padding(horizontal = CoffeeSpacing.md),
                    contentAlignment = Alignment.CenterStart
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                    ) {
                        Icon(
                            imageVector = CoffeeIcons.search,
                            contentDescription = "Search icon",
                            tint = CoffeeMuted,
                            modifier = Modifier.size(22.dp)
                        )

                        BasicTextField(
                            value = searchQuery,
                            onValueChange = { searchQuery = it },
                            textStyle = MaterialTheme.typography.bodyMedium.copy(
                                color = CoffeeInk,
                                fontWeight = FontWeight.Medium
                            ),
                            modifier = Modifier.weight(1f),
                            decorationBox = { innerTextField ->
                                if (searchQuery.isEmpty()) {
                                    Text(
                                        text = "Search moments, vibes, or people...",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = CoffeeMuted.copy(alpha = 0.6f)
                                    )
                                }
                                innerTextField()
                            }
                        )

                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CoffeeShapes.small)
                                .background(CoffeeBackground)
                                .clickable {
                                    searchQuery = ""
                                    activeFilter = "all"
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.filter,
                                contentDescription = "Clear filters",
                                tint = CoffeeInk,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }

                // Filter Chips Horizontal List
                val filterOptions = listOf(
                    "all" to "All",
                    "coffee" to "Coffee",
                    "walks" to "Walks",
                    "study" to "Study",
                    "food" to "Food",
                    "gaming" to "Gaming",
                    "creative" to "Creative"
                )

                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    items(filterOptions) { (id, label) ->
                        val isActive = activeFilter == id
                        val containerColor = if (isActive) CoffeePrimary else Color.White
                        val contentColor = if (isActive) Color.White else CoffeeInk
                        val borderModifier = if (isActive) Modifier else Modifier.border(1.dp, CoffeeBorder, CircleShape)
                        val shadowModifier = if (isActive) Modifier.shadow(8.dp, CircleShape, ambientColor = CoffeePrimary.copy(alpha = 0.2f), spotColor = CoffeePrimary.copy(alpha = 0.2f)) else Modifier

                        Row(
                            modifier = Modifier
                                .then(shadowModifier)
                                .clip(CircleShape)
                                .background(containerColor)
                                .then(borderModifier)
                                .clickable { activeFilter = id }
                                .padding(horizontal = CoffeeSpacing.lg, vertical = 10.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.category(id),
                                contentDescription = label,
                                tint = contentColor,
                                modifier = Modifier.size(16.dp)
                            )
                            Text(
                                text = label,
                                style = MaterialTheme.typography.labelMedium,
                                fontWeight = FontWeight.Bold,
                                color = contentColor
                            )
                        }
                    }
                }

                // Radar header & radar view toggler
                RadarHeader(
                    isRadarVisible = uiState.isRadarVisible,
                    isRefreshing = uiState.isRefreshing,
                    onToggleRadar = viewModel::toggleRadarVisibility,
                    onRefresh = { viewModel.refresh(forceLocationWrite = true) }
                )

                when (uiState.locationState) {
                    LocationState.Denied -> PermissionCard {
                        permissionLauncher.launch(
                            arrayOf(
                                Manifest.permission.ACCESS_FINE_LOCATION,
                                Manifest.permission.ACCESS_COARSE_LOCATION
                            )
                        )
                    }
                    LocationState.Unavailable -> MessageCard(
                        title = "Location unavailable",
                        body = "We could not resolve your area. Try again.",
                        actionLabel = "Try again",
                        onAction = { viewModel.refresh(forceLocationWrite = true) }
                    )
                    LocationState.Loading -> LoadingRadar()
                    is LocationState.Available -> AroundRadar(uiState.radarPeople)
                }

                val errorMsg = uiState.errorMessage
                if (errorMsg != null) {
                    MessageCard(
                        title = "Discovery paused",
                        body = errorMsg,
                        actionLabel = "Refresh",
                        onAction = { viewModel.refresh(forceLocationWrite = true) },
                        isError = true
                    )
                }

                // Header for Nearby Drifts list
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(top = CoffeeSpacing.sm)
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Nearby Drifts",
                            style = MaterialTheme.typography.titleLarge,
                            color = CoffeeInk,
                            fontWeight = FontWeight.Black
                        )
                        Text(
                            text = "Within 10 km, refreshed on demand",
                            style = MaterialTheme.typography.bodyMedium,
                            color = CoffeeMuted
                        )
                    }
                    CoffeePillBadge(
                        title = "${filteredDrifts.size}",
                        containerColor = CoffeePrimary.copy(alpha = 0.12f),
                        contentColor = CoffeePrimaryDark
                    )
                }

                // Drifts Feed
                if (uiState.isRefreshing && filteredDrifts.isEmpty()) {
                    CoffeeEmptyState(
                        title = "Finding nearby plans",
                        subtitle = "Discovery is checking your area for open Drifts.",
                        symbol = "..."
                    )
                } else if (filteredDrifts.isEmpty()) {
                    CoffeeEmptyState(
                        title = "No meetups found",
                        subtitle = "Try adjusting your filters or search to find different social vibes.",
                        symbol = "✨",
                        actionLabel = "Clear Filters",
                        onAction = {
                            activeFilter = "all"
                            searchQuery = ""
                        }
                    )
                } else {
                for (drift in filteredDrifts) {
                    CoffeeDriftCard(
                        title = drift.title.ifBlank { drift.hook.ifBlank { "Open Drift" } },
                        hostName = drift.creatorName,
                        category = drift.category.firestoreValue,
                        distanceText = "${String.format("%.1f", drift.distance)} km",
                        timeText = drift.time,
                        imageUrl = drift.imageUrl,
                        hostImageUrl = drift.creatorImageUrl,
                        statusLabel = drift.status.firestoreValue,
                        vibe = drift.vibeTags.firstOrNull(),
                        peopleGoing = drift.participantCount,
                        isFeatured = drift.participantCount > 2,
                        actionLabel = "Join Moment",
                        onJoin = {
                            selectedDrift = drift
                            showAcceptModal = true
                        },
                        onClick = { onDriftClick(drift.id) }
                    )
                }
                }
            }
        }

        // Floating Slate Dark Plus FAB
        if (!isMapView) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .navigationBarsPadding()
                    .padding(end = CoffeeSpacing.screen, bottom = 100.dp)
                    .size(64.dp)
                    .shadow(16.dp, CoffeeShapes.xlarge, ambientColor = CoffeeInk.copy(alpha = 0.3f), spotColor = CoffeeInk.copy(alpha = 0.3f))
                    .clip(CoffeeShapes.xlarge)
                    .background(CoffeeInk)
                    .border(4.dp, Color.White, CoffeeShapes.xlarge)
                    .clickable { onNavigateToCreate() },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.create,
                    contentDescription = "Create",
                    tint = Color.White,
                    modifier = Modifier.size(32.dp)
                )
            }
        }

        // Join / Accept Confirmation Dialog Modal
        if (showAcceptModal && selectedDrift != null) {
            androidx.compose.ui.window.Dialog(onDismissRequest = { showAcceptModal = false }) {
                Surface(
                    shape = CoffeeShapes.hero,
                    color = Color.White,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = CoffeeSpacing.xs)
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
                    ) {
                        Box(contentAlignment = Alignment.BottomEnd) {
                            CoffeeAvatar(
                                name = selectedDrift!!.creatorName,
                                imageUrl = selectedDrift!!.creatorImageUrl,
                                size = 80.dp,
                                ringColor = CoffeeBackground
                            )
                            Box(
                                modifier = Modifier
                                    .size(28.dp)
                                    .clip(CircleShape)
                                    .background(CoffeePrimary)
                                    .border(2.dp, Color.White, CircleShape),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = CoffeeIcons.category(selectedDrift!!.category.firestoreValue),
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(14.dp)
                                )
                            }
                        }

                        Text(
                            text = "Join ${selectedDrift!!.creatorName}?",
                            style = MaterialTheme.typography.headlineSmall,
                            fontWeight = FontWeight.Black,
                            color = CoffeeInk
                        )

                        Text(
                            text = selectedDrift!!.title.ifBlank { selectedDrift!!.hook },
                            style = MaterialTheme.typography.bodyMedium,
                            color = CoffeeMuted,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )

                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(CoffeeShapes.medium)
                                .background(CoffeeBackground)
                                .border(1.dp, CoffeeBorder, CoffeeShapes.medium)
                                .padding(CoffeeSpacing.md),
                            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                            ) {
                                Icon(
                                    imageVector = CoffeeIcons.clock,
                                    contentDescription = null,
                                    tint = CoffeePurple,
                                    modifier = Modifier.size(16.dp)
                                )
                                Text(
                                    text = selectedDrift!!.time,
                                    style = MaterialTheme.typography.labelMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = CoffeeInk
                                )
                            }
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                            ) {
                                Icon(
                                    imageVector = CoffeeIcons.location,
                                    contentDescription = null,
                                    tint = CoffeePrimary,
                                    modifier = Modifier.size(16.dp)
                                )
                                Text(
                                    text = selectedDrift!!.location,
                                    style = MaterialTheme.typography.labelMedium,
                                    color = CoffeeMuted
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(CoffeeSpacing.xs))

                        CoffeeButton(
                            title = "Send Request",
                            onClick = {
                                showAcceptModal = false
                                showMatchModal = true
                            },
                            variant = CoffeeButtonVariant.Primary
                        )

                        Text(
                            text = "Maybe later",
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.Bold,
                            color = CoffeeMuted,
                            modifier = Modifier
                                .clickable { showAcceptModal = false }
                                .padding(vertical = CoffeeSpacing.xs)
                        )
                    }
                }
            }
        }

        // Match Confirmed Dialog Modal
        if (showMatchModal && selectedDrift != null) {
            androidx.compose.ui.window.Dialog(onDismissRequest = { showMatchModal = false }) {
                Surface(
                    shape = CoffeeShapes.hero,
                    color = CoffeePrimary,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = CoffeeSpacing.xs)
                ) {
                    Column(
                        modifier = Modifier.padding(28.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(20.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(88.dp)
                                .shadow(8.dp, CoffeeShapes.xlarge)
                                .background(Color.White, CoffeeShapes.xlarge),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("🤝", style = MaterialTheme.typography.headlineLarge)
                        }

                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                        ) {
                            Text(
                                text = "It's a Match!",
                                style = MaterialTheme.typography.headlineMedium,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            Text(
                                text = "You and ${selectedDrift!!.creatorName} are hanging out!",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Bold,
                                color = Color.White.copy(alpha = 0.9f),
                                textAlign = androidx.compose.ui.text.style.TextAlign.Center
                            )
                        }

                        Row(
                            horizontalArrangement = Arrangement.spacedBy((-16).dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            CoffeeAvatar(
                                name = uiState.currentUserName.ifBlank { "You" },
                                imageUrl = uiState.currentUserPhotoUrl,
                                size = 64.dp,
                                ringColor = CoffeePrimary
                            )
                            CoffeeAvatar(
                                name = selectedDrift!!.creatorName,
                                imageUrl = selectedDrift!!.creatorImageUrl,
                                size = 64.dp,
                                ringColor = CoffeePrimary
                            )
                        }

                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(CoffeeShapes.medium)
                                .background(Color.Black.copy(alpha = 0.12f))
                                .border(1.dp, Color.White.copy(alpha = 0.2f), CoffeeShapes.medium)
                                .padding(CoffeeSpacing.md),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(
                                text = "MOMENT",
                                style = MaterialTheme.typography.labelSmall,
                                fontWeight = FontWeight.Black,
                                color = Color.White.copy(alpha = 0.7f)
                            )
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                modifier = Modifier.padding(top = 4.dp)
                            ) {
                                Icon(
                                    imageVector = CoffeeIcons.category(selectedDrift!!.category.firestoreValue),
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(20.dp)
                                )
                                Text(
                                    text = selectedDrift!!.category.firestoreValue.replaceFirstChar { it.uppercase() },
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.White
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(CoffeeSpacing.xs))

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .heightIn(min = 48.dp)
                                .shadow(elevation = 12.dp, shape = CoffeeShapes.medium)
                                .clip(CoffeeShapes.medium)
                                .background(Color.White)
                                .clickable {
                                    showMatchModal = false
                                    onDriftClick(selectedDrift!!.id)
                                }
                                .padding(horizontal = CoffeeSpacing.lg, vertical = CoffeeSpacing.sm),
                            horizontalArrangement = Arrangement.Center,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Say Hello",
                                style = MaterialTheme.typography.labelLarge,
                                color = CoffeePrimary,
                                fontWeight = FontWeight.Bold
                            )
                        }

                        Text(
                            text = "Keep Discovering",
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.Bold,
                            color = Color.White.copy(alpha = 0.8f),
                            modifier = Modifier
                                .clickable { showMatchModal = false }
                                .padding(vertical = CoffeeSpacing.xs)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun RadarHeader(
    isRadarVisible: Boolean,
    isRefreshing: Boolean,
    onToggleRadar: () -> Unit,
    onRefresh: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Around Radar",
                style = MaterialTheme.typography.titleMedium,
                color = CoffeeInk,
                fontWeight = FontWeight.Black
            )
            Text(
                text = if (isRadarVisible) "Anonymous signals from people nearby" else "Radar presence is offline",
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted
            )
        }
        Surface(
            onClick = onToggleRadar,
            shape = CircleShape,
            color = if (isRadarVisible) CoffeePrimary.copy(alpha = 0.14f) else CoffeeSurfaceSecondary
        ) {
            Text(
                text = if (isRadarVisible) "ON" else "OFF",
                style = MaterialTheme.typography.labelMedium,
                color = if (isRadarVisible) CoffeePrimaryDark else CoffeeMuted,
                modifier = Modifier.padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs)
            )
        }
        Spacer(modifier = Modifier.width(CoffeeSpacing.sm))
        Surface(
            onClick = onRefresh,
            shape = CircleShape,
            color = CoffeeSurface,
            shadowElevation = 4.dp
        ) {
            Text(
                text = if (isRefreshing) "..." else "Refresh",
                style = MaterialTheme.typography.titleMedium,
                color = CoffeePrimary,
                modifier = Modifier.padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs)
            )
        }
    }
}

@Composable
private fun PermissionCard(onRequestPermission: () -> Unit) {
    MessageCard(
        title = "Location keeps Discovery local",
        body = "CoffeeCall needs approximate location to show Drifts and anonymous Around signals within 10 km.",
        actionLabel = "Allow location",
        onAction = onRequestPermission
    )
}

@Composable
private fun LoadingRadar() {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(280.dp),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        shadowElevation = 8.dp
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            CircularProgressIndicator(color = CoffeePrimary)
            Spacer(modifier = Modifier.height(CoffeeSpacing.md))
            Text(
                text = "Resolving your area",
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted
            )
        }
    }
}

@Composable
private fun AroundRadar(people: List<RadarPerson>) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(320.dp),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        shadowElevation = 8.dp
    ) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val center = Offset(size.width / 2, size.height / 2)
                val maxRadius = minOf(size.width, size.height) * 0.42f
                listOf(0.33f, 0.66f, 1f).forEach { scale ->
                    drawCircle(
                        color = Color(0xFF53B8A6).copy(alpha = 0.15f),
                        radius = maxRadius * scale,
                        center = center,
                        style = Stroke(width = 2.dp.toPx())
                    )
                }
                drawCircle(
                    color = Color(0xFF53B8A6).copy(alpha = 0.10f),
                    radius = 16.dp.toPx(),
                    center = center
                )
            }

            Box(
                modifier = Modifier
                    .size(46.dp)
                    .clip(CircleShape)
                    .background(CoffeePrimary),
                contentAlignment = Alignment.Center
            ) {
                Text("YOU", style = MaterialTheme.typography.labelSmall, color = CoffeeTextOnBrand)
            }

            for (person in people.take(8)) {
                RadarDot(person)
            }

            if (people.isEmpty()) {
                Text(
                    text = "No anonymous radar signals nearby",
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeMuted,
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(bottom = CoffeeSpacing.lg)
                )
            }
        }
    }
}

@Composable
private fun RadarDot(person: RadarPerson) {
    val angleRadians = Math.toRadians(person.angleDegrees)
    val x = (cos(angleRadians) * person.normalizedDistance * 112).dp
    val y = (sin(angleRadians) * person.normalizedDistance * 112).dp
    Column(
        modifier = Modifier.offset(x = x, y = y),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(42.dp)
                .clip(CircleShape)
                .background(person.color.copy(alpha = 0.92f))
                .border(2.dp, CoffeeSurface, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = person.initials,
                style = MaterialTheme.typography.labelMedium,
                color = CoffeeTextOnBrand,
                maxLines = 1
            )
        }
        if (person.interests.isNotEmpty()) {
            Text(
                text = person.interests.take(2).joinToString(" / "),
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeMuted,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.width(92.dp)
            )
        }
    }
}

@Composable
private fun MessageCard(
    title: String,
    body: String,
    actionLabel: String,
    onAction: () -> Unit,
    isError: Boolean = false
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = if (isError) CoffeeError.copy(alpha = 0.08f) else CoffeeSurface,
        shadowElevation = 6.dp
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
                Text(text = title, style = MaterialTheme.typography.titleMedium, color = CoffeeInk)
                Text(text = body, style = MaterialTheme.typography.bodyMedium, color = CoffeeMuted)
            }
            Surface(onClick = onAction, shape = CircleShape, color = CoffeePrimary) {
                Text(
                    text = actionLabel,
                    style = MaterialTheme.typography.labelMedium,
                    color = CoffeeTextOnBrand,
                    modifier = Modifier.padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs)
                )
            }
        }
    }
}

class DiscoveryViewModel(
    application: Application,
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance(),
    private val locationProvider: AndroidLocationProvider = AndroidLocationProvider(application)
) : AndroidViewModel(application) {
    private val preferences = application.getSharedPreferences("CoffeeCall.discovery", Context.MODE_PRIVATE)
    private val _uiState = MutableStateFlow(DiscoveryUiState())
    val uiState: StateFlow<DiscoveryUiState> = _uiState.asStateFlow()

    fun refreshIfPermissionAlreadyGranted() {
        if (locationProvider.hasLocationPermission()) {
            refresh()
        } else {
            _uiState.update {
                it.copy(
                    permissionState = LocationPermissionState.Unknown,
                    locationState = LocationState.Denied
                )
            }
        }
    }

    fun onPermissionResult(granted: Boolean) {
        _uiState.update {
            it.copy(
                permissionState = if (granted) LocationPermissionState.Granted else LocationPermissionState.Denied,
                locationState = if (granted) LocationState.Loading else LocationState.Denied
            )
        }
        if (granted) refresh(forceLocationWrite = true)
    }

    fun refresh(forceLocationWrite: Boolean = false) {
        viewModelScope.launch {
            loadUserProfile()
            if (!locationProvider.hasLocationPermission()) {
                _uiState.update {
                    it.copy(
                        permissionState = LocationPermissionState.Denied,
                        locationState = LocationState.Denied,
                        isRefreshing = false
                    )
                }
                return@launch
            }

            _uiState.update {
                it.copy(
                    permissionState = LocationPermissionState.Granted,
                    locationState = LocationState.Loading,
                    isRefreshing = true,
                    errorMessage = null
                )
            }

            val location = locationProvider.currentLocation()
            if (location == null) {
                _uiState.update {
                    it.copy(locationState = LocationState.Unavailable, isRefreshing = false)
                }
                return@launch
            }

            runCatching {
                updateUserLocationIfNeeded(location, forceLocationWrite)
                val nearbyDeferred = async {
                    postRepository.fetchNearbyPosts(
                        latitude = location.latitude,
                        longitude = location.longitude
                    )
                }
                val radarDeferred = async {
                    userRepository.fetchRecentRadarProfiles().toRadarPeople(location, auth.currentUser?.uid)
                }
                val radarPeople = radarDeferred.await()
                _uiState.update {
                    it.copy(
                        locationState = LocationState.Available(location),
                        nearbyDrifts = nearbyDeferred.await(),
                        radarPeople = radarPeople,
                        interestCategories = radarPeople.toInterestCategories(),
                        isRefreshing = false,
                        errorMessage = null
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        locationState = LocationState.Available(location),
                        isRefreshing = false,
                        errorMessage = error.discoveryMessage()
                    )
                }
            }
        }
    }

    fun toggleRadarVisibility() {
        val nextValue = !_uiState.value.isRadarVisible
        preferences.edit().putBoolean(RADAR_VISIBLE_KEY, nextValue).apply()
        _uiState.update { it.copy(isRadarVisible = nextValue) }

        viewModelScope.launch {
            val uid = auth.currentUser?.uid ?: return@launch
            runCatching { userRepository.updateRadarVisibility(uid, nextValue) }
            if (nextValue) refresh(forceLocationWrite = true)
        }
    }

    private suspend fun updateUserLocationIfNeeded(location: CoffeeLocation, force: Boolean) {
        val uid = auth.currentUser?.uid ?: return
        if (!_uiState.value.isRadarVisible) {
            runCatching { userRepository.updateRadarVisibility(uid, false) }
            return
        }

        val lastWrite = preferences.getLong(LAST_LOCATION_WRITE_KEY, 0L)
        if (!force && System.currentTimeMillis() - lastWrite < LOCATION_WRITE_INTERVAL_MS) return

        userRepository.updateLastLocation(
            uid = uid,
            location = GeoLocation(location.latitude, location.longitude),
            geoHash = GeoHash.encode(location.latitude, location.longitude),
            isRadarVisible = true
        )
        preferences.edit().putLong(LAST_LOCATION_WRITE_KEY, System.currentTimeMillis()).apply()
    }

    private fun Throwable.discoveryMessage(): String =
        if (this is FirebaseUnavailableException) {
            "Firebase is not configured for this Android build yet, so live nearby Drifts cannot load."
        } else {
            localizedMessage ?: "Something went wrong while refreshing Discovery."
        }

    companion object {
        private const val RADAR_VISIBLE_KEY = "CoffeeCall.isRadarVisible"
        private const val LAST_LOCATION_WRITE_KEY = "CoffeeCall.lastLocationRefreshAt"
        private const val LOCATION_WRITE_INTERVAL_MS = 60 * 60 * 1000L

        fun factory(application: Application): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    DiscoveryViewModel(application) as T
            }
    }

    private fun loadUserProfile() {
        viewModelScope.launch {
            val uid = auth.currentUser?.uid ?: return@launch
            runCatching {
                userRepository.getUser(uid)
            }.onSuccess { profile ->
                if (profile != null) {
                    _uiState.update {
                        it.copy(
                            currentUserName = profile.name,
                            currentUserPhotoUrl = profile.profilePhotoUrl
                        )
                    }
                }
            }
        }
    }

    init {
        _uiState.update {
            it.copy(isRadarVisible = preferences.getBoolean(RADAR_VISIBLE_KEY, true))
        }
        loadUserProfile()
    }
}

private fun List<UserProfile>.toRadarPeople(location: CoffeeLocation, currentUid: String?): List<RadarPerson> =
    mapNotNull { profile ->
        if (profile.uid == currentUid || !profile.isRadarVisible) return@mapNotNull null
        val otherLocation = profile.lastLocation ?: return@mapNotNull null
        val distanceKm = haversineDistanceKm(
            location.latitude,
            location.longitude,
            otherLocation.latitude,
            otherLocation.longitude
        )
        if (distanceKm > DISCOVERY_RADIUS_KM) return@mapNotNull null

        val fallback = stableRadarPosition(profile.uid)
        RadarPerson(
            id = profile.uid,
            initials = profile.safeInitials(),
            normalizedDistance = 0.2 + (distanceKm / DISCOVERY_RADIUS_KM) * 0.75,
            angleDegrees = fallback.angleDegrees,
            interests = profile.interestTags.ifEmpty { profile.interests }.take(2),
            color = colorForInterests(profile.interestTags.ifEmpty { profile.interests })
        )
    }

private fun List<RadarPerson>.toInterestCategories(): List<InterestCategory> {
    val counts = flatMap { it.interests }.groupingBy { it }.eachCount()
    return listOf("Coffee", "Walks", "Movies", "Food", "Music", "Gaming", "Books", "Workout")
        .mapNotNull { interest ->
            val count = counts[interest] ?: 0
            if (count == 0) null else InterestCategory(interest, interest, count, colorForInterests(listOf(interest)))
        }
}

private fun UserProfile.safeInitials(): String =
    initials.ifBlank {
        name.split(" ")
            .mapNotNull { it.firstOrNull()?.uppercaseChar()?.toString() }
            .joinToString("")
    }.ifBlank { "?" }.take(2)

private fun stableRadarPosition(id: String): RadarPosition {
    var hash = 2_166_136_261u
    id.forEach { char ->
        hash = (hash xor char.code.toUInt()) * 16_777_619u
    }
    return RadarPosition(angleDegrees = ((hash / 75u) % 360u).toDouble())
}

private fun colorForInterests(interests: List<String>): Color =
    when {
        interests.any { it.equals("Coffee", true) || it.equals("Books", true) } -> CoffeePrimary
        interests.any { it.equals("Food", true) || it.equals("Gaming", true) } -> CoffeePeach
        else -> CoffeePurple
    }

private fun categoryColor(category: DriftCategory): Color =
    when (category) {
        DriftCategory.Coffee, DriftCategory.Study, DriftCategory.Yoga -> CoffeePrimary
        DriftCategory.Food, DriftCategory.Gaming, DriftCategory.Event -> CoffeePeach
        DriftCategory.Walk, DriftCategory.Movie, DriftCategory.Music -> CoffeePurple
    }

private fun categoryLabel(category: DriftCategory): String =
    category.firestoreValue.replaceFirstChar { it.uppercase() }

@Preview(showBackground = true, widthDp = 360, heightDp = 900)
@Composable
private fun DiscoveryContentPreview() {
    CoffeeCallTheme {
        Box(modifier = Modifier.fillMaxSize()) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .background(CoffeeBackground)
                    .padding(horizontal = CoffeeSpacing.screen)
                    .padding(top = CoffeeSpacing.md, bottom = CoffeeSpacing.screenBottomSpacer),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
            ) {
                // Mock layout content
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Hey Robin",
                            style = MaterialTheme.typography.headlineLarge,
                            color = CoffeeInk,
                            fontWeight = FontWeight.Black
                        )
                        Text(
                            text = "1 meetup happening nearby",
                            style = MaterialTheme.typography.bodyMedium,
                            color = CoffeeMuted
                        )
                    }
                }
            }
        }
    }
}


data class DiscoveryUiState(
    val permissionState: LocationPermissionState = LocationPermissionState.Unknown,
    val locationState: LocationState = LocationState.Loading,
    val isRadarVisible: Boolean = true,
    val isRefreshing: Boolean = false,
    val nearbyDrifts: List<DriftPost> = emptyList(),
    val radarPeople: List<RadarPerson> = emptyList(),
    val interestCategories: List<InterestCategory> = emptyList(),
    val errorMessage: String? = null,
    val currentUserName: String = "",
    val currentUserPhotoUrl: String = ""
)

data class RadarPerson(
    val id: String,
    val initials: String,
    val normalizedDistance: Double,
    val angleDegrees: Double,
    val interests: List<String>,
    val color: Color
)

data class InterestCategory(
    val id: String,
    val label: String,
    val count: Int,
    val color: Color
)

private data class RadarPosition(
    val angleDegrees: Double
)

private const val DISCOVERY_RADIUS_KM = 10.0


package com.coffeecall.app.feature.discovery

import android.Manifest
import android.app.Application
import android.content.Context
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectVerticalDragGestures
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
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.draw.blur
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.CoffeeAvatar
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeCallTheme
import com.coffeecall.app.core.design.CoffeeError
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePeach
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
import com.coffeecall.app.core.state.GlobalDriftStore
import com.coffeecall.app.data.repository.RepositoryProvider
import com.coffeecall.app.domain.model.GeoLocation
import com.coffeecall.app.domain.model.UserProfile
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
import kotlin.math.absoluteValue
import kotlin.math.roundToInt
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.foundation.layout.widthIn
import androidx.compose.ui.zIndex
import androidx.compose.ui.graphics.Brush

@Composable
fun DiscoveryScreen(
    onDriftClick: (String) -> Unit = {},
    onNavigateToDrifts: () -> Unit = {},
    onInterestSelected: (String) -> Unit = {}
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

    var showNotificationsSheet by remember { mutableStateOf(false) }

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        val screenHeight = maxHeight
        val density = LocalDensity.current

        val collapsedOffset = screenHeight * 0.7f
        val expandedOffset = 100.dp

        val collapsedPx = with(density) { collapsedOffset.toPx() }
        val expandedPx = with(density) { expandedOffset.toPx() }

        val animatableOffset = remember { Animatable(collapsedPx) }
        val coroutineScope = rememberCoroutineScope()

        LaunchedEffect(screenHeight) {
            animatableOffset.snapTo(collapsedPx)
        }

        val totalPx = collapsedPx - expandedPx
        val movedPx = collapsedPx - animatableOffset.value
        val progress = if (totalPx > 0f) (movedPx / totalPx).coerceIn(0f, 1f) else 0f

        val radarScale = 1.0f - (progress * 0.08f)
        val radarOpacity = 1.0f - (progress * 0.65f)
        val radarBlur = (progress * 8f).dp

        // 1. Radar Layer in the background
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = 112.dp)
                .graphicsLayer {
                    scaleX = radarScale
                    scaleY = radarScale
                    alpha = radarOpacity
                }
                .blur(radarBlur),
            contentAlignment = Alignment.TopCenter
        ) {
            Box(modifier = Modifier.padding(top = screenHeight * 0.15f)) {
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
                        body = "We could not resolve your current area. Try again.",
                        actionLabel = "Try again",
                        onAction = { viewModel.refreshNearby() }
                    )
                    LocationState.Loading -> LoadingRadar()
                    is LocationState.Available -> AroundRadar(
                        people = uiState.radarPeople,
                        isScanning = uiState.isScanning
                    )
                }
            }
        }

        // 2. Fixed Header Section overlay at the top
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(horizontal = CoffeeSpacing.screen, vertical = CoffeeSpacing.sm),
            shape = CoffeeShapes.xlarge,
            color = CoffeeSurface,
            shadowElevation = 12.dp
        ) {
            Row(
                modifier = Modifier.padding(horizontal = CoffeeSpacing.xl, vertical = CoffeeSpacing.lg),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Around",
                        style = MaterialTheme.typography.headlineLarge,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        text = "People nearby are open to plans",
                        style = MaterialTheme.typography.bodyMedium,
                        color = CoffeeMuted,
                        fontWeight = FontWeight.Medium
                    )
                }

                Row(
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Presence Toggle Button
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(CircleShape)
                            .background(CoffeeBackground)
                            .border(1.dp, CoffeeBorder.copy(alpha = 0.5f), CircleShape)
                            .clickable { viewModel.toggleRadarVisibility() },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = CoffeeIcons.antenna,
                            contentDescription = "Toggle Presence",
                            tint = if (uiState.isRadarVisible) CoffeePrimary else CoffeeMuted,
                            modifier = Modifier.size(24.dp)
                        )
                    }

                    // Notifications Bell Button
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(CircleShape)
                            .background(CoffeeBackground)
                            .border(1.dp, CoffeeBorder.copy(alpha = 0.5f), CircleShape)
                            .clickable { showNotificationsSheet = true },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = CoffeeIcons.bell,
                            contentDescription = "Notifications",
                            tint = CoffeeInk,
                            modifier = Modifier.size(24.dp)
                        )
                        if (uiState.notifications.isNotEmpty()) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.TopEnd)
                                    .padding(top = CoffeeSpacing.md, end = CoffeeSpacing.md)
                                    .size(10.dp)
                                    .clip(CircleShape)
                                    .background(CoffeePrimary)
                                    .border(1.5.dp, Color.White, CircleShape)
                            )
                        }
                    }
                }
            }
        }

        // 3. Draggable Bottom Sheet Layer
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight()
                .offset { IntOffset(0, animatableOffset.value.roundToInt()) }
                .background(
                    color = Color.White,
                    shape = RoundedCornerShape(topStart = 48.dp, topEnd = 48.dp)
                )
                .border(
                    width = 1.dp,
                    color = CoffeeBorder.copy(alpha = 0.5f),
                    shape = RoundedCornerShape(topStart = 48.dp, topEnd = 48.dp)
                )
        ) {
            // Drag Handle Area
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .pointerInput(Unit) {
                        detectVerticalDragGestures(
                            onDragEnd = {
                                val target = if (animatableOffset.value < (collapsedPx + expandedPx) / 2) {
                                    expandedPx
                                } else {
                                    collapsedPx
                                }
                                coroutineScope.launch {
                                    animatableOffset.animateTo(
                                        targetValue = target,
                                        animationSpec = spring(
                                            dampingRatio = Spring.DampingRatioMediumBouncy,
                                            stiffness = Spring.StiffnessLow
                                        )
                                    )
                                }
                            },
                            onDragCancel = {
                                val target = if (animatableOffset.value < (collapsedPx + expandedPx) / 2) {
                                    expandedPx
                                } else {
                                    collapsedPx
                                }
                                coroutineScope.launch {
                                    animatableOffset.animateTo(
                                        targetValue = target,
                                        animationSpec = spring(
                                            dampingRatio = Spring.DampingRatioMediumBouncy,
                                            stiffness = Spring.StiffnessLow
                                        )
                                    )
                                }
                            },
                            onVerticalDrag = { change, dragAmount ->
                                change.consume()
                                coroutineScope.launch {
                                    animatableOffset.snapTo(
                                        (animatableOffset.value + dragAmount).coerceIn(expandedPx, collapsedPx)
                                    )
                                }
                            }
                        )
                    }
                    .padding(top = CoffeeSpacing.md, bottom = CoffeeSpacing.xs),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(width = 50.dp, height = 5.dp)
                        .clip(CircleShape)
                        .background(CoffeeMuted.copy(alpha = 0.2f))
                )
            }

            // Scrollable Content
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = CoffeeSpacing.xl)
                    .padding(bottom = 120.dp)
            ) {
                // Nearby Drifts Pill
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = CoffeeSpacing.xs),
                    shape = RoundedCornerShape(24.dp),
                    color = CoffeeBackground.copy(alpha = 0.4f),
                    border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f))
                ) {
                    Row(
                        modifier = Modifier
                            .clickable { onNavigateToDrifts() }
                            .padding(CoffeeSpacing.md),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .clip(CircleShape)
                                .background(CoffeePrimary.copy(alpha = 0.15f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.people,
                                contentDescription = null,
                                tint = CoffeePrimary,
                                modifier = Modifier.size(24.dp)
                            )
                        }

                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "Nearby Drifts are forming",
                                style = MaterialTheme.typography.bodyLarge,
                                fontWeight = FontWeight.Black,
                                color = CoffeeInk
                            )
                            Text(
                                text = "Join one or create your own.",
                                style = MaterialTheme.typography.bodySmall,
                                color = CoffeeMuted
                            )
                        }

                        Icon(
                            imageVector = CoffeeIcons.chevronRight,
                            contentDescription = null,
                            tint = CoffeeMuted.copy(alpha = 0.5f),
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(32.dp))

                // Your interests nearby Header
                Text(
                    text = "Your interests nearby",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Black,
                    color = CoffeeInk
                )

                Spacer(modifier = Modifier.height(CoffeeSpacing.lg))

                // 4-column Interests Grid
                val categories = uiState.interestCategories
                val columns = 4
                val rows = (categories.size + columns - 1) / columns
                Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)) {
                    for (r in 0 until rows) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
                        ) {
                            for (c in 0 until columns) {
                                val index = r * columns + c
                                if (index < categories.size) {
                                    val category = categories[index]
                                    Box(modifier = Modifier.weight(1f)) {
                                        InterestCard(
                                            category = category,
                                            onClick = {
                                                onInterestSelected(category.id)
                                            }
                                        )
                                    }
                                } else {
                                    Spacer(modifier = Modifier.weight(1f))
                                }
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(40.dp))
            }
        }


        // 4. Floating Refresh Button
        val refreshButtonOpacity by animateFloatAsState(
            targetValue = if (progress < 0.55f) 1f else 0f,
            animationSpec = tween(durationMillis = 200),
            label = "RefreshButtonOpacity"
        )

        val refreshRotation = remember { Animatable(0f) }
        LaunchedEffect(uiState.isScanning) {
            if (uiState.isScanning) {
                refreshRotation.animateTo(
                    targetValue = 360f,
                    animationSpec = infiniteRepeatable(
                        animation = tween(durationMillis = 1000, easing = LinearEasing),
                        repeatMode = RepeatMode.Restart
                    )
                )
            } else {
                refreshRotation.snapTo(0f)
            }
        }

        if (refreshButtonOpacity > 0f) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = CoffeeSpacing.screen, bottom = 120.dp)
                    .graphicsLayer {
                        alpha = refreshButtonOpacity
                    }
                    .zIndex(20f)
                    .size(58.dp)
                    .shadow(elevation = 6.dp, shape = CircleShape)
                    .clip(CircleShape)
                    .background(Color.White.copy(alpha = 0.9f))
                    .border(BorderStroke(1.dp, Color.White.copy(alpha = 0.6f)), CircleShape)
                    .clickable(enabled = !uiState.isScanning) {
                        viewModel.refreshNearby()
                    },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.refresh,
                    contentDescription = "Refresh Nearby",
                    tint = CoffeePrimary,
                    modifier = Modifier
                        .size(24.dp)
                        .graphicsLayer {
                            rotationZ = refreshRotation.value
                        }
                )
            }
        }

        if (showNotificationsSheet) {
            NotificationsSheet(
                notifications = uiState.notifications,
                onDismiss = { showNotificationsSheet = false },
                onNotificationClick = { notification ->
                    showNotificationsSheet = false
                    onDriftClick(notification.driftId)
                }
            )
        }
    }
}

@Composable
private fun InterestCard(
    category: InterestCategory,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .height(112.dp),
        shape = RoundedCornerShape(22.dp),
        color = Color.White,
        border = BorderStroke(0.5.dp, CoffeeBorder.copy(alpha = 0.3f)),
        shadowElevation = 1.dp
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 10.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(category.color.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.category(category.label),
                    contentDescription = null,
                    tint = category.color,
                    modifier = Modifier.size(22.dp)
                )
            }

            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(1.dp)
            ) {
                Text(
                    text = category.label,
                    style = MaterialTheme.typography.labelMedium.copy(fontSize = 11.sp),
                    fontWeight = FontWeight.Bold,
                    color = CoffeeInk,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "${category.count} nearby",
                    style = MaterialTheme.typography.labelSmall.copy(fontSize = 9.sp),
                    fontWeight = FontWeight.Bold,
                    color = CoffeeMuted.copy(alpha = 0.7f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
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


private data class RadarParticle(
    val x: Float,
    val y: Float,
    val size: Float,
    val color: Color
)

private fun getInterestEmoji(interest: String): androidx.compose.ui.graphics.vector.ImageVector = when (interest.lowercase().trim()) {
    "walks", "walk" -> CoffeeIcons.category("walk")
    "coffee" -> CoffeeIcons.category("coffee")
    "movies", "movie" -> CoffeeIcons.category("movie")
    else -> CoffeeIcons.bolt
}

@Composable
private fun AroundRadar(
    people: List<RadarPerson>,
    isScanning: Boolean
) {
    var selectedPerson by remember { mutableStateOf<RadarPerson?>(null) }

    // Sweep Angle Animatable for energy-efficient timed scanning animation
    val sweepAngle = remember { Animatable(0f) }
    LaunchedEffect(isScanning) {
        if (isScanning) {
            sweepAngle.animateTo(
                targetValue = 360f,
                animationSpec = infiniteRepeatable(
                    animation = tween(durationMillis = 4000, easing = LinearEasing),
                    repeatMode = RepeatMode.Restart
                )
            )
        } else {
            sweepAngle.snapTo(0f)
        }
    }

    // Twinkle transition
    val infiniteTransition = rememberInfiniteTransition(label = "RadarTwinkle")
    val twinklePhase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = (2 * Math.PI).toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 8000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "Twinkle"
    )

    // Background atmospheric particles
    val particles = remember {
        List(12) {
            RadarParticle(
                x = (Math.random() * 320 - 160).toFloat(),
                y = (Math.random() * 320 - 160).toFloat(),
                size = (Math.random() * 4 + 4).toFloat(),
                color = if (Math.random() > 0.5) CoffeePrimary else CoffeePurple
            )
        }
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(360.dp),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2, size.height / 2)
            val maxRadius = minOf(size.width, size.height) * 0.42f

            // Draw particles
            particles.forEachIndexed { index, particle ->
                val twinkleVal = kotlin.math.sin(twinklePhase + index).absoluteValue
                val alpha = (0.1f + 0.2f * twinkleVal).coerceIn(0f, 1f)
                drawCircle(
                    color = particle.color.copy(alpha = alpha),
                    radius = particle.size.dp.toPx(),
                    center = Offset(center.x + particle.x.dp.toPx(), center.y + particle.y.dp.toPx())
                )
            }

            // Draw Dashed Concentric rings
            listOf(0.33f, 0.66f, 1f).forEach { scale ->
                drawCircle(
                    color = CoffeeBorder.copy(alpha = 0.5f),
                    radius = maxRadius * scale,
                    center = center,
                    style = Stroke(
                        width = 1.dp.toPx(),
                        pathEffect = PathEffect.dashPathEffect(floatArrayOf(4f, 8f), 0f)
                    )
                )
            }

            // Draw scanning sweep
            if (isScanning) {
                val sweepBrush = Brush.sweepGradient(
                    colors = listOf(
                        CoffeePrimary.copy(alpha = 0.25f),
                        CoffeePrimary.copy(alpha = 0.05f),
                        Color.Transparent,
                        Color.Transparent
                    ),
                    center = center
                )
                rotate(sweepAngle.value, pivot = center) {
                    drawCircle(
                        brush = sweepBrush,
                        radius = maxRadius,
                        center = center
                    )
                }
            }

            // Draw central YOU shadow ring
            drawCircle(
                color = CoffeePrimary.copy(alpha = 0.10f),
                radius = 24.dp.toPx(),
                center = center
            )
        }

        // Center "You" bubble
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .shadow(8.dp, CircleShape)
                    .clip(CircleShape)
                    .background(CoffeePrimary),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.profile,
                    contentDescription = "You",
                    tint = Color.White,
                    modifier = Modifier.size(28.dp)
                )
            }
            Text(
                text = "You",
                style = MaterialTheme.typography.labelMedium,
                color = CoffeeMuted,
                fontWeight = FontWeight.Bold
            )
        }

        // Radar People Dots
        for (person in people.take(8)) {
            val angleRadians = Math.toRadians(person.angleDegrees)
            val dotX = (cos(angleRadians) * person.normalizedDistance * 112).dp
            val dotY = (sin(angleRadians) * person.normalizedDistance * 112).dp

            Box(
                modifier = Modifier
                    .offset(x = dotX, y = dotY)
                    .zIndex(if (selectedPerson?.id == person.id) 50f else 10f)
            ) {
                RadarDot(
                    person = person,
                    isSelected = selectedPerson?.id == person.id,
                    onClick = {
                        selectedPerson = if (selectedPerson?.id == person.id) null else person
                    }
                )
            }
        }

        // Activity Tooltip overlay
        selectedPerson?.let { person ->
            val angleRadians = Math.toRadians(person.angleDegrees)
            val dotX = (cos(angleRadians) * person.normalizedDistance * 112).dp
            val dotY = (sin(angleRadians) * person.normalizedDistance * 112).dp

            val isBelow = dotY.value < -30
            val tooltipY = if (isBelow) dotY + 54.dp else dotY - 54.dp

            Box(
                modifier = Modifier
                    .offset(x = dotX, y = tooltipY)
                    .shadow(8.dp, RoundedCornerShape(12.dp))
                    .background(Color.White, RoundedCornerShape(12.dp))
                    .border(1.dp, CoffeeBorder, RoundedCornerShape(12.dp))
                    .padding(horizontal = 10.dp, vertical = CoffeeSpacing.xs)
                    .widthIn(max = 190.dp)
                    .zIndex(100f)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                ) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(CircleShape)
                            .background(person.color.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(getInterestEmoji(person.interests.firstOrNull() ?: ""), contentDescription = null, tint = CoffeeInk, modifier = Modifier.size(12.dp))
                    }

                    Column {
                        Text(
                            text = person.interests.joinToString(" & "),
                            style = MaterialTheme.typography.labelMedium,
                            color = CoffeeInk,
                            fontWeight = FontWeight.Bold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = "Someone nearby is open to plans",
                            style = MaterialTheme.typography.labelSmall.copy(fontSize = 9.sp),
                            color = CoffeeMuted,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }
        }

        if (people.isEmpty()) {
            Text(
                text = "No anonymous radar signals nearby",
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = CoffeeSpacing.sm)
            )
        }
    }
}

@Composable
private fun RadarDot(
    person: RadarPerson,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clickable(onClick = onClick)
            .size(56.dp),
        contentAlignment = Alignment.Center
    ) {
        if (isSelected) {
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .clip(CircleShape)
                    .background(CoffeePrimary.copy(alpha = 0.2f))
            )
        }
        Box(
            modifier = Modifier
                .size(42.dp)
                .shadow(elevation = 4.dp, shape = CircleShape)
                .clip(CircleShape)
                .background(Color.White)
                .border(2.dp, person.color, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = person.initials,
                style = MaterialTheme.typography.labelMedium,
                color = person.color,
                fontWeight = FontWeight.Bold,
                maxLines = 1
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
    private val userRepository: UserRepository = RepositoryProvider.userRepository,
    private val auth: FirebaseAuth = FirebaseAuth.getInstance(),
    private val locationProvider: AndroidLocationProvider = AndroidLocationProvider(application),
    private val store: GlobalDriftStore = GlobalDriftStore.getInstance(application)
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
                val radarDeferred = async {
                    userRepository.fetchRecentRadarProfiles().toRadarPeople(location, auth.currentUser?.uid)
                }
                val radarPeople = radarDeferred.await()
                _uiState.update {
                    it.copy(
                        locationState = LocationState.Available(location),
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

    fun refreshNearby() {
        if (_uiState.value.isScanning) return
        _uiState.update { it.copy(isScanning = true) }
        refresh(forceLocationWrite = true)
        viewModelScope.launch {
            kotlinx.coroutines.delay(3000)
            _uiState.update { it.copy(isScanning = false) }
        }
    }

    fun toggleRadarVisibility() {
        val nextValue = !_uiState.value.isRadarVisible
        preferences.edit().putBoolean(RADAR_VISIBLE_KEY, nextValue).apply()
        _uiState.update { it.copy(isRadarVisible = nextValue) }

        viewModelScope.launch {
            val uid = auth.currentUser?.uid ?: return@launch
            runCatching { userRepository.updateRadarVisibility(uid, nextValue) }
            if (nextValue) refreshNearby()
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

    private fun observeNotifications() {
        viewModelScope.launch {
            store.notifications.collect { notifications ->
                _uiState.update { it.copy(notifications = notifications.take(20)) }
            }
        }
    }

    init {
        _uiState.update {
            it.copy(isRadarVisible = preferences.getBoolean(RADAR_VISIBLE_KEY, true))
        }
        loadUserProfile()
        observeNotifications()
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
        .map { interest ->
            val count = counts[interest] ?: 0
            InterestCategory(interest, interest, count, colorForInterests(listOf(interest)))
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
    val isScanning: Boolean = false,
    val radarPeople: List<RadarPerson> = emptyList(),
    val interestCategories: List<InterestCategory> = emptyList(),
    val notifications: List<DiscoveryNotification> = emptyList(),
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

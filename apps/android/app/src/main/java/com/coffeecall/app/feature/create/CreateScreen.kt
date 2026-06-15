package com.coffeecall.app.feature.create

import android.app.Application
import android.location.Geocoder
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeCallTheme
import com.coffeecall.app.core.design.CoffeeError
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
import com.coffeecall.app.core.session.SessionPreferencesRepository
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.data.repository.FirebaseUserRepository
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.domain.repository.UserRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.UUID

@Composable
fun CreateScreen(
    onCreated: () -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as Application
    val viewModel: CreateDriftViewModel = viewModel(
        factory = CreateDriftViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()
    var showDiscardConfirmation by remember { mutableStateOf(false) }

    // Intercept back navigation if form is dirty
    BackHandler(enabled = uiState.hasUnsavedChanges) {
        showDiscardConfirmation = true
    }

    if (showDiscardConfirmation) {
        AlertDialog(
            onDismissRequest = { showDiscardConfirmation = false },
            title = { Text("Discard changes?", fontWeight = FontWeight.Bold) },
            text = { Text("Are you sure you want to go back? Your current Drift plan details will be lost.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        showDiscardConfirmation = false
                        onCreated() // Route back to Drifts
                    }
                ) {
                    Text("Discard", color = CoffeeError, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDiscardConfirmation = false }) {
                    Text("Cancel", color = CoffeeMuted)
                }
            },
            containerColor = CoffeeSurface
        )
    }

    CreateContent(
        uiState = uiState,
        popularHotspots = viewModel.popularHotspots,
        onActivitySelected = viewModel::selectActivity,
        onTitleChanged = viewModel::updateTitle,
        onHookChanged = viewModel::updateHook,
        onVibeSelected = viewModel::selectVibe,
        onDatePresetSelected = viewModel::selectDatePreset,
        onTimePresetSelected = viewModel::selectTimePreset,
        onCapacityChanged = viewModel::updateCapacity,
        onOpenToAllChanged = viewModel::setOpenToAll,
        onJoinModeSelected = viewModel::selectJoinMode,
        onNotesChanged = viewModel::updateNotes,
        onShowLocationPicker = viewModel::showLocationPicker,
        onDismissLocationPicker = viewModel::dismissLocationPicker,
        onLocationNameChanged = viewModel::updateLocationName,
        onLatitudeChanged = viewModel::updateLatitude,
        onLongitudeChanged = viewModel::updateLongitude,
        onLocationSearchQueryChanged = viewModel::updateLocationSearchQuery,
        onSelectLocationSuggestion = viewModel::selectLocationSuggestion,
        onSelectHotspot = viewModel::selectHotspot,
        onUseCurrentLocation = viewModel::useCurrentLocation,
        onConfirmLocation = viewModel::confirmLocation,
        onCreate = { viewModel.createDrift(onCreated) },
        onClearStatus = viewModel::clearTransientMessages
    )
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun CreateContent(
    uiState: CreateUiState,
    popularHotspots: List<LocationSearchResult>,
    onActivitySelected: (CreateActivity) -> Unit,
    onTitleChanged: (String) -> Unit,
    onHookChanged: (String) -> Unit,
    onVibeSelected: (CreateVibe) -> Unit,
    onDatePresetSelected: (DatePreset) -> Unit,
    onTimePresetSelected: (TimePreset) -> Unit,
    onCapacityChanged: (String) -> Unit,
    onOpenToAllChanged: (Boolean) -> Unit,
    onJoinModeSelected: (JoinMode) -> Unit,
    onNotesChanged: (String) -> Unit,
    onShowLocationPicker: () -> Unit,
    onDismissLocationPicker: () -> Unit,
    onLocationNameChanged: (String) -> Unit,
    onLatitudeChanged: (String) -> Unit,
    onLongitudeChanged: (String) -> Unit,
    onLocationSearchQueryChanged: (String) -> Unit,
    onSelectLocationSuggestion: (LocationSearchResult) -> Unit,
    onSelectHotspot: (LocationSearchResult) -> Unit,
    onUseCurrentLocation: () -> Unit,
    onConfirmLocation: () -> Unit,
    onCreate: () -> Unit,
    onClearStatus: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = CoffeeSpacing.screen)
            .padding(top = 104.dp, bottom = CoffeeSpacing.screenBottomSpacer),
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.lg)
    ) {
        HeaderCard()

        SectionCard(title = "Activity", subtitle = "Pick the shape of the plan.") {
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                CreateActivity.entries.forEach { activity ->
                    SelectablePill(
                        label = activity.label,
                        selected = uiState.activity == activity,
                        onClick = { onActivitySelected(activity) }
                    )
                }
            }
        }

        SectionCard(title = "Plan", subtitle = "Make it easy to say yes.") {
            OutlinedTextField(
                value = uiState.title,
                onValueChange = onTitleChanged,
                label = { Text("Title") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                supportingText = { Text("${uiState.title.length}/60") }
            )
            OutlinedTextField(
                value = uiState.hook,
                onValueChange = onHookChanged,
                label = { Text("Hook") },
                modifier = Modifier.fillMaxWidth(),
                minLines = 2,
                maxLines = 3
            )
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                CreateVibe.entries.forEach { vibe ->
                    SelectablePill(
                        label = vibe.label,
                        selected = uiState.vibe == vibe,
                        onClick = { onVibeSelected(vibe) },
                        accent = vibe.color
                    )
                }
            }
        }

        SectionCard(title = "When", subtitle = "Use a quick preset for now.") {
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                DatePreset.entries.forEach { preset ->
                    SelectablePill(
                        label = preset.label,
                        selected = uiState.datePreset == preset,
                        onClick = { onDatePresetSelected(preset) }
                    )
                }
            }
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                TimePreset.entries.forEach { preset ->
                    SelectablePill(
                        label = preset.label,
                        selected = uiState.timePreset == preset,
                        onClick = { onTimePresetSelected(preset) },
                        accent = CoffeePurple
                    )
                }
            }
        }

        SectionCard(title = "Where", subtitle = "Choose an approximate area with coordinates.") {
            Surface(
                onClick = onShowLocationPicker,
                modifier = Modifier.fillMaxWidth(),
                shape = CoffeeShapes.medium,
                color = CoffeeSurfaceSecondary.copy(alpha = 0.72f)
            ) {
                Row(
                    modifier = Modifier.padding(CoffeeSpacing.md),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = uiState.locationName.ifBlank { "Select location" },
                            style = MaterialTheme.typography.titleMedium,
                            color = CoffeeInk,
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = uiState.locationSummary,
                            style = MaterialTheme.typography.bodyMedium,
                            color = CoffeeMuted
                        )
                    }
                    Text("Edit", style = MaterialTheme.typography.labelMedium, color = CoffeePrimaryDark)
                }
            }
        }

        SectionCard(title = "Capacity", subtitle = "Keep the gathering comfortable.") {
            Row(verticalAlignment = Alignment.CenterVertically) {
                OutlinedTextField(
                    value = uiState.capacityText,
                    onValueChange = onCapacityChanged,
                    label = { Text("Spots") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.weight(1f),
                    enabled = !uiState.openToAll
                )
                Spacer(modifier = Modifier.width(CoffeeSpacing.md))
                Text("Open to all", style = MaterialTheme.typography.bodyMedium, color = CoffeeMuted)
                Switch(checked = uiState.openToAll, onCheckedChange = onOpenToAllChanged)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                SelectablePill(
                    label = "Open join",
                    selected = uiState.joinMode == JoinMode.Open,
                    onClick = { onJoinModeSelected(JoinMode.Open) }
                )
                SelectablePill(
                    label = "Approval",
                    selected = uiState.joinMode == JoinMode.Approval,
                    onClick = { onJoinModeSelected(JoinMode.Approval) }
                )
            }
        }

        SectionCard(title = "Optional notes", subtitle = "A little context helps.") {
            OutlinedTextField(
                value = uiState.notes,
                onValueChange = onNotesChanged,
                label = { Text("Notes") },
                modifier = Modifier.fillMaxWidth(),
                minLines = 2,
                maxLines = 4
            )
        }

        if (uiState.validationMessage != null || uiState.errorMessage != null || uiState.successMessage != null) {
            StatusCard(
                message = uiState.validationMessage ?: uiState.errorMessage ?: uiState.successMessage.orEmpty(),
                isError = uiState.successMessage == null,
                onDismiss = onClearStatus
            )
        }

        Button(
            onClick = onCreate,
            enabled = !uiState.isCreating,
            colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
        ) {
            if (uiState.isCreating) {
                CircularProgressIndicator(color = CoffeeTextOnBrand)
            } else {
                Text("Create Drift", color = CoffeeTextOnBrand)
            }
        }
    }

    if (uiState.showLocationPicker) {
        LocationPickerDialog(
            uiState = uiState,
            popularHotspots = popularHotspots,
            onDismiss = onDismissLocationPicker,
            onLocationNameChanged = onLocationNameChanged,
            onLatitudeChanged = onLatitudeChanged,
            onLongitudeChanged = onLongitudeChanged,
            onLocationSearchQueryChanged = onLocationSearchQueryChanged,
            onSelectLocationSuggestion = onSelectLocationSuggestion,
            onSelectHotspot = onSelectHotspot,
            onUseCurrentLocation = onUseCurrentLocation,
            onConfirm = onConfirmLocation
        )
    }
}

@Composable
private fun HeaderCard() {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        shadowElevation = 8.dp
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.lg),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
        ) {
            CoffeePillBadge(
                title = "NEW DRIFT",
                containerColor = CoffeePrimary.copy(alpha = 0.12f),
                contentColor = CoffeePrimaryDark
            )
            Text(
                text = "Start with the activity",
                style = MaterialTheme.typography.headlineSmall,
                color = CoffeeInk,
                fontWeight = FontWeight.Black
            )
            Text(
                text = "Android creates the same Drift documents iOS already reads.",
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted
            )
        }
    }
}

@Composable
private fun SectionCard(
    title: String,
    subtitle: String,
    content: @Composable () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        shadowElevation = 5.dp
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Text(text = title, style = MaterialTheme.typography.titleLarge, color = CoffeeInk)
            Text(text = subtitle, style = MaterialTheme.typography.bodyMedium, color = CoffeeMuted)
            content()
        }
    }
}

@Composable
private fun SelectablePill(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    accent: androidx.compose.ui.graphics.Color = CoffeePrimary
) {
    Surface(
        modifier = Modifier.clickable(onClick = onClick),
        shape = CircleShape,
        color = if (selected) accent else CoffeeSurfaceSecondary
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            color = if (selected) CoffeeTextOnBrand else CoffeeInk,
            modifier = Modifier.padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs)
        )
    }
}

@Composable
private fun StatusCard(
    message: String,
    isError: Boolean,
    onDismiss: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.medium,
        color = if (isError) CoffeeError.copy(alpha = 0.10f) else CoffeePrimary.copy(alpha = 0.10f)
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeInk,
                modifier = Modifier.weight(1f)
            )
            Text(
                text = "Dismiss",
                style = MaterialTheme.typography.labelMedium,
                color = if (isError) CoffeeError else CoffeePrimaryDark,
                modifier = Modifier.clickable(onClick = onDismiss)
            )
        }
    }
}

@Composable
private fun MapPickerCanvas(
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier) {
        val center = Offset(size.width / 2, size.height / 2)
        val maxRadius = minOf(size.width, size.height) * 0.45f

        // Draw grid lines to represent a map grid
        val gridStep = 30.dp.toPx()
        val gridColor = Color(0xFF53B8A6).copy(alpha = 0.08f)

        // Horizontal grid lines
        var y = 0f
        while (y < size.height) {
            drawLine(
                color = gridColor,
                start = Offset(0f, y),
                end = Offset(size.width, y),
                strokeWidth = 1.dp.toPx()
            )
            y += gridStep
        }

        // Vertical grid lines
        var x = 0f
        while (x < size.width) {
            drawLine(
                color = gridColor,
                start = Offset(x, 0f),
                end = Offset(x, size.height),
                strokeWidth = 1.dp.toPx()
            )
            x += gridStep
        }

        // concentric circles representing radar/approximate location radius
        listOf(0.3f, 0.6f, 0.9f).forEach { scale ->
            drawCircle(
                color = Color(0xFF53B8A6).copy(alpha = 0.12f * (1f - scale * 0.4f)),
                radius = maxRadius * scale,
                center = center,
                style = Stroke(
                    width = 1.5.dp.toPx(),
                    pathEffect = PathEffect.dashPathEffect(floatArrayOf(15f, 10f), 0f)
                )
            )
        }

        // Draw a pulse center ring
        drawCircle(
            color = Color(0xFF53B8A6).copy(alpha = 0.2f),
            radius = 16.dp.toPx(),
            center = center
        )
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun LocationPickerDialog(
    uiState: CreateUiState,
    popularHotspots: List<LocationSearchResult>,
    onDismiss: () -> Unit,
    onLocationNameChanged: (String) -> Unit,
    onLatitudeChanged: (String) -> Unit,
    onLongitudeChanged: (String) -> Unit,
    onLocationSearchQueryChanged: (String) -> Unit,
    onSelectLocationSuggestion: (LocationSearchResult) -> Unit,
    onSelectHotspot: (LocationSearchResult) -> Unit,
    onUseCurrentLocation: () -> Unit,
    onConfirm: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                text = "Select Location",
                style = MaterialTheme.typography.titleLarge,
                color = CoffeeInk,
                fontWeight = FontWeight.Black
            )
        },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
            ) {
                Text(
                    text = "Search for a place or select a popular hotspot nearby. Accurate geocoded coordinates will be attached.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeMuted
                )

                // Search Bar Input
                OutlinedTextField(
                    value = uiState.locationSearchQuery,
                    onValueChange = onLocationSearchQueryChanged,
                    label = { Text("Search location...") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    supportingText = {
                        if (uiState.isSearchingLocation) {
                            Text("Searching...", color = CoffeePrimaryDark)
                        }
                    },
                    trailingIcon = {
                        if (uiState.locationSearchQuery.isNotEmpty()) {
                            Text(
                                "✕",
                                modifier = Modifier
                                    .clickable { onLocationSearchQueryChanged("") }
                                    .padding(8.dp),
                                style = MaterialTheme.typography.titleMedium,
                                color = CoffeeMuted
                            )
                        }
                    }
                )

                // Search Suggestions List
                if (uiState.locationSuggestions.isNotEmpty()) {
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = CoffeeShapes.medium,
                        color = CoffeeSurfaceSecondary.copy(alpha = 0.5f),
                        border = BorderStroke(1.dp, CoffeeBorder)
                    ) {
                        Column {
                            uiState.locationSuggestions.forEach { suggestion ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clickable { onSelectLocationSuggestion(suggestion) }
                                        .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = "📍  ${suggestion.description}",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = CoffeeInk,
                                        maxLines = 2,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                                Spacer(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(1.dp)
                                        .background(CoffeeBorder)
                                )
                            }
                        }
                    }
                }

                // Popular Hotspots FlowRow
                if (uiState.locationSearchQuery.isEmpty()) {
                    Text(
                        text = "Popular Areas",
                        style = MaterialTheme.typography.titleMedium,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Bold
                    )
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                    ) {
                        popularHotspots.forEach { hotspot ->
                            Surface(
                                onClick = { onSelectHotspot(hotspot) },
                                shape = CircleShape,
                                color = if (uiState.draftLocationName == hotspot.name) CoffeePrimary.copy(alpha = 0.14f) else CoffeeSurfaceSecondary,
                                border = BorderStroke(
                                    1.dp,
                                    if (uiState.draftLocationName == hotspot.name) CoffeePrimary else CoffeeBorder
                                )
                            ) {
                                Text(
                                    text = hotspot.name.substringBefore(","),
                                    style = MaterialTheme.typography.labelMedium,
                                    color = if (uiState.draftLocationName == hotspot.name) CoffeePrimaryDark else CoffeeInk,
                                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                                )
                            }
                        }
                    }
                }

                // Custom Map Canvas Visualizer with Centered Pin
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                        .clip(CoffeeShapes.medium)
                        .background(CoffeeSurfaceSecondary.copy(alpha = 0.4f))
                        .border(1.dp, CoffeeBorder, CoffeeShapes.medium),
                    contentAlignment = Alignment.Center
                ) {
                    MapPickerCanvas(modifier = Modifier.fillMaxSize())
                    Text(
                        text = "📍",
                        fontSize = 32.sp,
                        modifier = Modifier.offset(y = (-14).dp)
                    )
                }

                // Manual Input Expansion / Details overrides
                var showManualFields by remember { mutableStateOf(false) }
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { showManualFields = !showManualFields }
                        .padding(vertical = CoffeeSpacing.xs),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Manual coordinates override",
                        style = MaterialTheme.typography.labelMedium,
                        color = CoffeePrimaryDark
                    )
                    Text(
                        text = if (showManualFields) "▲" else "▼",
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeePrimaryDark
                    )
                }

                if (showManualFields) {
                    Column(
                        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                    ) {
                        OutlinedTextField(
                            value = uiState.draftLocationName,
                            onValueChange = onLocationNameChanged,
                            label = { Text("Area name") },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true
                        )
                        Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                            OutlinedTextField(
                                value = uiState.draftLatitude,
                                onValueChange = onLatitudeChanged,
                                label = { Text("Latitude") },
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                modifier = Modifier.weight(1f),
                                singleLine = true
                            )
                            OutlinedTextField(
                                value = uiState.draftLongitude,
                                onValueChange = onLongitudeChanged,
                                label = { Text("Longitude") },
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                modifier = Modifier.weight(1f),
                                singleLine = true
                            )
                        }
                    }
                }

                // Bottom Selected Area card
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = CoffeeShapes.medium,
                    color = CoffeeSurfaceSecondary.copy(alpha = 0.8f),
                    border = BorderStroke(1.dp, CoffeeBorder)
                ) {
                    Row(
                        modifier = Modifier.padding(CoffeeSpacing.md),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(CoffeePrimary.copy(alpha = 0.12f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("📍", fontSize = 18.sp)
                        }
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "Selected Location",
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeMuted
                            )
                            Text(
                                text = uiState.draftLocationName.ifBlank { "No area selected" },
                                style = MaterialTheme.typography.titleMedium,
                                color = CoffeeInk,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            if (uiState.draftLatitude.isNotBlank() && uiState.draftLongitude.isNotBlank()) {
                                Text(
                                    text = "${uiState.draftLatitude}, ${uiState.draftLongitude}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = CoffeeMuted
                                )
                            }
                        }
                    }
                }

                if (uiState.locationPickerMessage != null) {
                    Text(
                        text = uiState.locationPickerMessage,
                        style = MaterialTheme.typography.bodyMedium,
                        color = CoffeePrimaryDark,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = onConfirm,
                enabled = uiState.draftLocationName.isNotBlank() && uiState.draftLatitude.isNotBlank() && uiState.draftLongitude.isNotBlank()
            ) {
                Text("Confirm Location", color = CoffeePrimaryDark, fontWeight = FontWeight.Bold)
            }
        },
        dismissButton = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                TextButton(onClick = onUseCurrentLocation) {
                    Text("Use Current GPS", color = CoffeePrimaryDark)
                }
                TextButton(onClick = onDismiss) {
                    Text("Cancel", color = CoffeeMuted)
                }
            }
        },
        containerColor = CoffeeSurface
    )
}

data class LocationSearchResult(
    val name: String,
    val latitude: Double,
    val longitude: Double,
    val description: String = ""
)

class CreateDriftViewModel(
    application: Application,
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val sessionRepository: SessionPreferencesRepository = SessionPreferencesRepository(application),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance(),
    private val locationProvider: AndroidLocationProvider = AndroidLocationProvider(application)
) : AndroidViewModel(application) {
    private val _uiState = MutableStateFlow(CreateUiState())
    val uiState: StateFlow<CreateUiState> = _uiState.asStateFlow()
    private var searchJob: Job? = null

    val popularHotspots = listOf(
        LocationSearchResult("Indiranagar, Bengaluru", 12.9719, 77.6412, "Popular café and shopping street"),
        LocationSearchResult("Koramangala, Bengaluru", 12.9352, 77.6245, "Tech hub and foodie hangout"),
        LocationSearchResult("HSR Layout, Bengaluru", 12.9141, 77.6411, "Social startups and cafés"),
        LocationSearchResult("MG Road, Bengaluru", 12.9744, 77.6075, "Metro station and central boulevard"),
        LocationSearchResult("Cubbon Park, Bengaluru", 12.9738, 77.5959, "Lush park and walking trails")
    )

    fun selectActivity(activity: CreateActivity) = _uiState.update { it.copy(activity = activity, validationMessage = null) }
    fun updateTitle(value: String) = _uiState.update { it.copy(title = value.take(60), validationMessage = null) }
    fun updateHook(value: String) = _uiState.update { it.copy(hook = value, validationMessage = null) }
    fun selectVibe(vibe: CreateVibe) = _uiState.update { it.copy(vibe = vibe, validationMessage = null) }
    fun selectDatePreset(preset: DatePreset) = _uiState.update { it.copy(datePreset = preset) }
    fun selectTimePreset(preset: TimePreset) = _uiState.update { it.copy(timePreset = preset) }
    fun selectJoinMode(mode: JoinMode) = _uiState.update { it.copy(joinMode = mode) }
    fun updateNotes(value: String) = _uiState.update { it.copy(notes = value) }

    fun updateCapacity(value: String) {
        val digits = value.filter { it.isDigit() }.take(2)
        _uiState.update { it.copy(capacityText = digits, validationMessage = null) }
    }

    fun setOpenToAll(open: Boolean) {
        _uiState.update {
            it.copy(
                openToAll = open,
                capacityText = if (open) "50" else it.capacityText.ifBlank { "3" }
            )
        }
    }

    fun showLocationPicker() {
        _uiState.update {
            it.copy(
                showLocationPicker = true,
                draftLocationName = it.locationName,
                draftLatitude = it.latitude?.toString().orEmpty(),
                draftLongitude = it.longitude?.toString().orEmpty(),
                locationSearchQuery = "",
                locationSuggestions = emptyList(),
                locationPickerMessage = null
            )
        }
    }

    fun dismissLocationPicker() = _uiState.update { it.copy(showLocationPicker = false, locationPickerMessage = null) }
    fun updateLocationName(value: String) = _uiState.update { it.copy(draftLocationName = value, locationPickerMessage = null) }
    fun updateLatitude(value: String) = _uiState.update { it.copy(draftLatitude = value, locationPickerMessage = null) }
    fun updateLongitude(value: String) = _uiState.update { it.copy(draftLongitude = value, locationPickerMessage = null) }

    fun updateLocationSearchQuery(query: String) {
        _uiState.update { it.copy(locationSearchQuery = query) }
        searchJob?.cancel()
        if (query.trim().length < 3) {
            _uiState.update { it.copy(locationSuggestions = emptyList(), isSearchingLocation = false) }
            return
        }

        searchJob = viewModelScope.launch {
            _uiState.update { it.copy(isSearchingLocation = true) }
            delay(400) // debounce
            val suggestions = withContext(Dispatchers.IO) {
                runCatching {
                    val geocoder = Geocoder(getApplication())
                    val addresses = geocoder.getFromLocationName(query, 5)
                    addresses?.mapNotNull { address ->
                        val lat = address.latitude
                        val lng = address.longitude
                        val name = address.locality ?: address.subLocality ?: address.featureName ?: query
                        val admin = address.subAdminArea ?: address.adminArea ?: address.countryName.orEmpty()
                        val description = if (admin.isNotBlank()) "$name, $admin" else name
                        LocationSearchResult(
                            name = description,
                            latitude = lat,
                            longitude = lng,
                            description = description
                        )
                    }
                }.getOrNull() ?: emptyList()
            }
            _uiState.update { it.copy(locationSuggestions = suggestions, isSearchingLocation = false) }
        }
    }

    fun selectLocationSuggestion(suggestion: LocationSearchResult) {
        _uiState.update {
            it.copy(
                draftLocationName = suggestion.name,
                draftLatitude = formatCoordinate(suggestion.latitude),
                draftLongitude = formatCoordinate(suggestion.longitude),
                locationSearchQuery = "",
                locationSuggestions = emptyList(),
                locationPickerMessage = "Place selected: ${suggestion.name}"
            )
        }
    }

    fun selectHotspot(hotspot: LocationSearchResult) {
        _uiState.update {
            it.copy(
                draftLocationName = hotspot.name,
                draftLatitude = formatCoordinate(hotspot.latitude),
                draftLongitude = formatCoordinate(hotspot.longitude),
                locationPickerMessage = "Hotspot set: ${hotspot.name}"
            )
        }
    }

    fun useCurrentLocation() {
        viewModelScope.launch {
            if (!locationProvider.hasLocationPermission()) {
                _uiState.update { it.copy(locationPickerMessage = "Location permission is not granted yet. Enter an area manually or allow location from Around.") }
                return@launch
            }
            _uiState.update { it.copy(locationPickerMessage = "Resolving coordinates...") }
            val location = locationProvider.currentLocation()
            if (location == null) {
                _uiState.update { it.copy(locationPickerMessage = "Could not resolve your current area. Manual coordinates still work.") }
            } else {
                val resolvedName = withContext(Dispatchers.IO) {
                    runCatching {
                        val geocoder = Geocoder(getApplication())
                        val addresses = geocoder.getFromLocation(location.latitude, location.longitude, 1)
                        val address = addresses?.firstOrNull()
                        if (address != null) {
                            val locality = address.locality ?: address.subLocality ?: address.featureName
                            val admin = address.subAdminArea ?: address.adminArea
                            if (locality != null && admin != null) "$locality, $admin"
                            else locality ?: address.featureName ?: "Current Area"
                        } else null
                    }.getOrNull()
                } ?: "Current Area"

                _uiState.update {
                    it.copy(
                        draftLocationName = resolvedName,
                        draftLatitude = formatCoordinate(location.latitude),
                        draftLongitude = formatCoordinate(location.longitude),
                        locationPickerMessage = "Location set to: $resolvedName"
                    )
                }
            }
        }
    }

    fun confirmLocation() {
        val locationName = _uiState.value.draftLocationName.trim()
        val latitude = _uiState.value.draftLatitude.toDoubleOrNull()
        val longitude = _uiState.value.draftLongitude.toDoubleOrNull()
        if (locationName.isBlank() || latitude == null || longitude == null || latitude !in -90.0..90.0 || longitude !in -180.0..180.0) {
            _uiState.update { it.copy(locationPickerMessage = "Enter an area name plus valid latitude and longitude.") }
            return
        }
        _uiState.update {
            it.copy(
                showLocationPicker = false,
                locationName = locationName,
                latitude = latitude,
                longitude = longitude,
                validationMessage = null,
                locationPickerMessage = null
            )
        }
    }

    fun clearTransientMessages() {
        _uiState.update { it.copy(validationMessage = null, errorMessage = null, successMessage = null) }
    }

    fun createDrift(onCreated: () -> Unit) {
        val validation = validate(_uiState.value)
        if (validation != null) {
            _uiState.update { it.copy(validationMessage = validation, errorMessage = null, successMessage = null) }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isCreating = true, validationMessage = null, errorMessage = null, successMessage = null) }
            runCatching {
                postRepository.createPostWithThread(buildPost())
            }.onSuccess {
                _uiState.update { CreateUiState(successMessage = "Drift created. Opening Drifts next.") }
                onCreated()
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        isCreating = false,
                        errorMessage = error.createMessage()
                    )
                }
            }
        }
    }

    private suspend fun buildPost(): DriftPost {
        val state = _uiState.value
        val uid = auth.currentUser?.uid ?: ""
        val session = sessionRepository.currentState()
        val profile = uid.takeIf { it.isNotBlank() }?.let { runCatching { userRepository.getUser(it) }.getOrNull() }
        val creatorName = profile?.name?.takeIf { it.isNotBlank() } ?: session.profileName.ifBlank { "Host" }
        val creatorInitials = profile?.initials?.takeIf { it.isNotBlank() } ?: session.profileInitials.ifBlank { initialsFrom(creatorName) }
        val capacity = state.resolvedCapacity
        val scheduled = state.scheduledCalendar()
        val latitude = state.latitude ?: 0.0
        val longitude = state.longitude ?: 0.0

        return DriftPost(
            id = UUID.randomUUID().toString(),
            title = state.title.trim(),
            description = state.descriptionText,
            location = state.locationName.trim(),
            meetingPoint = "Approximate area shared until the Drift is joined.",
            time = timeFormatter.format(scheduled.time),
            endTime = timeFormatter.format((scheduled.clone() as Calendar).apply { add(Calendar.HOUR_OF_DAY, 1) }.time),
            date = dateFormatter.format(scheduled.time),
            distance = 1.2,
            status = DriftStatus.Open,
            category = state.activity.category,
            hook = state.hook.trim(),
            creatorId = uid,
            creatorName = creatorName,
            creatorImageUrl = profile?.profilePhotoUrl.orEmpty(),
            creatorVerified = true,
            participantCount = 1,
            capacity = capacity,
            spotsLeft = (capacity - 1).coerceAtLeast(0),
            vibeTags = listOf(requireNotNull(state.vibe).label),
            whatToBring = emptyList(),
            participantInitials = listOfNotNull(creatorInitials.takeIf { it.isNotBlank() }),
            participantIds = listOfNotNull(uid.takeIf { it.isNotBlank() }),
            imageUrl = "",
            pendingRequests = emptyList(),
            latitude = latitude,
            longitude = longitude,
            joinMode = state.joinMode,
            locationGeoHash = GeoHash.encode(latitude, longitude)
        )
    }

    private fun validate(state: CreateUiState): String? =
        when {
            state.title.trim().isBlank() -> "Add a title for your Drift."
            state.vibe == null -> "Choose a vibe."
            state.locationName.trim().isBlank() || state.latitude == null || state.longitude == null -> "Select an approximate location with coordinates."
            state.resolvedCapacity < 1 -> "Choose at least one spot."
            auth.currentUser?.uid.isNullOrBlank() -> "Sign in with Firebase before creating a live Drift."
            else -> null
        }

    private fun Throwable.createMessage(): String =
        if (this is FirebaseUnavailableException) {
            "Firebase is not configured for this Android build yet, so the Drift was not created."
        } else {
            localizedMessage ?: "Could not create the Drift."
        }

    companion object {
        private val dateFormatter = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
        private val timeFormatter = SimpleDateFormat("h:mm a", Locale.getDefault())

        fun factory(application: Application): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    CreateDriftViewModel(application) as T
            }
    }
}

data class CreateUiState(
    val activity: CreateActivity = CreateActivity.Coffee,
    val title: String = "",
    val hook: String = "",
    val vibe: CreateVibe? = null,
    val datePreset: DatePreset = DatePreset.Today,
    val timePreset: TimePreset = TimePreset.In30,
    val capacityText: String = "3",
    val openToAll: Boolean = false,
    val joinMode: JoinMode = JoinMode.Open,
    val notes: String = "",
    val locationName: String = "",
    val latitude: Double? = null,
    val longitude: Double? = null,
    val showLocationPicker: Boolean = false,
    val draftLocationName: String = "",
    val draftLatitude: String = "",
    val draftLongitude: String = "",
    val locationPickerMessage: String? = null,
    val locationSearchQuery: String = "",
    val locationSuggestions: List<LocationSearchResult> = emptyList(),
    val isSearchingLocation: Boolean = false,
    val isCreating: Boolean = false,
    val validationMessage: String? = null,
    val errorMessage: String? = null,
    val successMessage: String? = null
) {
    val resolvedCapacity: Int = if (openToAll) 50 else capacityText.toIntOrNull()?.coerceIn(1, 50) ?: 0

    val locationSummary: String =
        if (latitude != null && longitude != null) {
            "${formatCoordinate(latitude)}, ${formatCoordinate(longitude)}"
        } else {
            "Manual picker or current area"
        }

    val descriptionText: String =
        listOf(hook.trim(), activity.label, notes.trim())
            .filter { it.isNotBlank() }
            .ifEmpty { listOf(title.trim()) }
            .joinToString(" • ")

    val hasUnsavedChanges: Boolean
        get() = title.isNotBlank() ||
            hook.isNotBlank() ||
            vibe != null ||
            notes.isNotBlank() ||
            locationName.isNotBlank() ||
            latitude != null ||
            longitude != null ||
            activity != CreateActivity.Coffee ||
            openToAll ||
            capacityText != "3"

    fun scheduledCalendar(): Calendar =
        Calendar.getInstance().apply {
            when (datePreset) {
                DatePreset.Today -> Unit
                DatePreset.Tomorrow -> add(Calendar.DAY_OF_YEAR, 1)
                DatePreset.Weekend -> {
                    while (get(Calendar.DAY_OF_WEEK) != Calendar.SATURDAY) {
                        add(Calendar.DAY_OF_YEAR, 1)
                    }
                }
            }
            when (timePreset) {
                TimePreset.Now -> add(Calendar.MINUTE, 5)
                TimePreset.In30 -> add(Calendar.MINUTE, 30)
                TimePreset.Tonight -> {
                    set(Calendar.HOUR_OF_DAY, 18)
                    set(Calendar.MINUTE, 30)
                }
                TimePreset.TomorrowMorning -> {
                    add(Calendar.DAY_OF_YEAR, if (datePreset == DatePreset.Today) 1 else 0)
                    set(Calendar.HOUR_OF_DAY, 10)
                    set(Calendar.MINUTE, 0)
                }
            }
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
}

enum class CreateActivity(val label: String, val category: DriftCategory) {
    Coffee("Coffee", DriftCategory.Coffee),
    Walk("Walk", DriftCategory.Walk),
    Food("Food", DriftCategory.Food),
    Movie("Movie", DriftCategory.Movie),
    Study("Study", DriftCategory.Study),
    Fitness("Fitness", DriftCategory.Yoga),
    Games("Games", DriftCategory.Gaming),
    Music("Music", DriftCategory.Music),
    Sports("Sports", DriftCategory.Event),
    Drinks("Drinks", DriftCategory.Event)
}

enum class CreateVibe(val label: String, val color: androidx.compose.ui.graphics.Color) {
    Casual("Casual", CoffeePeach),
    Chill("Chill", CoffeePeach),
    Friendly("Friendly", CoffeePrimary),
    Focused("Focused", CoffeePurple),
    Adventurous("Adventurous", CoffeePurple),
    Social("Social", CoffeePrimary)
}

enum class DatePreset(val label: String) {
    Today("Today"),
    Tomorrow("Tomorrow"),
    Weekend("Weekend")
}

enum class TimePreset(val label: String) {
    Now("Now"),
    In30("In 30"),
    Tonight("Tonight"),
    TomorrowMorning("Morning")
}

private fun initialsFrom(name: String): String =
    name.split(" ")
        .filter { it.isNotBlank() }
        .mapNotNull { it.firstOrNull()?.uppercaseChar()?.toString() }
        .take(2)
        .joinToString("")
        .ifBlank { "U" }

private fun formatCoordinate(value: Double): String =
    String.format(Locale.US, "%.5f", value)

@Preview(showBackground = true, widthDp = 360, heightDp = 980)
@Composable
private fun CreateContentPreview() {
    CoffeeCallTheme {
        CreateContent(
            uiState = CreateUiState(
                title = "Coffee and a short walk",
                hook = "Low-key chat after work.",
                vibe = CreateVibe.Friendly,
                locationName = "Indiranagar, Bengaluru",
                latitude = 12.9784,
                longitude = 77.6408
            ),
            popularHotspots = emptyList(),
            onActivitySelected = {},
            onTitleChanged = {},
            onHookChanged = {},
            onVibeSelected = {},
            onDatePresetSelected = {},
            onTimePresetSelected = {},
            onCapacityChanged = {},
            onOpenToAllChanged = {},
            onJoinModeSelected = {},
            onNotesChanged = {},
            onShowLocationPicker = {},
            onDismissLocationPicker = {},
            onLocationNameChanged = {},
            onLatitudeChanged = {},
            onLongitudeChanged = {},
            onLocationSearchQueryChanged = {},
            onSelectLocationSuggestion = {},
            onSelectHotspot = {},
            onUseCurrentLocation = {},
            onConfirmLocation = {},
            onCreate = {},
            onClearStatus = {}
        )
    }
}

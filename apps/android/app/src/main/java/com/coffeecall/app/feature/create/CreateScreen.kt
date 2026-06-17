package com.coffeecall.app.feature.create

import android.app.Application
import android.location.Geocoder
import androidx.activity.compose.BackHandler
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.*
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.core.location.AndroidLocationProvider
import com.coffeecall.app.core.location.GeoHash
import com.coffeecall.app.core.session.SessionPreferencesRepository
import com.coffeecall.app.core.state.GlobalDriftStore
import com.coffeecall.app.data.repository.RepositoryProvider
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.UserProfile
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
import java.util.*
import kotlin.math.roundToInt

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
                CoffeeButton(
                    title = "Discard",
                    onClick = {
                        showDiscardConfirmation = false
                        onCreated()
                    },
                    variant = CoffeeButtonVariant.Ghost,
                    fullWidth = false,
                    height = 40.dp
                )
            },
            dismissButton = {
                CoffeeButton(
                    title = "Cancel",
                    onClick = { showDiscardConfirmation = false },
                    variant = CoffeeButtonVariant.Ghost,
                    fullWidth = false,
                    height = 40.dp
                )
            },
            containerColor = CoffeeSurface
        )
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        // Redesigned Glass Backdrop
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = 100.dp)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            CoffeePrimary.copy(alpha = 0.05f),
                            Color.White.copy(alpha = 0.8f)
                        )
                    ),
                    shape = RoundedCornerShape(topStart = 48.dp, topEnd = 48.dp)
                )
                .border(
                    1.dp,
                    CoffeePrimary.copy(alpha = 0.1f),
                    RoundedCornerShape(topStart = 48.dp, topEnd = 48.dp)
                )
        )

        CreateContent(
            uiState = uiState,
            popularHotspots = viewModel.popularHotspots,
            onActivitySelected = viewModel::selectActivity,
            onTitleChanged = viewModel::updateTitle,
            onHookChanged = viewModel::updateHook,
            onVibeSelected = viewModel::selectVibe,
            onDatePresetSelected = viewModel::selectDatePreset,
            onTimePresetSelected = viewModel::selectTimePreset,
            onCustomDateSelected = viewModel::selectCustomDate,
            onCustomTimeSelected = viewModel::selectCustomTime,
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
            onClearStatus = viewModel::clearTransientMessages,
            onClose = onCreated
        )
    }
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
    onCustomDateSelected: (Int, Int, Int) -> Unit,
    onCustomTimeSelected: (Int, Int) -> Unit,
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
    onClearStatus: () -> Unit,
    onClose: () -> Unit
) {
    BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
        val isTablet = maxWidth >= 700.dp

        if (isTablet) {
            TabletCreatePanel(
                uiState = uiState,
                onClose = onClose,
                onActivitySelected = onActivitySelected,
                onTitleChanged = onTitleChanged,
                onHookChanged = onHookChanged,
                onVibeSelected = onVibeSelected,
                onDatePresetSelected = onDatePresetSelected,
                onTimePresetSelected = onTimePresetSelected,
                onCustomDateSelected = onCustomDateSelected,
                onCustomTimeSelected = onCustomTimeSelected,
                onCapacityChanged = onCapacityChanged,
                onOpenToAllChanged = onOpenToAllChanged,
                onJoinModeSelected = onJoinModeSelected,
                onNotesChanged = onNotesChanged,
                onShowLocationPicker = onShowLocationPicker,
                onCreate = onCreate,
                onClearStatus = onClearStatus
            )
        } else {
            PhoneCreateSheet(
                uiState = uiState,
                onClose = onClose,
                onActivitySelected = onActivitySelected,
                onTitleChanged = onTitleChanged,
                onHookChanged = onHookChanged,
                onVibeSelected = onVibeSelected,
                onDatePresetSelected = onDatePresetSelected,
                onTimePresetSelected = onTimePresetSelected,
                onCustomDateSelected = onCustomDateSelected,
                onCustomTimeSelected = onCustomTimeSelected,
                onCapacityChanged = onCapacityChanged,
                onOpenToAllChanged = onOpenToAllChanged,
                onJoinModeSelected = onJoinModeSelected,
                onNotesChanged = onNotesChanged,
                onShowLocationPicker = onShowLocationPicker,
                onCreate = onCreate,
                onClearStatus = onClearStatus
            )
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
private fun PhoneCreateSheet(
    uiState: CreateUiState,
    onClose: () -> Unit,
    onActivitySelected: (CreateActivity) -> Unit,
    onTitleChanged: (String) -> Unit,
    onHookChanged: (String) -> Unit,
    onVibeSelected: (CreateVibe) -> Unit,
    onDatePresetSelected: (DatePreset) -> Unit,
    onTimePresetSelected: (TimePreset) -> Unit,
    onCustomDateSelected: (Int, Int, Int) -> Unit,
    onCustomTimeSelected: (Int, Int) -> Unit,
    onCapacityChanged: (String) -> Unit,
    onOpenToAllChanged: (Boolean) -> Unit,
    onJoinModeSelected: (JoinMode) -> Unit,
    onNotesChanged: (String) -> Unit,
    onShowLocationPicker: () -> Unit,
    onCreate: () -> Unit,
    onClearStatus: () -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        HeaderRow(onClose = onClose, centered = true)

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Spacer(modifier = Modifier.height(2.dp))
            ActivitySection(uiState.activity, onActivitySelected)
            PlanSection(uiState.title, onTitleChanged, uiState.hook, onHookChanged)
            VibeSection(uiState.vibe, onVibeSelected)
            WhenSection(
                uiState.datePreset,
                onDatePresetSelected,
                uiState.timePreset,
                onTimePresetSelected,
                uiState.scheduledCalendar().timeInMillis,
                onCustomDateSelected,
                onCustomTimeSelected
            )
            LocationSection(uiState.locationName, uiState.latitude, onShowLocationPicker)
            GatheringSection(uiState.capacityText, onCapacityChanged, uiState.openToAll, onOpenToAllChanged, uiState.joinMode, onJoinModeSelected)
            NotesSection(uiState.notes, onNotesChanged)
            StatusBlock(uiState, onClearStatus)
            Spacer(modifier = Modifier.height(86.dp))
        }

        StickyFooter(uiState.isCreating, onCreate)
    }
}

@Composable
private fun TabletCreatePanel(
    uiState: CreateUiState,
    onClose: () -> Unit,
    onActivitySelected: (CreateActivity) -> Unit,
    onTitleChanged: (String) -> Unit,
    onHookChanged: (String) -> Unit,
    onVibeSelected: (CreateVibe) -> Unit,
    onDatePresetSelected: (DatePreset) -> Unit,
    onTimePresetSelected: (TimePreset) -> Unit,
    onCustomDateSelected: (Int, Int, Int) -> Unit,
    onCustomTimeSelected: (Int, Int) -> Unit,
    onCapacityChanged: (String) -> Unit,
    onOpenToAllChanged: (Boolean) -> Unit,
    onJoinModeSelected: (JoinMode) -> Unit,
    onNotesChanged: (String) -> Unit,
    onShowLocationPicker: () -> Unit,
    onCreate: () -> Unit,
    onClearStatus: () -> Unit
) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .heightIn(max = 760.dp),
            shape = RoundedCornerShape(22.dp),
            color = Color.White.copy(alpha = 0.94f),
            border = BorderStroke(1.dp, CoffeeBorder),
            shadowElevation = 18.dp
        ) {
            Column(modifier = Modifier.fillMaxWidth()) {
                HeaderRow(onClose = onClose, centered = false)

                Row(
                    modifier = Modifier
                        .weight(1f)
                        .padding(horizontal = 24.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(20.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .verticalScroll(rememberScrollState()),
                        verticalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        ActivitySection(uiState.activity, onActivitySelected)
                        PlanSection(uiState.title, onTitleChanged, uiState.hook, onHookChanged)
                        VibeSection(uiState.vibe, onVibeSelected)
                        WhenSection(
                            uiState.datePreset,
                            onDatePresetSelected,
                            uiState.timePreset,
                            onTimePresetSelected,
                            uiState.scheduledCalendar().timeInMillis,
                            onCustomDateSelected,
                            onCustomTimeSelected
                        )
                    }

                    Column(
                        modifier = Modifier
                            .width(360.dp)
                            .verticalScroll(rememberScrollState()),
                        verticalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        LocationSection(uiState.locationName, uiState.latitude, onShowLocationPicker)
                        GatheringSection(uiState.capacityText, onCapacityChanged, uiState.openToAll, onOpenToAllChanged, uiState.joinMode, onJoinModeSelected)
                        NotesSection(uiState.notes, onNotesChanged)
                        StatusBlock(uiState, onClearStatus)
                    }
                }

                StickyFooter(uiState.isCreating, onCreate)
            }
        }
    }
}

@Composable
private fun HeaderRow(onClose: () -> Unit, centered: Boolean) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .padding(horizontal = 20.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (centered) {
            IconButton(onClick = onClose, modifier = Modifier.size(40.dp)) {
                Icon(CoffeeIcons.back, contentDescription = "Close", tint = CoffeeInk, modifier = Modifier.size(20.dp))
            }
        }

        Column(
            modifier = Modifier.weight(1f),
            horizontalAlignment = if (centered) Alignment.CenterHorizontally else Alignment.Start
        ) {
            Text(
                text = "NEW DRIFT",
                style = MaterialTheme.typography.labelSmall,
                color = CoffeePrimaryDark,
                fontWeight = FontWeight.Black,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(CoffeePrimary.copy(alpha = 0.12f))
                    .padding(horizontal = 9.dp, vertical = 4.dp)
            )
            Text(
                text = "Host a Moment",
                style = if (centered) MaterialTheme.typography.titleLarge else MaterialTheme.typography.headlineSmall,
                color = CoffeeInk,
                fontWeight = FontWeight.Black
            )
            Text(
                text = if (centered) "Create a plan. Invite people. Make it happen." else "Create meaningful moments with people around you.",
                style = MaterialTheme.typography.bodySmall,
                color = CoffeeMuted
            )
        }

        IconButton(
            onClick = onClose,
            modifier = Modifier.size(40.dp)
        ) {
            Icon(CoffeeIcons.close, contentDescription = "Close", tint = CoffeeInk, modifier = Modifier.size(20.dp))
        }
    }
}

@Composable
private fun StatusBlock(uiState: CreateUiState, onClearStatus: () -> Unit) {
    if (uiState.validationMessage != null || uiState.errorMessage != null || uiState.successMessage != null) {
        StatusCard(
            message = uiState.validationMessage ?: uiState.errorMessage ?: uiState.successMessage.orEmpty(),
            isError = uiState.successMessage == null,
            onDismiss = onClearStatus
        )
    }
}

@Composable
private fun SectionCard(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        color = Color.White.copy(alpha = 0.74f),
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 14.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelLarge,
                color = CoffeeInk,
                fontWeight = FontWeight.Black
            )
            content()
        }
    }
}

@Composable
private fun ActivitySection(
    selectedActivity: CreateActivity,
    onActivitySelected: (CreateActivity) -> Unit
) {
    SectionCard("1. What are we doing?") {
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            CreateActivity.entries.take(7).forEach { activity ->
                ActivityTile(
                    activity = activity,
                    isSelected = selectedActivity == activity,
                    onClick = { onActivitySelected(activity) }
                )
            }
        }
    }
}

@Composable
private fun PlanSection(
    title: String,
    onTitleChanged: (String) -> Unit,
    hook: String,
    onHookChanged: (String) -> Unit
) {
    SectionCard("2. The plan") {
        FormField(
            label = "Drift title *",
            value = title,
            onValueChange = { onTitleChanged(it.take(60)) },
            placeholder = "e.g. Coffee & conversations",
            counter = "${title.length.coerceAtMost(60)}/60"
        )
        FormField(
            label = "Hook / Icebreaker",
            value = hook,
            onValueChange = { onHookChanged(it.take(120)) },
            placeholder = "e.g. Bringing my dog, hope that's okay!",
            counter = "${hook.length.coerceAtMost(120)}/120"
        )
    }
}

@Composable
private fun VibeSection(
    selectedVibe: CreateVibe?,
    onVibeSelected: (CreateVibe) -> Unit
) {
    SectionCard("3. Vibe") {
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            CreateVibe.entries.forEach { vibe ->
                SelectablePill(vibe.label, selectedVibe == vibe, { onVibeSelected(vibe) }, CoffeePrimary)
            }
        }
    }
}

@Composable
private fun WhenSection(
    datePreset: DatePreset,
    onDatePresetSelected: (DatePreset) -> Unit,
    timePreset: TimePreset,
    onTimePresetSelected: (TimePreset) -> Unit,
    scheduledTimeMillis: Long,
    onCustomDateSelected: (Int, Int, Int) -> Unit,
    onCustomTimeSelected: (Int, Int) -> Unit
) {
    val context = LocalContext.current
    val selectedCalendar = remember(scheduledTimeMillis) {
        Calendar.getInstance().apply { timeInMillis = scheduledTimeMillis }
    }

    SectionCard("4. When") {
        TinyLabel("Date")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SelectablePill("Today", datePreset == DatePreset.Today, { onDatePresetSelected(DatePreset.Today) }, modifier = Modifier.weight(1f))
            SelectablePill("Tomorrow", datePreset == DatePreset.Tomorrow, { onDatePresetSelected(DatePreset.Tomorrow) }, modifier = Modifier.weight(1f))
            SelectablePill(
                label = "Pick date",
                selected = datePreset == DatePreset.Custom,
                onClick = {
                    android.app.DatePickerDialog(
                        context,
                        { _, year, month, day -> onCustomDateSelected(year, month, day) },
                        selectedCalendar.get(Calendar.YEAR),
                        selectedCalendar.get(Calendar.MONTH),
                        selectedCalendar.get(Calendar.DAY_OF_MONTH)
                    ).show()
                },
                modifier = Modifier.weight(1f)
            )
        }

        TinyLabel("Time")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SelectablePill("In 30 mins", timePreset == TimePreset.In30, { onTimePresetSelected(TimePreset.In30) }, modifier = Modifier.weight(1f))
            SelectablePill("In 1 hour", timePreset == TimePreset.In60, { onTimePresetSelected(TimePreset.In60) }, modifier = Modifier.weight(1f))
            SelectablePill(
                label = "Pick time",
                selected = timePreset == TimePreset.Custom,
                onClick = {
                    android.app.TimePickerDialog(
                        context,
                        { _, hour, minute -> onCustomTimeSelected(hour, minute) },
                        selectedCalendar.get(Calendar.HOUR_OF_DAY),
                        selectedCalendar.get(Calendar.MINUTE),
                        false
                    ).show()
                },
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun LocationSection(
    locationName: String,
    latitude: Double?,
    onShowLocationPicker: () -> Unit
) {
    SectionCard("5. Where") {
        Surface(
            onClick = onShowLocationPicker,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            color = Color.White,
            border = BorderStroke(1.dp, CoffeeBorder)
        ) {
            Column {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(96.dp)
                        .clip(RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp))
                        .background(CoffeeBackground)
                ) {
                    MapPickerCanvas(modifier = Modifier.fillMaxSize())
                    Icon(
                        imageVector = CoffeeIcons.location,
                        contentDescription = null,
                        tint = CoffeePrimaryDark,
                        modifier = Modifier.align(Alignment.Center).size(34.dp)
                    )
                }

                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                        Text(
                            text = locationName.ifBlank { "Indiranagar, Bengaluru" },
                            style = MaterialTheme.typography.labelLarge,
                            color = CoffeeInk,
                            fontWeight = FontWeight.Bold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = if (latitude == null) "Near 100 Feet Road" else "Coordinates selected",
                            style = MaterialTheme.typography.bodySmall,
                            color = CoffeeMuted
                        )
                        Text(
                            text = "Change area >",
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeePrimaryDark,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Icon(CoffeeIcons.chevronRight, contentDescription = null, tint = CoffeeMuted, modifier = Modifier.size(18.dp))
                }
            }
        }
    }
}

@Composable
private fun GatheringSection(
    capacityText: String,
    onCapacityChanged: (String) -> Unit,
    openToAll: Boolean,
    onOpenToAllChanged: (Boolean) -> Unit,
    joinMode: JoinMode,
    onJoinModeSelected: (JoinMode) -> Unit
) {
    SectionCard("6. Gathering") {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text("Spots", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold, color = CoffeeInk)
                Text("How many can join?", style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
            }
            CapacityStepper(capacityText, onCapacityChanged)
        }

        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text("Open to all", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold, color = CoffeeInk)
                Text("Anyone can join without approval", style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
            }
            Switch(
                checked = openToAll,
                onCheckedChange = onOpenToAllChanged,
                colors = SwitchDefaults.colors(checkedThumbColor = Color.White, checkedTrackColor = CoffeePrimaryDark)
            )
        }

        TinyLabel("Join mode")
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            JoinModeButton(
                title = "Open Join",
                subtitle = "Instant",
                icon = CoffeeIcons.people,
                isSelected = joinMode == JoinMode.Open,
                onClick = { onJoinModeSelected(JoinMode.Open) },
                modifier = Modifier.weight(1f)
            )
            JoinModeButton(
                title = "Approval Required",
                subtitle = "Manual",
                icon = CoffeeIcons.lock,
                isSelected = joinMode == JoinMode.Approval,
                onClick = { onJoinModeSelected(JoinMode.Approval) },
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun NotesSection(
    notes: String,
    onNotesChanged: (String) -> Unit
) {
    SectionCard("7. Notes (Optional)") {
        OutlinedTextField(
            value = notes,
            onValueChange = { onNotesChanged(it.take(300)) },
            placeholder = { Text("Add anything else people should know...") },
            modifier = Modifier.fillMaxWidth().heightIn(min = 72.dp),
            minLines = 2,
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = Color.White,
                focusedContainerColor = Color.White,
                unfocusedBorderColor = CoffeeBorder,
                focusedBorderColor = CoffeePrimary
            ),
            shape = RoundedCornerShape(10.dp)
        )

        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SuggestionChip("What to bring")
            SuggestionChip("Parking info")
            SuggestionChip("Group vibe")
        }
    }
}

@Composable
private fun FormField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    counter: String
) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row {
            Text(label, style = MaterialTheme.typography.labelSmall, color = CoffeeInk, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.weight(1f))
            Text(counter, style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
        }
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            placeholder = { Text(placeholder) },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = Color.White,
                focusedContainerColor = Color.White,
                unfocusedBorderColor = CoffeeBorder,
                focusedBorderColor = CoffeePrimary
            ),
            shape = RoundedCornerShape(10.dp),
            textStyle = MaterialTheme.typography.bodyMedium
        )
    }
}

@Composable
private fun TinyLabel(text: String) {
    Text(text, style = MaterialTheme.typography.labelSmall, color = CoffeeMuted, fontWeight = FontWeight.Bold)
}

@Composable
private fun CapacityStepper(
    capacityText: String,
    onCapacityChanged: (String) -> Unit
) {
    val capacity = capacityText.toIntOrNull()?.coerceIn(1, 20) ?: 3
    Surface(
        shape = RoundedCornerShape(10.dp),
        color = Color.White,
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = { onCapacityChanged((capacity - 1).coerceAtLeast(1).toString()) }, modifier = Modifier.size(36.dp)) {
                Text("−", fontWeight = FontWeight.Black, color = CoffeeInk)
            }
            Text(
                text = capacity.toString(),
                modifier = Modifier.width(28.dp),
                textAlign = TextAlign.Center,
                fontWeight = FontWeight.Black,
                color = CoffeeInk
            )
            IconButton(onClick = { onCapacityChanged((capacity + 1).coerceAtMost(20).toString()) }, modifier = Modifier.size(36.dp)) {
                Text("+", fontWeight = FontWeight.Black, color = CoffeeInk)
            }
        }
    }
}

@Composable
private fun SuggestionChip(label: String) {
    Surface(
        shape = CircleShape,
        color = CoffeeBackground.copy(alpha = 0.55f),
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Text(
            text = label,
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 7.dp),
            style = MaterialTheme.typography.labelSmall,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
private fun SectionHeader(title: String, subtitle: String) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleLarge,
            color = CoffeeInk,
            fontWeight = FontWeight.Black
        )
        Text(
            text = subtitle,
            style = MaterialTheme.typography.bodyMedium,
            color = CoffeeMuted
        )
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun ActivityGrid(
    selectedActivity: CreateActivity,
    onActivitySelected: (CreateActivity) -> Unit
) {
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        maxItemsInEachRow = 3
    ) {
        CreateActivity.entries.forEach { activity ->
            ActivityTile(
                activity = activity,
                isSelected = selectedActivity == activity,
                onClick = { onActivitySelected(activity) },
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun ActivityTile(
    activity: CreateActivity,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val accent = categoryAccent(activity.category.name)

    Surface(
        onClick = onClick,
        modifier = modifier.size(width = 64.dp, height = 66.dp),
        shape = RoundedCornerShape(12.dp),
        color = if (isSelected) accent.copy(alpha = 0.08f) else Color.White,
        border = BorderStroke(
            width = if (isSelected) 1.5.dp else 1.dp,
            color = if (isSelected) accent else CoffeeBorder
        )
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterVertically)
        ) {
            Icon(
                imageVector = CoffeeIcons.category(activity.category.name),
                contentDescription = activity.label,
                tint = accent,
                modifier = Modifier.size(22.dp)
            )
            Text(
                text = activity.label,
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeInk,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun PlanDetailsCard(
    title: String,
    onTitleChanged: (String) -> Unit,
    hook: String,
    onHookChanged: (String) -> Unit,
    selectedVibe: CreateVibe?,
    onVibeSelected: (CreateVibe) -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        color = Color.White,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedTextField(
                value = title,
                onValueChange = onTitleChanged,
                placeholder = { Text("What's the plan?") },
                modifier = Modifier.fillMaxWidth(),
                textStyle = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Black),
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedBorderColor = Color.Transparent,
                    focusedBorderColor = Color.Transparent
                )
            )

            OutlinedTextField(
                value = hook,
                onValueChange = onHookChanged,
                placeholder = { Text("Add a short hook to invite others...") },
                modifier = Modifier.fillMaxWidth(),
                textStyle = MaterialTheme.typography.bodyLarge,
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedBorderColor = Color.Transparent,
                    focusedBorderColor = Color.Transparent
                )
            )

            Row(
                modifier = Modifier.horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                CreateVibe.entries.forEach { vibe ->
                    SelectablePill(
                        label = vibe.label,
                        selected = selectedVibe == vibe,
                        onClick = { onVibeSelected(vibe) },
                        accent = vibe.color
                    )
                }
            }
        }
    }
}

@Composable
private fun WhenWhereCard(
    datePreset: DatePreset,
    onDatePresetSelected: (DatePreset) -> Unit,
    timePreset: TimePreset,
    onTimePresetSelected: (TimePreset) -> Unit,
    locationName: String,
    locationSummary: String,
    latitude: Double?,
    longitude: Double?,
    onShowLocationPicker: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        color = Color.White,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // When
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    DatePreset.entries.forEach { preset ->
                        SelectablePill(
                            label = preset.label,
                            selected = datePreset == preset,
                            onClick = { onDatePresetSelected(preset) }
                        )
                    }
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    TimePreset.entries.forEach { preset ->
                        SelectablePill(
                            label = preset.label,
                            selected = timePreset == preset,
                            onClick = { onTimePresetSelected(preset) },
                            accent = CoffeePurple
                        )
                    }
                }
            }

            // Where
            Surface(
                onClick = onShowLocationPicker,
                shape = RoundedCornerShape(20.dp),
                color = CoffeeBackground.copy(alpha = 0.4f),
                border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.3f))
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(CircleShape)
                            .background(CoffeePrimary.copy(alpha = 0.15f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = CoffeeIcons.location,
                            contentDescription = null,
                            tint = CoffeePrimary,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = locationName.ifBlank { "Select Area" },
                            style = MaterialTheme.typography.bodyLarge,
                            fontWeight = FontWeight.Black,
                            color = CoffeeInk
                        )
                        Text(
                            text = if (latitude != null) "Approximate coordinates set" else "Choose where to meet",
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
        }
    }
}

@Composable
private fun GatheringCard(
    capacityText: String,
    onCapacityChanged: (String) -> Unit,
    openToAll: Boolean,
    onOpenToAllChanged: (Boolean) -> Unit,
    joinMode: JoinMode,
    onJoinModeSelected: (JoinMode) -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        color = Color.White,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = "Spots", style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold)
                    Text(text = if (openToAll) "Unlimited" else "$capacityText people", style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
                }

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Open to all", style = MaterialTheme.typography.labelMedium, color = CoffeeMuted)
                    Spacer(modifier = Modifier.width(8.dp))
                    Switch(checked = openToAll, onCheckedChange = onOpenToAllChanged)
                }
            }

            if (!openToAll) {
                Slider(
                    value = capacityText.toFloatOrNull() ?: 3f,
                    onValueChange = { onCapacityChanged(it.roundToInt().toString()) },
                    valueRange = 1f..20f,
                    steps = 19,
                    colors = SliderDefaults.colors(
                        thumbColor = CoffeePrimary,
                        activeTrackColor = CoffeePrimary,
                        inactiveTrackColor = CoffeeBorder
                    )
                )
            }

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                JoinModeButton(
                    title = "Open Join",
                    isSelected = joinMode == JoinMode.Open,
                    onClick = { onJoinModeSelected(JoinMode.Open) },
                    modifier = Modifier.weight(1f)
                )
                JoinModeButton(
                    title = "Approval",
                    isSelected = joinMode == JoinMode.Approval,
                    onClick = { onJoinModeSelected(JoinMode.Approval) },
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun JoinModeButton(
    title: String,
    subtitle: String = "",
    icon: ImageVector? = null,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = onClick,
        modifier = modifier.height(52.dp),
        shape = RoundedCornerShape(10.dp),
        color = if (isSelected) CoffeePrimary.copy(alpha = 0.10f) else Color.White,
        border = BorderStroke(1.dp, if (isSelected) CoffeePrimary else CoffeeBorder)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            if (icon != null) {
                Icon(icon, contentDescription = null, tint = if (isSelected) CoffeePrimaryDark else CoffeeMuted, modifier = Modifier.size(18.dp))
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(title, style = MaterialTheme.typography.labelSmall, color = CoffeeInk, fontWeight = FontWeight.Black, maxLines = 1, overflow = TextOverflow.Ellipsis)
                if (subtitle.isNotBlank()) {
                    Text(subtitle, style = MaterialTheme.typography.labelSmall, color = CoffeeMuted, maxLines = 1)
                }
            }
        }
    }
}

@Composable
private fun ContextCard(
    notes: String,
    onNotesChanged: (String) -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        color = Color.White,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f))
    ) {
        OutlinedTextField(
            value = notes,
            onValueChange = onNotesChanged,
            placeholder = { Text("Any extra details or items to bring?") },
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            minLines = 3,
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = Color.Transparent,
                focusedBorderColor = Color.Transparent
            )
        )
    }
}

@Composable
private fun StickyFooter(
    isCreating: Boolean,
    onCreate: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color.White.copy(alpha = 0.94f),
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f)),
        shadowElevation = 8.dp
    ) {
        Column(
            modifier = Modifier
                .navigationBarsPadding()
                .padding(horizontal = 16.dp, vertical = 10.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            CoffeeButton(
                title = if (isCreating) "Creating Drift" else "Create Drift",
                onClick = onCreate,
                variant = CoffeeButtonVariant.Primary,
                enabled = !isCreating,
                leadingIcon = CoffeeIcons.create,
                height = 48.dp
            )
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                Icon(CoffeeIcons.lock, contentDescription = null, tint = CoffeeMuted, modifier = Modifier.size(11.dp))
                Text(
                    text = "You can review everything before it goes live.",
                    style = MaterialTheme.typography.labelSmall,
                    color = CoffeeMuted
                )
            }
        }
    }
}

@Composable
private fun SelectablePill(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    accent: Color = CoffeePrimary,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(8.dp),
        color = if (selected) accent.copy(alpha = 0.10f) else Color.White,
        border = BorderStroke(1.dp, if (selected) accent else CoffeeBorder),
        modifier = modifier.height(36.dp)
    ) {
        Box(
            modifier = Modifier.padding(horizontal = 13.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = if (selected) CoffeePrimaryDark else CoffeeInk,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
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
        shape = RoundedCornerShape(16.dp),
        color = if (isError) CoffeeError.copy(alpha = 0.10f) else CoffeePrimary.copy(alpha = 0.10f)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeInk,
                modifier = Modifier.weight(1f)
            )
            Text(
                text = "✕",
                style = MaterialTheme.typography.titleMedium,
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

        val gridStep = 30.dp.toPx()
        val gridColor = Color(0xFF53B8A6).copy(alpha = 0.08f)

        var y = 0f
        while (y < size.height) {
            drawLine(color = gridColor, start = Offset(0f, y), end = Offset(size.width, y), strokeWidth = 1.dp.toPx())
            y += gridStep
        }

        var x = 0f
        while (x < size.width) {
            drawLine(color = gridColor, start = Offset(x, 0f), end = Offset(x, size.height), strokeWidth = 1.dp.toPx())
            x += gridStep
        }

        listOf(0.3f, 0.6f, 0.9f).forEach { scale ->
            drawCircle(
                color = Color(0xFF53B8A6).copy(alpha = 0.12f * (1f - scale * 0.4f)),
                radius = maxRadius * scale,
                center = center,
                style = Stroke(width = 1.5.dp.toPx(), pathEffect = PathEffect.dashPathEffect(floatArrayOf(15f, 10f), 0f))
            )
        }
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
        title = { Text("Select Area", fontWeight = FontWeight.Black) },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                OutlinedTextField(
                    value = uiState.locationSearchQuery,
                    onValueChange = onLocationSearchQueryChanged,
                    label = { Text("Search location...") },
                    modifier = Modifier.fillMaxWidth()
                )

                if (uiState.locationSuggestions.isNotEmpty()) {
                    Column {
                        uiState.locationSuggestions.forEach { suggestion ->
                            Text(
                                text = suggestion.description,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { onSelectLocationSuggestion(suggestion) }
                                    .padding(vertical = 8.dp)
                            )
                        }
                    }
                }

                if (uiState.locationSearchQuery.isEmpty()) {
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        popularHotspots.forEach { hotspot ->
                            SelectablePill(
                                label = hotspot.name.substringBefore(","),
                                selected = uiState.draftLocationName == hotspot.name,
                                onClick = { onSelectHotspot(hotspot) }
                            )
                        }
                    }
                }

                Box(
                    modifier = Modifier.fillMaxWidth().height(140.dp).clip(RoundedCornerShape(12.dp)).background(CoffeeBackground),
                    contentAlignment = Alignment.Center
                ) {
                    MapPickerCanvas(modifier = Modifier.fillMaxSize())
                    Text("📍", fontSize = 24.sp, modifier = Modifier.offset(y = (-8).dp))
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onConfirm) { Text("Confirm") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        },
        containerColor = Color.White
    )
}

data class LocationSearchResult(val name: String, val latitude: Double, val longitude: Double, val description: String = "")

class CreateDriftViewModel(
    application: Application,
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val sessionRepository: SessionPreferencesRepository = SessionPreferencesRepository(application),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance(),
    private val locationProvider: AndroidLocationProvider = AndroidLocationProvider(application),
    private val store: GlobalDriftStore = GlobalDriftStore.getInstance(application)
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

    fun selectActivity(activity: CreateActivity) = _uiState.update { it.copy(activity = activity) }
    fun updateTitle(value: String) = _uiState.update { it.copy(title = value.take(60)) }
    fun updateHook(value: String) = _uiState.update { it.copy(hook = value) }
    fun selectVibe(vibe: CreateVibe) = _uiState.update { it.copy(vibe = vibe) }
    fun selectDatePreset(preset: DatePreset) = _uiState.update { it.copy(datePreset = preset) }
    fun selectTimePreset(preset: TimePreset) = _uiState.update { it.copy(timePreset = preset) }
    fun selectCustomDate(year: Int, month: Int, day: Int) = _uiState.update {
        it.copy(datePreset = DatePreset.Custom, customYear = year, customMonth = month, customDay = day)
    }
    fun selectCustomTime(hour: Int, minute: Int) = _uiState.update {
        it.copy(timePreset = TimePreset.Custom, customHour = hour, customMinute = minute)
    }
    fun selectJoinMode(mode: JoinMode) = _uiState.update { it.copy(joinMode = mode) }
    fun updateNotes(value: String) = _uiState.update { it.copy(notes = value) }
    fun updateCapacity(value: String) = _uiState.update { it.copy(capacityText = value.filter { it.isDigit() }.take(2)) }
    fun setOpenToAll(open: Boolean) = _uiState.update { it.copy(openToAll = open, capacityText = if (open) "50" else it.capacityText) }

    fun showLocationPicker() = _uiState.update { it.copy(showLocationPicker = true, draftLocationName = it.locationName, draftLatitude = it.latitude?.toString().orEmpty(), draftLongitude = it.longitude?.toString().orEmpty()) }
    fun dismissLocationPicker() = _uiState.update { it.copy(showLocationPicker = false) }
    fun updateLocationName(value: String) = _uiState.update { it.copy(draftLocationName = value) }
    fun updateLatitude(value: String) = _uiState.update { it.copy(draftLatitude = value) }
    fun updateLongitude(value: String) = _uiState.update { it.copy(draftLongitude = value) }

    fun updateLocationSearchQuery(query: String) {
        _uiState.update { it.copy(locationSearchQuery = query) }
        searchJob?.cancel()
        if (query.trim().length < 3) return
        searchJob = viewModelScope.launch {
            delay(400)
            val suggestions = withContext(Dispatchers.IO) {
                runCatching {
                    val geocoder = Geocoder(getApplication())
                    geocoder.getFromLocationName(query, 5)?.map { address ->
                        LocationSearchResult(address.locality ?: query, address.latitude, address.longitude, address.getAddressLine(0))
                    }
                }.getOrNull() ?: emptyList()
            }
            _uiState.update { it.copy(locationSuggestions = suggestions) }
        }
    }

    fun selectLocationSuggestion(suggestion: LocationSearchResult) = _uiState.update { it.copy(draftLocationName = suggestion.name, draftLatitude = "%.5f".format(suggestion.latitude), draftLongitude = "%.5f".format(suggestion.longitude), locationSearchQuery = "") }
    fun selectHotspot(hotspot: LocationSearchResult) = _uiState.update { it.copy(draftLocationName = hotspot.name, draftLatitude = "%.5f".format(hotspot.latitude), draftLongitude = "%.5f".format(hotspot.longitude)) }

    fun useCurrentLocation() = viewModelScope.launch {
        val loc = locationProvider.currentLocation() ?: return@launch
        _uiState.update { it.copy(draftLocationName = "Current Area", draftLatitude = "%.5f".format(loc.latitude), draftLongitude = "%.5f".format(loc.longitude)) }
    }

    fun confirmLocation() {
        val lat = _uiState.value.draftLatitude.toDoubleOrNull() ?: return
        val lng = _uiState.value.draftLongitude.toDoubleOrNull() ?: return
        _uiState.update { it.copy(showLocationPicker = false, locationName = it.draftLocationName, latitude = lat, longitude = lng) }
    }

    fun clearTransientMessages() = _uiState.update { it.copy(validationMessage = null, errorMessage = null, successMessage = null) }

    fun createDrift(onCreated: () -> Unit) {
        val state = _uiState.value
        if (state.title.isBlank()) { _uiState.update { it.copy(validationMessage = "Add a title") }; return }
        if (state.vibe == null) { _uiState.update { it.copy(validationMessage = "Pick a vibe") }; return }
        if (state.latitude == null) { _uiState.update { it.copy(validationMessage = "Pick a location") }; return }

        viewModelScope.launch {
            _uiState.update { it.copy(isCreating = true) }
            runCatching {
                store.createPost(buildPost())
            }.onSuccess {
                _uiState.update { CreateUiState(successMessage = "Created!") }
                onCreated()
            }.onFailure { e ->
                _uiState.update { it.copy(isCreating = false, errorMessage = e.localizedMessage) }
            }
        }
    }

    private suspend fun buildPost(): DriftPost {
        val state = _uiState.value
        val uid = auth.currentUser?.uid ?: ""
        val session = sessionRepository.currentState()
        val profile = uid.takeIf { it.isNotBlank() }?.let { runCatching { userRepository.getUser(it) }.getOrNull() }
        val scheduled = state.scheduledCalendar()
        return DriftPost(
            id = UUID.randomUUID().toString(),
            title = state.title.trim(),
            description = state.descriptionText,
            location = state.locationName.trim(),
            meetingPoint = "Joined users see exact details.",
            time = SimpleDateFormat("h:mm a", Locale.getDefault()).format(scheduled.time),
            date = SimpleDateFormat("MMM d, yyyy", Locale.getDefault()).format(scheduled.time),
            status = DriftStatus.Open,
            category = state.activity.category,
            hook = state.hook.trim(),
            creatorId = uid,
            creatorName = profile?.name ?: session.profileName,
            creatorImageUrl = profile?.profilePhotoUrl ?: "",
            participantCount = 1,
            capacity = state.resolvedCapacity,
            spotsLeft = state.resolvedCapacity - 1,
            vibeTags = listOfNotNull(state.vibe?.label),
            latitude = state.latitude ?: 0.0,
            longitude = state.longitude ?: 0.0,
            joinMode = state.joinMode,
            locationGeoHash = GeoHash.encode(state.latitude ?: 0.0, state.longitude ?: 0.0)
        )
    }

    companion object {
        fun factory(application: Application): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            override fun <T : ViewModel> create(modelClass: Class<T>): T = CreateDriftViewModel(application) as T
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
    val customYear: Int? = null,
    val customMonth: Int? = null,
    val customDay: Int? = null,
    val customHour: Int? = null,
    val customMinute: Int? = null,
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
    val isCreating: Boolean = false,
    val validationMessage: String? = null,
    val errorMessage: String? = null,
    val successMessage: String? = null,
    val locationSearchQuery: String = "",
    val locationSuggestions: List<LocationSearchResult> = emptyList()
) {
    val resolvedCapacity = if (openToAll) 50 else capacityText.toIntOrNull() ?: 3
    val locationSummary = if (latitude != null) "%.4f, %.4f".format(latitude, longitude) else "Current area"
    val descriptionText = "$title • $hook".trim()
    val hasUnsavedChanges = title.isNotBlank() || hook.isNotBlank() || vibe != null

    fun scheduledCalendar(): Calendar = Calendar.getInstance().apply {
        when (datePreset) {
            DatePreset.Today -> Unit
            DatePreset.Tomorrow -> add(Calendar.DAY_OF_YEAR, 1)
            DatePreset.Custom -> if (customYear != null && customMonth != null && customDay != null) {
                set(Calendar.YEAR, customYear)
                set(Calendar.MONTH, customMonth)
                set(Calendar.DAY_OF_MONTH, customDay)
            }
        }

        when (timePreset) {
            TimePreset.In30 -> add(Calendar.MINUTE, 30)
            TimePreset.In60 -> add(Calendar.HOUR_OF_DAY, 1)
            TimePreset.Custom -> if (customHour != null && customMinute != null) {
                set(Calendar.HOUR_OF_DAY, customHour)
                set(Calendar.MINUTE, customMinute)
                set(Calendar.SECOND, 0)
            }
        }
    }
}

enum class CreateActivity(val label: String, val category: DriftCategory) {
    Coffee("Coffee", DriftCategory.Coffee), Walk("Walk", DriftCategory.Walk), Food("Food", DriftCategory.Food),
    Movie("Movie", DriftCategory.Movie), Study("Study", DriftCategory.Study), Fitness("Fitness", DriftCategory.Yoga),
    Games("Games", DriftCategory.Gaming), Music("Music", DriftCategory.Music), Sports("Sports", DriftCategory.Event)
}

enum class CreateVibe(val label: String, val color: Color) {
    Casual("Casual", CoffeePeach), Chill("Chill", CoffeePeach), Friendly("Friendly", CoffeePrimary),
    Focused("Focused", CoffeePurple), Adventurous("Adventurous", CoffeePurple), Social("Social", CoffeePrimary)
}

enum class DatePreset(val label: String) { Today("Today"), Tomorrow("Tomorrow"), Custom("Pick date") }
enum class TimePreset(val label: String) { In30("In 30 mins"), In60("In 1 hour"), Custom("Pick time") }

private fun FirebaseUserRepository(): UserRepository = RepositoryProvider.userRepository

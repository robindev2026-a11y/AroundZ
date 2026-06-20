package com.coffeecall.app.feature.driftDetail

import android.app.Application
import android.content.Intent
import android.net.Uri
import android.provider.CalendarContract
import androidx.compose.foundation.BorderStroke
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
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.ui.graphics.vector.ImageVector
import com.coffeecall.app.core.design.CoffeeIcons
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import coil.compose.AsyncImage
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeDarkOverlay
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
import com.coffeecall.app.core.design.CoffeeTopAppBar
import com.coffeecall.app.core.design.CoffeeAvatar
import com.coffeecall.app.core.design.CoffeeGlassBadge
import com.coffeecall.app.core.design.CoffeeButton
import com.coffeecall.app.core.design.CoffeeButtonVariant
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.JoinRequest

@Composable
fun DriftDetailScreen(
    postId: String,
    onBack: () -> Unit,
    onNavigateToDrift: ((String) -> Unit)? = null,
    onNavigateToChat: ((String) -> Unit)? = null
) {
    val context = LocalContext.current
    val application = context.applicationContext as Application
    val viewModel: DriftDetailViewModel = viewModel(
        factory = DriftDetailViewModel.factory(application, postId)
    )
    val uiState by viewModel.uiState.collectAsState()
    var showEditDialog by remember { mutableStateOf(false) }
    var showCloseDialog by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf(false) }
    var editTitle by remember { mutableStateOf("") }
    var editDescription by remember { mutableStateOf("") }
    var editLocation by remember { mutableStateOf("") }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        if (uiState.isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = CoffeePrimary)
            }
        } else if (uiState.drift == null) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(text = "Drift not found.", color = CoffeeInk, style = MaterialTheme.typography.bodyLarge)
            }
        } else {
            val drift = uiState.drift!!

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {
                // Compact Header (matching iOS)
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .statusBarsPadding(),
                    color = CoffeeBackground
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Back button
                        Box(
                            modifier = Modifier
                                .size(CoffeeSpacing.minTouchTarget)
                                .clip(CircleShape)
                                .background(CoffeeSurface)
                                .border(1.dp, CoffeeBorder, CircleShape)
                                .clickable(onClick = onBack),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.back,
                                contentDescription = "Back",
                                tint = CoffeeInk,
                                modifier = Modifier.size(CoffeeSpacing.lg)
                            )
                        }

                        Spacer(modifier = Modifier.width(CoffeeSpacing.sm))

                        // Drift icon + title
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(categoryColor(drift.category).copy(alpha = 0.12f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = CoffeeIcons.category(drift.category.name),
                                contentDescription = null,
                                tint = categoryColor(drift.category),
                                modifier = Modifier.size(20.dp)
                            )
                        }
                        Spacer(modifier = Modifier.width(CoffeeSpacing.sm))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = drift.title.take(15) + if (drift.title.length > 15) "..." else "",
                                style = MaterialTheme.typography.titleMedium,
                                color = CoffeeInk,
                                fontWeight = FontWeight.Bold,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            Text(
                                text = categoryLabel(drift.category),
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeMuted
                            )
                        }

                        // Action icons
                        Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
                            HeaderActionIcon(icon = CoffeeIcons.send) {
                                val inviteText = "Join my CoffeeCall: ${drift.title} on ${drift.date} at ${drift.time}! Meet at ${drift.location}."
                                val sendIntent = Intent().apply {
                                    action = Intent.ACTION_SEND
                                    putExtra(Intent.EXTRA_TEXT, inviteText)
                                    type = "text/plain"
                                }
                                context.startActivity(Intent.createChooser(sendIntent, "Share Drift"))
                            }
                            HeaderActionIcon(icon = CoffeeIcons.calendar) {
                                viewModel.setReminder()
                            }
                            HeaderActionIcon(icon = CoffeeIcons.bell) {
                                // Notification action
                            }
                        }
                    }
                }

                // Status badge
                if (drift.status == com.coffeecall.app.domain.model.DriftStatus.Open) {
                    Row(
                        modifier = Modifier.padding(horizontal = CoffeeSpacing.screen)
                    ) {
                        CoffeeGlassBadge(
                            title = "OPEN",
                            icon = null,
                            containerColor = CoffeePrimary
                        )
                    }
                }

                // Title
                Text(
                    text = drift.title,
                    style = MaterialTheme.typography.headlineLarge.copy(lineHeight = 32.sp),
                    color = CoffeeInk,
                    fontWeight = FontWeight.Black,
                    modifier = Modifier.padding(horizontal = CoffeeSpacing.screen, vertical = CoffeeSpacing.sm)
                )

                // Summary Grid (matching iOS)
                DriftSummaryGrid(drift = drift, uiState = uiState)

                DriftDetailContent(
                    drift = drift,
                    uiState = uiState,
                    onAcceptRequest = viewModel::acceptJoinRequest,
                    onRejectRequest = viewModel::rejectJoinRequest,
                    onSetReminder = viewModel::setReminder,
                    onShare = {
                        val inviteText = "Join my CoffeeCall: ${drift.title} on ${drift.date} at ${drift.time}! Meet at ${drift.location}."
                        val sendIntent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_TEXT, inviteText)
                            type = "text/plain"
                        }
                        context.startActivity(Intent.createChooser(sendIntent, "Share Drift"))
                    },
                    onOpenMap = {
                        val geoUri = Uri.parse("geo:${drift.latitude},${drift.longitude}?q=${drift.latitude},${drift.longitude}(${Uri.encode(drift.meetingPoint)})")
                        val mapIntent = Intent(Intent.ACTION_VIEW, geoUri)
                        context.startActivity(mapIntent)
                    },
                    onNavigateToDrift = onNavigateToDrift,
                    onHostEdit = {
                        editTitle = drift.title
                        editDescription = drift.description
                        editLocation = drift.location
                        showEditDialog = true
                    },
                    onHostClose = { showCloseDialog = true },
                    onHostDelete = { showDeleteDialog = true },
                    onHostChat = { onNavigateToChat?.invoke(drift.id) }
                )

                Spacer(modifier = Modifier.height(140.dp))
            }

            // Floating Bottom CTA (Glassmorphism design)
            FloatingBottomCTA(
                uiState = uiState,
                onJoin = { viewModel.requestToJoin() },
                onCancelRequest = viewModel::cancelJoinRequest,
                onLeave = { viewModel.leaveDrift() },
                onMessage = { onNavigateToChat?.invoke(drift.id) }
            )
        }

        // Calendar Alerts
        if (uiState.showCalendarConfirmation) {
            AlertDialog(
                onDismissRequest = viewModel::dismissCalendarConfirmation,
                title = { Text("Add to Calendar", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("Would you like to add this CoffeeCall to your calendar?", color = CoffeeMuted) },
                confirmButton = {
                    TextButton(onClick = {
                        val drift = uiState.drift ?: return@TextButton
                        viewModel.confirmAddReminder()
                        
                        val categoryFormatted = drift.category.firestoreValue.replaceFirstChar { it.uppercase() }
                        val canSeeExactMeetingPoint = uiState.joinStatus == JoinStatus.Joined
                        val meetingPointText = if (canSeeExactMeetingPoint) {
                            drift.meetingPoint.ifBlank { "Meeting point will be coordinated in chat" }
                        } else {
                            "Exact meeting point unlocks after you join"
                        }
                        val formattedDescription = "Drift Category: $categoryFormatted\nMeeting Point: $meetingPointText\n\n${drift.description}"
                        
                        val startTime = parseDriftDateTime(drift.date, drift.time)
                        val endTime = if (drift.endTime.isNotBlank()) {
                            parseDriftDateTime(drift.date, drift.endTime)
                        } else {
                            startTime + 60 * 60 * 1000 // default 1 hour later
                        }

                        // Launch native Intent
                        val intent = Intent(Intent.ACTION_INSERT).apply {
                            data = CalendarContract.Events.CONTENT_URI
                            putExtra(CalendarContract.Events.TITLE, "CoffeeCall: ${drift.title}")
                            putExtra(CalendarContract.Events.DESCRIPTION, formattedDescription)
                            putExtra(CalendarContract.Events.EVENT_LOCATION, drift.location)
                            putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startTime)
                            putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTime)
                            putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, false)
                        }
                        context.startActivity(intent)
                    }) {
                        Text("Add", color = CoffeePrimary)
                    }
                },
                dismissButton = {
                    TextButton(onClick = viewModel::dismissCalendarConfirmation) {
                        Text("Cancel", color = CoffeeMuted)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        if (uiState.showCalendarDisclaimer) {
            AlertDialog(
                onDismissRequest = viewModel::dismissCalendarDisclaimer,
                title = { Text("Reminder Set", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("This CoffeeCall event is already in your calendar app.", color = CoffeeMuted) },
                confirmButton = {
                    TextButton(onClick = viewModel::dismissCalendarDisclaimer) {
                        Text("OK", color = CoffeePrimary)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        if (showEditDialog) {
            AlertDialog(
                onDismissRequest = { showEditDialog = false },
                title = { Text("Edit Drift", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                        OutlinedTextField(
                            value = editTitle,
                            onValueChange = { editTitle = it },
                            label = { Text("Title") },
                            singleLine = true
                        )
                        OutlinedTextField(
                            value = editDescription,
                            onValueChange = { editDescription = it },
                            label = { Text("Description") },
                            minLines = 3
                        )
                        OutlinedTextField(
                            value = editLocation,
                            onValueChange = { editLocation = it },
                            label = { Text("Approximate location") },
                            singleLine = true
                        )
                    }
                },
                confirmButton = {
                    TextButton(onClick = {
                        showEditDialog = false
                        viewModel.updateHostDrift(editTitle, editDescription, editLocation)
                    }) {
                        Text("Save", color = CoffeePrimary)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showEditDialog = false }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        if (showCloseDialog) {
            AlertDialog(
                onDismissRequest = { showCloseDialog = false },
                title = { Text("Close Drift?", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("This ends the drift for new joins while keeping the record visible.", color = CoffeeMuted) },
                confirmButton = {
                    TextButton(onClick = {
                        showCloseDialog = false
                        viewModel.closeDrift()
                    }) {
                        Text("Close", color = CoffeePeach, fontWeight = FontWeight.Bold)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showCloseDialog = false }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        if (showDeleteDialog) {
            AlertDialog(
                onDismissRequest = { showDeleteDialog = false },
                title = { Text("Delete Drift?", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("This removes the drift and its chat thread. This cannot be undone.", color = CoffeeMuted) },
                confirmButton = {
                    TextButton(onClick = {
                        showDeleteDialog = false
                        viewModel.deleteDrift()
                        onBack()
                    }) {
                        Text("Delete", color = CoffeeError, fontWeight = FontWeight.Bold)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showDeleteDialog = false }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun DriftDetailContent(
    drift: DriftPost,
    uiState: DriftDetailUiState,
    onAcceptRequest: (JoinRequest) -> Unit,
    onRejectRequest: (String) -> Unit,
    onSetReminder: () -> Unit,
    onShare: () -> Unit,
    onOpenMap: () -> Unit,
    onNavigateToDrift: ((String) -> Unit)? = null,
    onHostEdit: () -> Unit,
    onHostClose: () -> Unit,
    onHostDelete: () -> Unit,
    onHostChat: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = CoffeeSpacing.screen, vertical = CoffeeSpacing.md),
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
    ) {
        // Title
        Text(
            text = drift.title,
            style = MaterialTheme.typography.headlineLarge.copy(lineHeight = 32.sp),
            color = CoffeeInk,
            fontWeight = FontWeight.Black,
            modifier = Modifier.padding(top = CoffeeSpacing.sm)
        )

        if (drift.hook.isNotBlank()) {
            Surface(
                color = CoffeePeach.copy(alpha = 0.08f),
                shape = CoffeeShapes.medium,
                border = BorderStroke(1.dp, CoffeePeach.copy(alpha = 0.24f)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(CoffeeIcons.bolt, contentDescription = null, tint = CoffeePeach, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(CoffeeSpacing.sm))
                    Text(
                        text = drift.hook,
                        style = MaterialTheme.typography.bodyMedium.copy(lineHeight = 18.sp),
                        color = CoffeeInk,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        AboutSection(drift = drift)

        HostContextCard(drift = drift, uiState = uiState, onNavigateToDrift = onNavigateToDrift)

        ParticipantsSection(drift = drift, uiState = uiState)

        DriftDetailsListSection(drift = drift, uiState = uiState)

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Surface(
                modifier = Modifier
                    .weight(1f)
                    .clickable(onClick = onSetReminder),
                shape = CoffeeShapes.medium,
                color = CoffeeSurface,
                border = BorderStroke(1.dp, CoffeeBorder)
            ) {
                Row(
                    modifier = Modifier.padding(vertical = CoffeeSpacing.sm),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(text = if (uiState.isReminderSet) "⏰ Added" else "⏰ Add Calendar", style = MaterialTheme.typography.labelMedium, color = CoffeeInk)
                }
            }
            Surface(
                modifier = Modifier
                    .weight(1f)
                    .clickable(onClick = onShare),
                shape = CoffeeShapes.medium,
                color = CoffeeSurface,
                border = BorderStroke(1.dp, CoffeeBorder)
            ) {
                Row(
                    modifier = Modifier.padding(vertical = CoffeeSpacing.sm),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(text = "📤 Share Invite", style = MaterialTheme.typography.labelMedium, color = CoffeeInk)
                }
            }
        }

        MapSection(drift = drift, uiState = uiState, onOpenMap = onOpenMap)

        SafetyBanner()

        if (drift.creatorId == uiState.currentUserId) {
            HostManagementPanel(
                drift = drift,
                uiState = uiState,
                onEdit = onHostEdit,
                onShare = onShare,
                onClose = onHostClose,
                onDelete = onHostDelete,
                onChat = onHostChat
            )
        }

        // Pending Requests Panel (Host Actions)
        if (drift.creatorId == uiState.currentUserId && drift.pendingRequests.isNotEmpty()) {
            HostRequestsPanel(
                requests = drift.pendingRequests,
                onAccept = onAcceptRequest,
                onReject = onRejectRequest
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun AboutSection(drift: DriftPost) {
    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
        Text(
            text = "About this Drift",
            style = MaterialTheme.typography.titleMedium,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )
        if (drift.description.isNotBlank()) {
            Text(
                text = drift.description,
                style = MaterialTheme.typography.bodyMedium.copy(lineHeight = 20.sp),
                color = CoffeeMuted
            )
        }
        if (drift.vibeTags.isNotEmpty()) {
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
            ) {
                drift.vibeTags.forEach { vibe ->
                    Text(
                        text = vibe,
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeePurple,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier
                            .clip(CoffeeShapes.medium)
                            .background(CoffeePurple.copy(alpha = 0.08f))
                            .padding(horizontal = 10.dp, vertical = 6.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun HeaderActionIcon(icon: ImageVector, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .size(CoffeeSpacing.minTouchTarget)
            .clip(CircleShape)
            .background(CoffeeSurface)
            .border(1.dp, CoffeeBorder, CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = CoffeeInk.copy(alpha = 0.7f),
            modifier = Modifier.size(CoffeeSpacing.lg)
        )
    }
}

@Composable
private fun DriftSummaryGrid(
    drift: DriftPost,
    uiState: DriftDetailUiState
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = CoffeeSpacing.screen),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            SummaryGridItem(
                icon = CoffeeIcons.calendar,
                value = drift.date,
                subtitle = drift.time
            )
            SummaryGridItem(
                icon = CoffeeIcons.location,
                value = drift.location.take(12) + if (drift.location.length > 12) "..." else "",
                subtitle = drift.location.split(",").lastOrNull()?.trim() ?: ""
            )
            SummaryGridItem(
                icon = CoffeeIcons.profile,
                value = String.format("%.1f km", drift.distance),
                subtitle = "from you"
            )
            SummaryGridItem(
                icon = CoffeeIcons.people,
                value = "${drift.participantCount} joined",
                subtitle = "Open to ${drift.spotsLeft + drift.participantCount}"
            )
        }
    }
}

@Composable
private fun SummaryGridItem(
    icon: ImageVector,
    value: String,
    subtitle: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = CoffeePrimary,
            modifier = Modifier.size(20.dp)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.labelMedium,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
        Text(
            text = subtitle,
            style = MaterialTheme.typography.labelSmall,
            color = CoffeeMuted,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
private fun DriftDetailsListSection(
    drift: DriftPost,
    uiState: DriftDetailUiState
) {
    val canSeeExactMeetingPoint = uiState.joinStatus == JoinStatus.Joined
    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
        Text(
            text = "Details",
            style = MaterialTheme.typography.titleMedium,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )
        Surface(
            modifier = Modifier.fillMaxWidth(),
            shape = CoffeeShapes.large,
            color = CoffeeSurface,
            border = BorderStroke(1.dp, CoffeeBorder)
        ) {
            Column(modifier = Modifier.padding(horizontal = CoffeeSpacing.md)) {
                DetailListRow(
                    icon = CoffeeIcons.clock,
                    label = "Time",
                    value = if (drift.endTime.isNotBlank()) "${drift.time} - ${drift.endTime}" else drift.time
                )
                DetailListRow(
                    icon = if (canSeeExactMeetingPoint) CoffeeIcons.location else CoffeeIcons.lock,
                    label = "Meeting point",
                    value = if (canSeeExactMeetingPoint) {
                        drift.meetingPoint.ifBlank { "Meeting point will be coordinated in chat" }
                    } else {
                        "Join to see exact location"
                    },
                    locked = !canSeeExactMeetingPoint
                )
                DetailListRow(
                    icon = CoffeeIcons.profile,
                    label = "Bring",
                    value = drift.whatToBring.joinToString(", ").ifBlank { "Good mood" }
                )
                DetailListRow(
                    icon = CoffeeIcons.bolt,
                    label = "Vibe",
                    value = drift.vibeTags.joinToString(" • ").ifBlank { "Friendly" }
                )
                DetailListRow(
                    icon = CoffeeIcons.info,
                    label = "Notes",
                    value = drift.hook.ifBlank { "No extra notes." },
                    isLast = true
                )
            }
        }
    }
}

@Composable
private fun DetailListRow(
    icon: ImageVector,
    label: String,
    value: String,
    locked: Boolean = false,
    isLast: Boolean = false
) {
    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = CoffeeSpacing.md),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = if (locked) CoffeeMuted else CoffeePrimary,
                modifier = Modifier.size(CoffeeSpacing.lg)
            )
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelSmall,
                    color = CoffeeMuted,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    text = value,
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (locked) CoffeeMuted else CoffeeInk,
                    fontWeight = FontWeight.Bold
                )
            }
        }
        if (!isLast) {
            HorizontalDivider(color = CoffeeBorder.copy(alpha = 0.72f))
        }
    }
}

@Composable
private fun SafetyBanner() {
    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
        Surface(
            modifier = Modifier.fillMaxWidth(),
            shape = CoffeeShapes.medium,
            color = CoffeePurple.copy(alpha = 0.08f),
            border = BorderStroke(1.dp, CoffeePurple.copy(alpha = 0.18f))
        ) {
            Row(
                modifier = Modifier.padding(CoffeeSpacing.md),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                Icon(
                    imageVector = CoffeeIcons.info,
                    contentDescription = null,
                    tint = CoffeePurple,
                    modifier = Modifier.size(22.dp)
                )
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Safety first",
                        style = MaterialTheme.typography.labelLarge,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Exact meeting details stay private until you join.",
                        style = MaterialTheme.typography.bodySmall,
                        color = CoffeeMuted
                    )
                }
            }
        }
        Text(
            text = "Coordinate final details in the drift chat.",
            style = MaterialTheme.typography.labelSmall,
            color = CoffeeMuted,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )
    }
}

@Composable
private fun ParticipantsSection(
    drift: DriftPost,
    uiState: DriftDetailUiState
) {
    val canRevealParticipants = uiState.joinStatus == JoinStatus.Joined
    val initials = if (uiState.participants.isNotEmpty()) {
        uiState.participants.map { it.initials }
    } else {
        drift.participantInitials
    }

    if (drift.participantCount <= 0 && initials.isEmpty()) return

    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
        Text(
            text = "Who's Going",
            style = MaterialTheme.typography.titleMedium,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )

        if (!canRevealParticipants) {
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = CoffeeShapes.large,
                color = CoffeeSurface,
                border = BorderStroke(1.dp, CoffeeBorder)
            ) {
                Row(
                    modifier = Modifier.padding(CoffeeSpacing.md),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                ) {
                    Row(horizontalArrangement = Arrangement.spacedBy((-8).dp)) {
                        initials.take(3).forEach { initial ->
                            CoffeeAvatar(
                                name = initial,
                                size = 34.dp,
                                background = CoffeePeach,
                                ringColor = CoffeeBackground
                            )
                        }
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "${drift.participantCount} people are in",
                            style = MaterialTheme.typography.labelLarge,
                            color = CoffeeInk,
                            fontWeight = FontWeight.Black
                        )
                        Text(
                            text = "Full participant details unlock after you join.",
                            style = MaterialTheme.typography.bodySmall,
                            color = CoffeeMuted
                        )
                    }
                    Icon(
                        imageVector = CoffeeIcons.check,
                        contentDescription = null,
                        tint = CoffeeMuted,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
            return
        }

        if (uiState.participants.isNotEmpty()) {
            Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
                uiState.participants.forEach { participant ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(CoffeeShapes.medium)
                            .background(CoffeeSurface)
                            .border(1.dp, CoffeeBorder, CoffeeShapes.medium)
                            .padding(CoffeeSpacing.sm),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                    ) {
                        CoffeeAvatar(
                            name = participant.initials,
                            size = 38.dp,
                            background = CoffeePeach,
                            ringColor = CoffeeBackground
                        )
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = participant.name,
                                style = MaterialTheme.typography.labelMedium,
                                color = CoffeeInk,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = participant.interests.take(3).joinToString(", ").ifBlank { participant.joinTimeDescription },
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeMuted
                            )
                        }
                    }
                }
            }
        } else {
            Row(
                horizontalArrangement = Arrangement.spacedBy((-8).dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                initials.take(6).forEach { initial ->
                        CoffeeAvatar(
                                name = initial,
                                size = CoffeeSpacing.xxl,
                                background = CoffeePeach,
                                ringColor = CoffeeBackground
                    )
                }
                if (initials.size > 6) {
                    Box(
                        modifier = Modifier
                            .size(CoffeeSpacing.xxl)
                            .clip(CircleShape)
                            .background(CoffeeBorder)
                            .border(2.dp, CoffeeBackground, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "+${initials.size - 6}",
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeeInk
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun DetailInfoRow(icon: ImageVector, label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(CoffeeSpacing.lg),
            tint = CoffeeMuted
        )
        Spacer(modifier = Modifier.width(CoffeeSpacing.sm))
        Text(
            text = "$label: ",
            style = MaterialTheme.typography.labelMedium,
            color = CoffeeMuted,
            fontWeight = FontWeight.Medium
        )
        Text(
            text = value,
            style = MaterialTheme.typography.labelMedium,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun HostContextCard(
    drift: DriftPost,
    uiState: DriftDetailUiState,
    onNavigateToDrift: ((String) -> Unit)? = null
) {
    Surface(
        color = CoffeeSurface,
        shape = CoffeeShapes.large,
        border = BorderStroke(1.dp, CoffeeBorder),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(CoffeeSpacing.md), verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                CoffeeAvatar(
                    name = drift.creatorName,
                    imageUrl = drift.creatorImageUrl.ifBlank { null },
                    size = CoffeeSpacing.minTouchTarget,
                    background = CoffeePrimary.copy(alpha = 0.12f),
                    ringColor = null
                )
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(text = drift.creatorName, style = MaterialTheme.typography.titleMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
                        if (drift.creatorVerified) {
                            Spacer(modifier = Modifier.width(CoffeeSpacing.xxs))
                            Icon(CoffeeIcons.check, contentDescription = "Verified", tint = CoffeePrimary, modifier = Modifier.size(12.dp))
                        }
                    }
                    Text(text = "Host", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
                }
            }

            // Bio / stats
            val bioText = uiState.hostProfile?.bio ?: "Host coordinates community CoffeeCalls."
            Text(text = bioText, style = MaterialTheme.typography.bodyMedium, color = CoffeeInk.copy(alpha = 0.8f))

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(CoffeeShapes.medium)
                    .background(CoffeeBackground.copy(alpha = 0.5f))
                    .padding(vertical = CoffeeSpacing.sm, horizontal = CoffeeSpacing.md),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                HostStatItem(label = "Hosted", value = "4")
                Box(modifier = Modifier.height(CoffeeSpacing.xl).width(1.dp).background(CoffeeBorder))
                HostStatItem(label = "Joined", value = "12")
                Box(modifier = Modifier.height(CoffeeSpacing.xl).width(1.dp).background(CoffeeBorder))
                HostStatItem(label = "Completed", value = "16")
            }

            // Interests
            val interests = uiState.hostProfile?.interests ?: listOf("Walks", "Coffee", "Movies")
            if (interests.isNotEmpty()) {
                Text(text = "Interests", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted, fontWeight = FontWeight.Bold)
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs),
                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)
                ) {
                    interests.forEach { interest ->
                        Text(
                            text = interest,
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeeInk,
                            modifier = Modifier
                                .clip(CircleShape)
                                .background(CoffeeBorder.copy(alpha = 0.6f))
                                .padding(horizontal = CoffeeSpacing.xs, vertical = CoffeeSpacing.xxs)
                        )
                    }
                }
            }

            // Other Active Drifts
            if (uiState.otherActiveDrifts.isNotEmpty()) {
                HorizontalDivider(color = CoffeeBorder.copy(alpha = 0.5f), modifier = Modifier.padding(vertical = CoffeeSpacing.xxs))
                Text(text = "Other active drifts by host", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted, fontWeight = FontWeight.Bold)
                
                uiState.otherActiveDrifts.forEach { activePost ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onNavigateToDrift?.invoke(activePost.id) }
                            .padding(vertical = CoffeeSpacing.xxs),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(text = activePost.title, style = MaterialTheme.typography.labelMedium, color = CoffeeInk, fontWeight = FontWeight.Medium)
                            Text(text = "${activePost.date} • ${activePost.time}", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
                        }
                        Icon(CoffeeIcons.chevronRight, contentDescription = null, tint = CoffeePrimary, modifier = Modifier.size(20.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun HostStatItem(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = value, style = MaterialTheme.typography.titleMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
        Text(text = label, style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
    }
}

@Composable
private fun MapSection(
    drift: DriftPost,
    uiState: DriftDetailUiState,
    onOpenMap: () -> Unit
) {
    val joined = uiState.joinStatus == JoinStatus.Joined

    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
        Text(
            text = if (joined) "Location Details" else "Approximate Location",
            style = MaterialTheme.typography.titleMedium,
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1.8f)
                .clip(CoffeeShapes.large)
                .background(CoffeeSurfaceSecondary)
                .border(1.dp, CoffeeBorder, CoffeeShapes.large)
        ) {
            if (joined) {
                // Detailed Map
                DetailedMapCanvas(modifier = Modifier.fillMaxSize())
            } else {
                // Approximate Area
                ApproximateMapCanvas(modifier = Modifier.fillMaxSize())
            }
        }

        if (joined) {
            Text(
                text = drift.meetingPoint.ifBlank { "Meeting point details will be coordinated in chat." },
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeInk.copy(alpha = 0.8f)
            )
            CoffeeButton(
                title = "Open in Google Maps",
                onClick = onOpenMap,
                modifier = Modifier.fillMaxWidth().padding(top = CoffeeSpacing.xxs)
            )
        } else {
            Text(
                text = "Meeting point details and precise pins are revealed once you join this Drift.",
                style = MaterialTheme.typography.bodySmall,
                color = CoffeeMuted
            )
        }
    }
}

@Composable
private fun ApproximateMapCanvas(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val center = Offset(size.width / 2, size.height / 2)
        val maxRadius = minOf(size.width, size.height) / 2
        val stroke = Stroke(
            width = 2.dp.toPx(),
            pathEffect = PathEffect.dashPathEffect(floatArrayOf(15f, 15f), 0f)
        )

        // 3 Dashed Concentric circles
        for (i in 1..3) {
            val r = maxRadius * (i.toFloat() / 3f)
            drawCircle(
                color = CoffeePrimary.copy(alpha = 0.24f / i),
                radius = r,
                center = center,
                style = stroke
            )
        }

        // Center glow
        drawCircle(
            color = CoffeePrimary.copy(alpha = 0.12f),
            radius = maxRadius * 0.25f,
            center = center
        )
    }
}

@Composable
private fun DetailedMapCanvas(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val center = Offset(w / 2, h / 2)

        // Grid lines
        val lines = 8
        val stroke = Stroke(width = 1.dp.toPx())
        val gridColor = CoffeeBorder.copy(alpha = 0.5f)
        for (i in 1 until lines) {
            val x = w * (i.toFloat() / lines)
            drawLine(color = gridColor, start = Offset(x, 0f), end = Offset(x, h), strokeWidth = stroke.width)
            val y = h * (i.toFloat() / lines)
            drawLine(color = gridColor, start = Offset(0f, y), end = Offset(w, y), strokeWidth = stroke.width)
        }

        // Center Pin Glow
        drawCircle(
            color = CoffeePrimary.copy(alpha = 0.2f),
            radius = 16.dp.toPx(),
            center = center
        )

        // Center Pin
        drawCircle(
            color = CoffeePrimary,
            radius = 8.dp.toPx(),
            center = center
        )
        drawCircle(
            color = CoffeeTextOnBrand,
            radius = 3.dp.toPx(),
            center = center
        )
    }
}

@Composable
@OptIn(ExperimentalLayoutApi::class)
private fun HostManagementPanel(
    drift: DriftPost,
    uiState: DriftDetailUiState,
    onEdit: () -> Unit,
    onShare: () -> Unit,
    onClose: () -> Unit,
    onDelete: () -> Unit,
    onChat: () -> Unit
) {
    Surface(
        color = CoffeeSurface,
        shape = CoffeeShapes.large,
        border = BorderStroke(1.dp, CoffeePrimary.copy(alpha = 0.24f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .clip(CircleShape)
                        .background(CoffeePrimary.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = CoffeeIcons.bolt,
                        contentDescription = null,
                        tint = CoffeePrimary,
                        modifier = Modifier.size(21.dp)
                    )
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Host Management",
                        style = MaterialTheme.typography.titleMedium,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        text = "${drift.pendingRequests.size} pending requests · ${drift.participantCount} joined",
                        style = MaterialTheme.typography.bodySmall,
                        color = CoffeeMuted
                    )
                }
            }

            Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm), modifier = Modifier.fillMaxWidth()) {
                CoffeeButton(
                    title = "Edit",
                    onClick = onEdit,
                    variant = CoffeeButtonVariant.Secondary,
                    leadingIcon = CoffeeIcons.profile,
                    modifier = Modifier.weight(1f)
                )
                CoffeeButton(
                    title = "Share",
                    onClick = onShare,
                    variant = CoffeeButtonVariant.Secondary,
                    leadingIcon = CoffeeIcons.send,
                    modifier = Modifier.weight(1f)
                )
            }

            Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm), modifier = Modifier.fillMaxWidth()) {
                CoffeeButton(
                    title = "Chat",
                    onClick = onChat,
                    variant = CoffeeButtonVariant.Primary,
                    leadingIcon = CoffeeIcons.chats,
                    modifier = Modifier.weight(1f)
                )
                CoffeeButton(
                    title = "Close",
                    onClick = onClose,
                    variant = CoffeeButtonVariant.Peach,
                    leadingIcon = CoffeeIcons.close,
                    modifier = Modifier.weight(1f),
                    enabled = drift.status != com.coffeecall.app.domain.model.DriftStatus.Ended
                )
            }

            CoffeeButton(
                title = "Delete Drift",
                onClick = onDelete,
                variant = CoffeeButtonVariant.Ghost,
                leadingIcon = CoffeeIcons.close
            )

            if (uiState.participants.isNotEmpty() || drift.participantInitials.isNotEmpty()) {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(
                        text = "Joined Participants",
                        style = MaterialTheme.typography.labelMedium,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Black
                    )
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                    ) {
                        val participants = if (uiState.participants.isNotEmpty()) {
                            uiState.participants.map { it.initials }
                        } else {
                            drift.participantInitials
                        }
                        participants.forEach { initials ->
                            Surface(
                                shape = CircleShape,
                                color = CoffeeSurfaceSecondary,
                                border = BorderStroke(1.dp, CoffeeBorder)
                            ) {
                                Text(
                                    text = initials,
                                    style = MaterialTheme.typography.labelSmall,
                                    color = CoffeeInk,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                                )
                            }
                        }
                    }
                }
            }

            Surface(
                shape = CoffeeShapes.medium,
                color = CoffeePeach.copy(alpha = 0.1f),
                border = BorderStroke(1.dp, CoffeePeach.copy(alpha = 0.28f))
            ) {
                Text(
                    text = "Safety reminder: keep exact meeting details in chat and close or delete plans that are no longer active.",
                    style = MaterialTheme.typography.bodySmall,
                    color = CoffeeInk,
                    modifier = Modifier.padding(CoffeeSpacing.sm)
                )
            }
        }
    }
}

@Composable
private fun HostRequestsPanel(
    requests: List<JoinRequest>,
    onAccept: (JoinRequest) -> Unit,
    onReject: (String) -> Unit
) {
    Surface(
        color = CoffeeSurface,
        shape = CoffeeShapes.large,
        border = BorderStroke(1.dp, CoffeePeach.copy(alpha = 0.3f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(CoffeeSpacing.md), verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
            Text(
                text = "Join Requests (${requests.size})",
                style = MaterialTheme.typography.titleMedium,
                color = CoffeeInk,
                fontWeight = FontWeight.Bold
            )

            requests.forEach { request ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(CoffeeShapes.medium)
                        .background(CoffeeBackground.copy(alpha = 0.4f))
                        .padding(CoffeeSpacing.sm),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                ) {
                    CoffeeAvatar(
                        name = request.userName,
                        size = CoffeeSpacing.xxl,
                        background = CoffeePurple.copy(alpha = 0.12f),
                        ringColor = null
                    )

                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = request.userName, style = MaterialTheme.typography.labelMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
                        Text(text = request.message, style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
                    }

                    Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)) {
                        CoffeeButton(
                            title = "Reject",
                            onClick = { onReject(request.id) },
                            variant = CoffeeButtonVariant.Ghost,
                            fullWidth = false,
                            height = CoffeeSpacing.xxl
                        )
                        CoffeeButton(
                            title = "Accept",
                            onClick = { onAccept(request) },
                            variant = CoffeeButtonVariant.Primary,
                            fullWidth = false,
                            height = CoffeeSpacing.xxl
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun FloatingBottomCTA(
    uiState: DriftDetailUiState,
    onJoin: () -> Unit,
    onCancelRequest: () -> Unit,
    onLeave: () -> Unit,
    onMessage: () -> Unit
) {
    val isActionLoading = uiState.isActionLoading

    Box(
        modifier = Modifier
            .fillMaxSize()
    ) {
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.Transparent,
                            CoffeeBackground.copy(alpha = 0.94f)
                        )
                    )
                )
                .padding(bottom = CoffeeSpacing.screenBottomSpacer)
                .padding(horizontal = CoffeeSpacing.screen)
        ) {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(16.dp, CoffeeShapes.large, spotColor = CoffeeDarkOverlay.copy(alpha = 0.12f))
                    .clip(CoffeeShapes.large)
                    .border(1.dp, CoffeeBorder.copy(alpha = 0.72f), CoffeeShapes.large),
                color = CoffeeSurface.copy(alpha = 0.92f)
            ) {
                Row(
                    modifier = Modifier.padding(CoffeeSpacing.md),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (isActionLoading) {
                        Box(modifier = Modifier.fillMaxWidth().height(48.dp), contentAlignment = Alignment.Center) {
                            CircularProgressIndicator(color = CoffeePrimary, modifier = Modifier.size(CoffeeSpacing.xl))
                        }
                    } else {
                        when (uiState.joinStatus) {
                            JoinStatus.Joined -> {
                                val isMine = uiState.drift?.creatorId == uiState.currentUserId
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    CoffeeButton(
                                        title = "Open Chat",
                                        onClick = onMessage,
                                        variant = CoffeeButtonVariant.Primary,
                                        leadingIcon = CoffeeIcons.chats,
                                        modifier = Modifier.weight(1f)
                                    )

                                    if (!isMine) {
                                        CoffeeButton(
                                            title = "Leave",
                                            onClick = onLeave,
                                            variant = CoffeeButtonVariant.Secondary,
                                            fullWidth = false
                                        )
                                    } else {
                                        Surface(
                                            shape = CoffeeShapes.medium,
                                            color = CoffeeSurfaceSecondary,
                                            border = BorderStroke(1.dp, CoffeeBorder),
                                            modifier = Modifier.height(48.dp)
                                        ) {
                                            Box(
                                                modifier = Modifier.padding(horizontal = CoffeeSpacing.md),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Text("Host", color = CoffeeInk, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.labelLarge)
                                            }
                                        }
                                    }
                                }
                            }
                            JoinStatus.Requested -> {
                                CoffeeButton(
                                    title = "Cancel Join Request",
                                    onClick = onCancelRequest,
                                    variant = CoffeeButtonVariant.Secondary
                                )
                            }
                            JoinStatus.Full -> {
                                CoffeeButton(
                                    title = "Drift Full",
                                    onClick = {},
                                    enabled = false
                                )
                            }
                            JoinStatus.Ended -> {
                                CoffeeButton(
                                    title = "Drift Ended",
                                    onClick = {},
                                    enabled = false
                                )
                            }
                            JoinStatus.NotJoined -> {
                                val title = if (uiState.drift?.joinMode == JoinMode.Open) "Join Drift" else "Request to Join"
                                CoffeeButton(
                                    title = title,
                                    onClick = onJoin,
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// Helpers
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

private fun categoryLabel(cat: DriftCategory): String = cat.firestoreValue



private fun parseDriftDateTime(dateStr: String, timeStr: String): Long {
    val calendar = java.util.Calendar.getInstance()
    val dateLower = dateStr.trim().lowercase()

    if (dateLower == "today") {
        // Keep today
    } else if (dateLower == "tomorrow") {
        calendar.add(java.util.Calendar.DAY_OF_YEAR, 1)
    } else {
        val sdf = java.text.SimpleDateFormat("MMM d, yyyy", java.util.Locale.getDefault())
        try {
            val date = sdf.parse(dateStr)
            if (date != null) {
                val parsedCal = java.util.Calendar.getInstance().apply { time = date }
                calendar.set(java.util.Calendar.YEAR, parsedCal.get(java.util.Calendar.YEAR))
                calendar.set(java.util.Calendar.MONTH, parsedCal.get(java.util.Calendar.MONTH))
                calendar.set(java.util.Calendar.DAY_OF_MONTH, parsedCal.get(java.util.Calendar.DAY_OF_MONTH))
            }
        } catch (e: Exception) {
            val weekdays = listOf("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
            val dayIndex = weekdays.indexOf(dateLower)
            if (dayIndex != -1) {
                val targetDayOfWeek = dayIndex + 1
                val currentDayOfWeek = calendar.get(java.util.Calendar.DAY_OF_WEEK)
                var daysDiff = targetDayOfWeek - currentDayOfWeek
                if (daysDiff <= 0) {
                    daysDiff += 7
                }
                calendar.add(java.util.Calendar.DAY_OF_YEAR, daysDiff)
            }
        }
    }

    val sdfTime = java.text.SimpleDateFormat("h:mm a", java.util.Locale.getDefault())
    try {
        val timeDate = sdfTime.parse(timeStr)
        if (timeDate != null) {
            val parsedTimeCal = java.util.Calendar.getInstance().apply { time = timeDate }
            calendar.set(java.util.Calendar.HOUR_OF_DAY, parsedTimeCal.get(java.util.Calendar.HOUR_OF_DAY))
            calendar.set(java.util.Calendar.MINUTE, parsedTimeCal.get(java.util.Calendar.MINUTE))
            calendar.set(java.util.Calendar.SECOND, 0)
            calendar.set(java.util.Calendar.MILLISECOND, 0)
        }
    } catch (e: Exception) {
        // Fallback default hour
    }

    return calendar.timeInMillis
}

@Composable
private fun DetailCard(
    icon: ImageVector,
    iconColor: Color,
    title: String,
    value: String,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .shadow(elevation = 2.dp, shape = RoundedCornerShape(16.dp))
            .border(1.dp, CoffeeBorder, RoundedCornerShape(16.dp)),
        color = Color.White
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(iconColor.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = iconColor,
                    modifier = Modifier.size(CoffeeSpacing.md)
                )
            }
            Text(
                text = title,
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeMuted,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = value,
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeInk,
                fontWeight = FontWeight.Black,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

private fun categoryHeroUrl(cat: DriftCategory): String =
    when (cat) {
        DriftCategory.Coffee -> "https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Walk -> "https://images.unsplash.com/photo-1470240731273-7821a6eeb6bd?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Movie -> "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Food -> "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Study -> "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Gaming -> "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Music -> "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Yoga -> "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800"
        DriftCategory.Event -> "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&q=80&w=800"
    }

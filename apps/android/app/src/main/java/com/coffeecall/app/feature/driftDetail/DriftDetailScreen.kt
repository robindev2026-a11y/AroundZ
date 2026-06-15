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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
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
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
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
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.JoinRequest

@Composable
fun DriftDetailScreen(
    postId: String,
    onBack: () -> Unit,
    onNavigateToDrift: ((String) -> Unit)? = null
) {
    val context = LocalContext.current
    val application = context.applicationContext as Application
    val viewModel: DriftDetailViewModel = viewModel(
        factory = DriftDetailViewModel.factory(application, postId)
    )
    val uiState by viewModel.uiState.collectAsState()

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
                // Top App Bar Spacer & Header
                Spacer(modifier = Modifier.height(56.dp))

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
                    onNavigateToDrift = onNavigateToDrift
                )

                Spacer(modifier = Modifier.height(140.dp)) // Padding for bottom floating bar
            }

            // Top Bar
            Surface(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth(),
                color = CoffeeBackground.copy(alpha = 0.94f),
                shadowElevation = 0.dp
            ) {
                CoffeeTopAppBar(
                    title = "Drift Details",
                    subtitle = "Hosted by ${drift.creatorName}",
                    actionLabel = "Back",
                    onAction = onBack,
                    modifier = Modifier.padding(top = CoffeeSpacing.xs)
                )
            }

            // Floating Bottom CTA (Glassmorphism design)
            FloatingBottomCTA(
                uiState = uiState,
                onJoin = { viewModel.requestToJoin() },
                onCancelRequest = viewModel::cancelJoinRequest,
                onLeave = { viewModel.leaveDrift() }
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
                        val formattedDescription = "Drift Category: $categoryFormatted\nMeeting Point: ${drift.meetingPoint.ifBlank { "Approximate location shared until joined" }}\n\n${drift.description}"
                        
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
    onNavigateToDrift: ((String) -> Unit)? = null
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = CoffeeSpacing.screen, vertical = CoffeeSpacing.md),
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
    ) {
        // Category representation & Status
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
        ) {
            val color = categoryColor(drift.category)
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(color.copy(alpha = 0.16f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = categorySymbol(drift.category),
                    style = MaterialTheme.typography.labelLarge,
                    color = color
                )
            }
            Text(
                text = categoryLabel(drift.category).uppercase(),
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeMuted,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.weight(1f))
            CoffeePillBadge(
                title = drift.status.firestoreValue,
                containerColor = CoffeePrimary.copy(alpha = 0.12f),
                contentColor = CoffeePrimaryDark
            )
        }

        // Title
        Text(
            text = drift.title,
            style = MaterialTheme.typography.headlineLarge.copy(lineHeight = 32.sp),
            color = CoffeeInk,
            fontWeight = FontWeight.Bold
        )

        // Hook (if present)
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
                    Text(text = "🔥", style = MaterialTheme.typography.titleMedium)
                    Spacer(modifier = Modifier.width(CoffeeSpacing.sm))
                    Text(
                        text = drift.hook,
                        style = MaterialTheme.typography.bodyMedium.copy(lineHeight = 18.sp),
                        color = CoffeeInk,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }

        // Time / Location Details
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(CoffeeShapes.large)
                .background(CoffeeSurface)
                .border(1.dp, CoffeeBorder, CoffeeShapes.large)
                .padding(CoffeeSpacing.md),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            DetailInfoRow(symbol = "📅", label = "Date", value = drift.date)
            DetailInfoRow(symbol = "🕒", label = "Time", value = "${drift.time} - ${drift.endTime}")
            DetailInfoRow(symbol = "📍", label = "Area", value = drift.location)

            // Meeting point details only visible to joined participants/hosts
            if (uiState.joinStatus == JoinStatus.Joined) {
                HorizontalDivider(color = CoffeeBorder.copy(alpha = 0.5f), modifier = Modifier.padding(vertical = 4.dp))
                DetailInfoRow(
                    symbol = "🔑",
                    label = "Meeting Point",
                    value = drift.meetingPoint.ifBlank { "To be decided" }
                )
            }
        }

        // Spots Left Indicator
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            val progress = if (drift.capacity > 0) drift.participantCount.toFloat() / drift.capacity else 0f
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row {
                    Text(text = "Spots Left", style = MaterialTheme.typography.labelLarge, color = CoffeeInk)
                    Spacer(modifier = Modifier.weight(1f))
                    Text(
                        text = "${drift.spotsLeft} of ${drift.capacity} slots remaining",
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeeMuted
                    )
                }
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp)
                        .clip(CircleShape)
                        .background(CoffeeBorder.copy(alpha = 0.5f))
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(progress.coerceIn(0f, 1f))
                            .height(8.dp)
                            .clip(CircleShape)
                            .background(CoffeePrimary)
                    )
                }
            }
        }

        // Description
        if (drift.description.isNotBlank()) {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(text = "About this Drift", style = MaterialTheme.typography.titleMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
                Text(
                    text = drift.description,
                    style = MaterialTheme.typography.bodyLarge.copy(lineHeight = 22.sp),
                    color = CoffeeInk.copy(alpha = 0.86f)
                )
            }
        }

        // Vibe Tags
        if (drift.vibeTags.isNotEmpty()) {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(text = "Drift Vibes", style = MaterialTheme.typography.titleSmall, color = CoffeeInk, fontWeight = FontWeight.Bold)
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                ) {
                    drift.vibeTags.forEach { vibe ->
                        Text(
                            text = "#$vibe",
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeePurple,
                            modifier = Modifier
                                .clip(CircleShape)
                                .background(CoffeePurple.copy(alpha = 0.08f))
                                .border(1.dp, CoffeePurple.copy(alpha = 0.16f), CircleShape)
                                .padding(horizontal = 10.dp, vertical = 5.dp)
                        )
                    }
                }
            }
        }

        // Share & Remind Tools Row
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

        // Participants Initials row
        if (uiState.participants.isNotEmpty() || drift.participantInitials.isNotEmpty()) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(text = "Who's Going", style = MaterialTheme.typography.titleMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
                Row(
                    horizontalArrangement = Arrangement.spacedBy((-8).dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val initialsToDisplay = if (uiState.participants.isNotEmpty()) {
                        uiState.participants.map { it.initials }
                    } else {
                        drift.participantInitials
                    }

                    initialsToDisplay.take(5).forEach { initials ->
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(CoffeePeach)
                                .border(2.dp, CoffeeBackground, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = initials,
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeTextOnBrand,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                    if (initialsToDisplay.size > 5) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(CoffeeBorder)
                                .border(2.dp, CoffeeBackground, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "+${initialsToDisplay.size - 5}",
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeInk
                            )
                        }
                    }
                }
            }
        }

        // Host Context Card
        HostContextCard(drift = drift, uiState = uiState, onNavigateToDrift = onNavigateToDrift)

        // Maps Integration Section
        MapSection(drift = drift, uiState = uiState, onOpenMap = onOpenMap)

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

@Composable
private fun DetailInfoRow(symbol: String, label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = symbol, style = MaterialTheme.typography.titleMedium)
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
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(CoffeePrimary.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = drift.creatorName.take(1).uppercase(),
                        style = MaterialTheme.typography.titleMedium,
                        color = CoffeePrimary,
                        fontWeight = FontWeight.Bold
                    )
                }
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(text = drift.creatorName, style = MaterialTheme.typography.titleMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
                        if (drift.creatorVerified) {
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "✓", color = CoffeePrimary, fontWeight = FontWeight.Bold, fontSize = 12.sp)
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
                Box(modifier = Modifier.height(24.dp).width(1.dp).background(CoffeeBorder))
                HostStatItem(label = "Joined", value = "12")
                Box(modifier = Modifier.height(24.dp).width(1.dp).background(CoffeeBorder))
                HostStatItem(label = "Completed", value = "16")
            }

            // Interests
            val interests = uiState.hostProfile?.interests ?: listOf("Walks", "Coffee", "Movies")
            if (interests.isNotEmpty()) {
                Text(text = "Interests", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted, fontWeight = FontWeight.Bold)
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    interests.forEach { interest ->
                        Text(
                            text = interest,
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeeInk,
                            modifier = Modifier
                                .clip(CircleShape)
                                .background(CoffeeBorder.copy(alpha = 0.6f))
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        )
                    }
                }
            }

            // Other Active Drifts
            if (uiState.otherActiveDrifts.isNotEmpty()) {
                HorizontalDivider(color = CoffeeBorder.copy(alpha = 0.5f), modifier = Modifier.padding(vertical = 4.dp))
                Text(text = "Other active drifts by host", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted, fontWeight = FontWeight.Bold)
                
                uiState.otherActiveDrifts.forEach { activePost ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onNavigateToDrift?.invoke(activePost.id) }
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(text = activePost.title, style = MaterialTheme.typography.labelMedium, color = CoffeeInk, fontWeight = FontWeight.Medium)
                            Text(text = "${activePost.date} • ${activePost.time}", style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
                        }
                        Text(text = "→", color = CoffeePrimary, style = MaterialTheme.typography.titleMedium)
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

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
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
            CoffeePrimaryButton(
                title = "Open in Google Maps",
                onClick = onOpenMap,
                modifier = Modifier.fillMaxWidth().padding(top = 4.dp)
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
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(CoffeePurple.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = request.userInitials,
                            style = MaterialTheme.typography.labelSmall,
                            color = CoffeePurple,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = request.userName, style = MaterialTheme.typography.labelMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
                        Text(text = request.message, style = MaterialTheme.typography.labelSmall, color = CoffeeMuted)
                    }

                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        TextButton(
                            onClick = { onReject(request.id) },
                            colors = ButtonDefaults.textButtonColors(contentColor = CoffeeError)
                        ) {
                            Text("Reject", style = MaterialTheme.typography.labelSmall)
                        }
                        Button(
                            onClick = { onAccept(request) },
                            colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                            shape = CoffeeShapes.small
                        ) {
                            Text("Accept", style = MaterialTheme.typography.labelSmall, color = CoffeeTextOnBrand)
                        }
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
    onLeave: () -> Unit
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
                            CircularProgressIndicator(color = CoffeePrimary, modifier = Modifier.size(24.dp))
                        }
                    } else {
                        when (uiState.joinStatus) {
                            JoinStatus.Joined -> {
                                val isMine = uiState.drift?.creatorId == uiState.currentUserId
                                if (isMine) {
                                    Button(
                                        onClick = {},
                                        enabled = false,
                                        modifier = Modifier.fillMaxWidth().height(48.dp),
                                        colors = ButtonDefaults.buttonColors(disabledContainerColor = CoffeePrimary.copy(alpha = 0.5f)),
                                        shape = CoffeeShapes.medium
                                    ) {
                                        Text("You are the Host", color = CoffeeTextOnBrand)
                                    }
                                } else {
                                    Button(
                                        onClick = onLeave,
                                        modifier = Modifier.fillMaxWidth().height(48.dp),
                                        colors = ButtonDefaults.buttonColors(containerColor = CoffeeError),
                                        shape = CoffeeShapes.medium
                                    ) {
                                        Text("Leave Drift", color = CoffeeTextOnBrand)
                                    }
                                }
                            }
                            JoinStatus.Requested -> {
                                Button(
                                    onClick = onCancelRequest,
                                    modifier = Modifier.fillMaxWidth().height(48.dp),
                                    colors = ButtonDefaults.buttonColors(containerColor = CoffeeMuted),
                                    shape = CoffeeShapes.medium
                                ) {
                                    Text("Cancel Join Request", color = CoffeeTextOnBrand)
                                }
                            }
                            JoinStatus.Full -> {
                                Button(
                                    onClick = {},
                                    enabled = false,
                                    modifier = Modifier.fillMaxWidth().height(48.dp),
                                    shape = CoffeeShapes.medium
                                ) {
                                    Text("Drift Full", color = CoffeeTextOnBrand)
                                }
                            }
                            JoinStatus.Ended -> {
                                Button(
                                    onClick = {},
                                    enabled = false,
                                    modifier = Modifier.fillMaxWidth().height(48.dp),
                                    shape = CoffeeShapes.medium
                                ) {
                                    Text("Drift Ended", color = CoffeeTextOnBrand)
                                }
                            }
                            JoinStatus.NotJoined -> {
                                val title = if (uiState.drift?.joinMode == JoinMode.Open) "Join Drift" else "Request to Join"
                                CoffeePrimaryButton(
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

@Composable
fun CoffeePrimaryButton(
    title: String,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier
            .fillMaxWidth()
            .height(48.dp)
            .shadow(
                elevation = if (enabled) 12.dp else 0.dp,
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
        )
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

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

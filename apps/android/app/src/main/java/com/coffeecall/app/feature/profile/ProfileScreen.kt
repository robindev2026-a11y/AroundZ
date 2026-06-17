package com.coffeecall.app.feature.profile

import android.app.Application
import android.content.Context
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.coffeecall.app.core.design.CoffeeAvatar
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeButton
import com.coffeecall.app.core.design.CoffeeButtonVariant
import com.coffeecall.app.core.design.CoffeeDriftCard
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePrimary
import com.coffeecall.app.core.design.CoffeeShapes
import com.coffeecall.app.core.design.CoffeeSpacing
import com.coffeecall.app.core.design.CoffeeSurface
import com.coffeecall.app.core.design.CoffeeSurfaceSecondary
import com.coffeecall.app.core.design.CoffeeTextOnBrand
import com.coffeecall.app.core.design.categoryAccent
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.UserProfile
import kotlin.math.min

private enum class ProfileSheet {
    HostedStats,
    JoinedStats,
    NoShowsStats,
    ScoreStats,
    Interests,
    Availability,
    Notifications,
    Privacy,
    Location,
    Help
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    onDriftClick: (String) -> Unit = {},
    onSignOut: () -> Unit = {},
    onEditClick: () -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as Application
    val viewModel: ProfileViewModel = viewModel(
        factory = ProfileViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()
    val settingsPrefs = remember {
        application.getSharedPreferences("CoffeeCall.profile_settings", Context.MODE_PRIVATE)
    }

    var activeSheet by remember { mutableStateOf<ProfileSheet?>(null) }
    var notifyMeetups by remember { mutableStateOf(settingsPrefs.getBoolean("notify_meetups", true)) }
    var notifyChat by remember { mutableStateOf(settingsPrefs.getBoolean("notify_chat", true)) }
    var notifySafety by remember { mutableStateOf(settingsPrefs.getBoolean("notify_safety", true)) }
    var approximateLocationOnly by remember { mutableStateOf(settingsPrefs.getBoolean("privacy_approx_location", true)) }
    var requireApproval by remember { mutableStateOf(settingsPrefs.getBoolean("privacy_require_approval", true)) }
    var safetyReminders by remember { mutableStateOf(settingsPrefs.getBoolean("privacy_safety_reminders", true)) }

    LaunchedEffect(Unit) {
        viewModel.loadProfile()
    }

    val user = uiState.user
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        if (uiState.isLoading && user == null) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = CoffeePrimary)
            }
        } else if (user != null) {
            val noShows = 0
            val score = min(100, 82 + uiState.driftsHosted + uiState.driftsJoined)
            val savedDrifts = uiState.historyDrifts.take(6)
            val activityDrifts = uiState.historyDrifts.take(8)

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = CoffeeSpacing.screen)
                    .padding(top = 104.dp, bottom = CoffeeSpacing.screenBottomSpacer),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
            ) {
                IdentityCard(user = user, onEditClick = onEditClick)

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                ) {
                    ProfileStatTile(
                        value = uiState.driftsHosted.toString(),
                        label = "Hosted",
                        onClick = { activeSheet = ProfileSheet.HostedStats },
                        modifier = Modifier.weight(1f)
                    )
                    ProfileStatTile(
                        value = uiState.driftsJoined.toString(),
                        label = "Joined",
                        onClick = { activeSheet = ProfileSheet.JoinedStats },
                        modifier = Modifier.weight(1f)
                    )
                    ProfileStatTile(
                        value = noShows.toString(),
                        label = "No-shows",
                        onClick = { activeSheet = ProfileSheet.NoShowsStats },
                        modifier = Modifier.weight(1f)
                    )
                    ProfileStatTile(
                        value = score.toString(),
                        label = "Score",
                        onClick = { activeSheet = ProfileSheet.ScoreStats },
                        modifier = Modifier.weight(1f)
                    )
                }

                ProfileSectionHeader(title = "Saved Drifts", subtitle = "Bookmarked and recent plans")
                DriftShelf(
                    drifts = savedDrifts,
                    empty = "Saved drifts will appear here.",
                    onDriftClick = onDriftClick
                )

                ProfileSectionHeader(title = "Activity Log", subtitle = "Hosted and joined history")
                ActivityLog(
                    drifts = activityDrifts,
                    empty = "Your CoffeeCall activity will build up here.",
                    onDriftClick = onDriftClick
                )

                ProfileSectionHeader(title = "Preferences", subtitle = "Tune how CoffeeCall fits your week")
                SettingsGroup {
                    SettingsRow(
                        title = "Interests",
                        subtitle = user.interests.ifEmpty { listOf("Not set") }.joinToString(", ") { it.toDisplayLabel() },
                        icon = CoffeeIcons.heart,
                        onClick = { activeSheet = ProfileSheet.Interests }
                    )
                    SettingsRow(
                        title = "Availability",
                        subtitle = user.availabilitySummary(),
                        icon = CoffeeIcons.calendar,
                        onClick = { activeSheet = ProfileSheet.Availability }
                    )
                    SettingsRow(
                        title = "Notifications",
                        subtitle = "Meetups, chats, and safety",
                        icon = CoffeeIcons.bell,
                        onClick = { activeSheet = ProfileSheet.Notifications }
                    )
                    SettingsRow(
                        title = "Privacy & Safety",
                        subtitle = "Location, approvals, reminders",
                        icon = CoffeeIcons.check,
                        onClick = { activeSheet = ProfileSheet.Privacy }
                    )
                }

                ProfileSectionHeader(title = "Account", subtitle = "Location, support, and session")
                SettingsGroup {
                    SettingsRow(
                        title = "Location",
                        subtitle = user.location.ifBlank { "Set approximate area" },
                        icon = CoffeeIcons.location,
                        onClick = { activeSheet = ProfileSheet.Location }
                    )
                    SettingsRow(
                        title = "Help",
                        subtitle = "Safety, hosting, and account help",
                        icon = CoffeeIcons.bolt,
                        onClick = { activeSheet = ProfileSheet.Help }
                    )
                    SettingsRow(
                        title = "Sign out",
                        subtitle = "Leave this device signed out",
                        icon = CoffeeIcons.profile,
                        onClick = { viewModel.signOut(onSignOut) }
                    )
                }
            }

            activeSheet?.let { sheet ->
                ProfileSheetContent(
                    sheet = sheet,
                    user = user,
                    hosted = uiState.driftsHosted,
                    joined = uiState.driftsJoined,
                    noShows = noShows,
                    score = score,
                    notifyMeetups = notifyMeetups,
                    notifyChat = notifyChat,
                    notifySafety = notifySafety,
                    approximateLocationOnly = approximateLocationOnly,
                    requireApproval = requireApproval,
                    safetyReminders = safetyReminders,
                    onDismiss = { activeSheet = null },
                    onUpdateProfile = { interests, weekday, weekend, daytime, location ->
                        viewModel.updateProfile(
                            name = user.name,
                            bio = user.bio,
                            location = location,
                            availabilityWeekdayEvenings = weekday,
                            availabilityWeekends = weekend,
                            availabilityDaytime = daytime,
                            interests = interests,
                            photoUri = null,
                            removePhoto = false
                        )
                    },
                    onResolveLocation = {
                        viewModel.fetchLocationAndAddress { resolved ->
                            viewModel.updateProfile(
                                name = user.name,
                                bio = user.bio,
                                location = resolved,
                                availabilityWeekdayEvenings = user.availabilityWeekdayEvenings,
                                availabilityWeekends = user.availabilityWeekends,
                                availabilityDaytime = user.availabilityDaytime,
                                interests = user.interests,
                                photoUri = null,
                                removePhoto = false
                            )
                        }
                    },
                    onPreferenceToggle = { key, value ->
                        settingsPrefs.edit().putBoolean(key, value).apply()
                        when (key) {
                            "notify_meetups" -> notifyMeetups = value
                            "notify_chat" -> notifyChat = value
                            "notify_safety" -> notifySafety = value
                            "privacy_approx_location" -> approximateLocationOnly = value
                            "privacy_require_approval" -> requireApproval = value
                            "privacy_safety_reminders" -> safetyReminders = value
                        }
                    }
                )
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun IdentityCard(
    user: UserProfile,
    onEditClick: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.hero,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder),
        shadowElevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            CoffeeAvatar(
                name = user.name.ifBlank { "User" },
                imageUrl = user.profilePhotoUrl.ifBlank { null },
                size = 112.dp,
                background = CoffeeSurfaceSecondary,
                ringColor = CoffeePrimary
            )
            Text(
                text = user.name.ifBlank { "User" },
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeInk,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = user.location.ifBlank { "Approximate location not set" },
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Surface(
                shape = CircleShape,
                color = CoffeePrimary.copy(alpha = 0.12f),
                border = BorderStroke(1.dp, CoffeePrimary.copy(alpha = 0.26f))
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = CoffeeSpacing.sm, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        imageVector = CoffeeIcons.check,
                        contentDescription = null,
                        tint = CoffeePrimary,
                        modifier = Modifier.size(14.dp)
                    )
                    Text(
                        text = "Verified phone",
                        style = MaterialTheme.typography.labelMedium,
                        color = CoffeePrimary,
                        fontWeight = FontWeight.Black
                    )
                }
            }
            if (user.bio.isNotBlank()) {
                Text(
                    text = user.bio,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeInk.copy(alpha = 0.72f),
                    textAlign = TextAlign.Center
                )
            }
            if (user.interests.isNotEmpty()) {
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                ) {
                    user.interests.forEach { interest ->
                        InterestChip(interest = interest, selected = false, onClick = {})
                    }
                }
            }
            CoffeeButton(
                title = "Edit Profile",
                onClick = onEditClick,
                variant = CoffeeButtonVariant.Secondary,
                fullWidth = false,
                leadingIcon = CoffeeIcons.profile
            )
        }
    }
}

@Composable
private fun ProfileStatTile(
    value: String,
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = onClick,
        modifier = modifier.height(92.dp),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Column(
            modifier = Modifier.padding(horizontal = CoffeeSpacing.xs),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(text = value, fontSize = 24.sp, fontWeight = FontWeight.Black, color = CoffeeInk)
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeMuted,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun ProfileSectionHeader(title: String, subtitle: String) {
    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
        Text(text = title, style = MaterialTheme.typography.titleLarge, color = CoffeeInk, fontWeight = FontWeight.Black)
        Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
    }
}

@Composable
private fun DriftShelf(
    drifts: List<DriftPost>,
    empty: String,
    onDriftClick: (String) -> Unit
) {
    if (drifts.isEmpty()) {
        EmptyProfilePanel(empty)
    } else {
        LazyRow(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)) {
            items(drifts, key = { it.id }) { drift ->
                Box(modifier = Modifier.width(292.dp)) {
                    HistoryDriftCard(drift = drift, onDriftClick = onDriftClick)
                }
            }
        }
    }
}

@Composable
private fun ActivityLog(
    drifts: List<DriftPost>,
    empty: String,
    onDriftClick: (String) -> Unit
) {
    if (drifts.isEmpty()) {
        EmptyProfilePanel(empty)
    } else {
        Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
            drifts.forEach { drift ->
                ActivityLogRow(drift = drift, onClick = { onDriftClick(drift.id) })
            }
        }
    }
}

@Composable
private fun ActivityLogRow(drift: DriftPost, onClick: () -> Unit) {
    Surface(
        onClick = onClick,
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
            Box(
                modifier = Modifier
                    .size(42.dp)
                    .clip(CircleShape)
                    .background(categoryAccent(drift.category.firestoreValue).copy(alpha = 0.14f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.category(drift.category.firestoreValue),
                    contentDescription = null,
                    tint = categoryAccent(drift.category.firestoreValue),
                    modifier = Modifier.size(21.dp)
                )
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = drift.title.ifBlank { drift.hook.ifBlank { drift.category.firestoreValue.toDisplayLabel() } },
                    style = MaterialTheme.typography.labelLarge,
                    color = CoffeeInk,
                    fontWeight = FontWeight.Black,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = listOf(drift.date, drift.location).filter { it.isNotBlank() }.joinToString(" · "),
                    style = MaterialTheme.typography.bodySmall,
                    color = CoffeeMuted,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
            Icon(
                imageVector = CoffeeIcons.chevronRight,
                contentDescription = null,
                tint = CoffeeMuted,
                modifier = Modifier.size(18.dp)
            )
        }
    }
}

@Composable
private fun EmptyProfilePanel(message: String) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurfaceSecondary,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.7f))
    ) {
        Text(
            text = message,
            modifier = Modifier.padding(CoffeeSpacing.lg),
            style = MaterialTheme.typography.bodyMedium,
            color = CoffeeMuted,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun SettingsGroup(content: @Composable ColumnScope.() -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder)
    ) {
        Column(modifier = Modifier.padding(vertical = CoffeeSpacing.xs), content = content)
    }
}

@Composable
private fun SettingsRow(
    title: String,
    subtitle: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(CoffeePrimary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = CoffeePrimary, modifier = Modifier.size(20.dp))
        }
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, style = MaterialTheme.typography.labelLarge, color = CoffeeInk, fontWeight = FontWeight.Black)
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = CoffeeMuted,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
        Icon(
            imageVector = CoffeeIcons.chevronRight,
            contentDescription = null,
            tint = CoffeeMuted,
            modifier = Modifier.size(18.dp)
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
private fun ProfileSheetContent(
    sheet: ProfileSheet,
    user: UserProfile,
    hosted: Int,
    joined: Int,
    noShows: Int,
    score: Int,
    notifyMeetups: Boolean,
    notifyChat: Boolean,
    notifySafety: Boolean,
    approximateLocationOnly: Boolean,
    requireApproval: Boolean,
    safetyReminders: Boolean,
    onDismiss: () -> Unit,
    onUpdateProfile: (List<String>, Boolean, Boolean, Boolean, String) -> Unit,
    onResolveLocation: () -> Unit,
    onPreferenceToggle: (String, Boolean) -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(),
        containerColor = CoffeeBackground,
        contentColor = CoffeeInk,
        shape = CoffeeShapes.xlarge
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(horizontal = CoffeeSpacing.screen)
                .padding(bottom = CoffeeSpacing.lg),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            when (sheet) {
                ProfileSheet.HostedStats -> StatDetailSheet("Hosted", hosted.toString(), "Drifts you created and opened for others nearby.")
                ProfileSheet.JoinedStats -> StatDetailSheet("Joined", joined.toString(), "Drifts you joined as a guest or participant.")
                ProfileSheet.NoShowsStats -> StatDetailSheet("No-shows", noShows.toString(), "Keep this low by leaving plans early if you cannot make it.")
                ProfileSheet.ScoreStats -> StatDetailSheet("CoffeeCall score", score.toString(), "A private reliability signal based on hosting, joining, and showing up.")
                ProfileSheet.Interests -> InterestsSheet(user = user, onUpdateProfile = onUpdateProfile)
                ProfileSheet.Availability -> AvailabilitySheet(user = user, onUpdateProfile = onUpdateProfile)
                ProfileSheet.Notifications -> {
                    SheetTitle("Notifications", "Choose what CoffeeCall can nudge you about.")
                    ToggleRow("Meetup updates", "Requests, approvals, and changes", notifyMeetups) {
                        onPreferenceToggle("notify_meetups", it)
                    }
                    ToggleRow("Chat messages", "New messages from active drifts", notifyChat) {
                        onPreferenceToggle("notify_chat", it)
                    }
                    ToggleRow("Safety reminders", "Meeting and coordination prompts", notifySafety) {
                        onPreferenceToggle("notify_safety", it)
                    }
                }
                ProfileSheet.Privacy -> {
                    SheetTitle("Privacy & Safety", "Control what is shared before someone joins.")
                    ToggleRow("Approximate location only", "Keep exact meeting points locked before join", approximateLocationOnly) {
                        onPreferenceToggle("privacy_approx_location", it)
                    }
                    ToggleRow("Request approval by default", "Review people before they join hosted drifts", requireApproval) {
                        onPreferenceToggle("privacy_require_approval", it)
                    }
                    ToggleRow("Show safety reminders", "Keep safety notes visible in plans and chats", safetyReminders) {
                        onPreferenceToggle("privacy_safety_reminders", it)
                    }
                }
                ProfileSheet.Location -> {
                    SheetTitle("Location", "Use an approximate area for profile and discovery context.")
                    Surface(shape = CoffeeShapes.large, color = CoffeeSurface, border = BorderStroke(1.dp, CoffeeBorder)) {
                        Text(
                            text = user.location.ifBlank { "No location set" },
                            modifier = Modifier.padding(CoffeeSpacing.md),
                            style = MaterialTheme.typography.bodyLarge,
                            color = CoffeeInk
                        )
                    }
                    CoffeeButton(
                        title = "Update From GPS",
                        onClick = onResolveLocation,
                        variant = CoffeeButtonVariant.Primary,
                        leadingIcon = CoffeeIcons.location
                    )
                }
                ProfileSheet.Help -> {
                    SheetTitle("Help", "Quick support topics")
                    HelpRow("Hosting", "Create a clear plan, keep the meeting point safe, and respond to requests.")
                    HelpRow("Joining", "Request only plans you can attend and use chat for coordination.")
                    HelpRow("Safety", "Meet in public places and keep exact locations private until joined.")
                }
            }
        }
    }
}

@Composable
private fun StatDetailSheet(title: String, value: String, body: String) {
    SheetTitle(title, body)
    Surface(shape = CoffeeShapes.hero, color = CoffeeSurface, border = BorderStroke(1.dp, CoffeeBorder)) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(CoffeeSpacing.xl),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(text = value, style = MaterialTheme.typography.displayMedium, color = CoffeeInk, fontWeight = FontWeight.Black)
            Text(text = title, style = MaterialTheme.typography.labelLarge, color = CoffeeMuted, fontWeight = FontWeight.Bold)
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun InterestsSheet(
    user: UserProfile,
    onUpdateProfile: (List<String>, Boolean, Boolean, Boolean, String) -> Unit
) {
    var selected by remember(user.uid, user.interests) { mutableStateOf(user.interests) }
    val interests = listOf("coffee", "walk", "food", "movie", "study", "gaming", "music", "yoga")

    SheetTitle("Interests", "Pick the activities you want Around to recognize.")
    FlowRow(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs), verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
        interests.forEach { interest ->
            val isSelected = selected.any { it.equals(interest, ignoreCase = true) }
            InterestChip(
                interest = interest,
                selected = isSelected,
                onClick = {
                    selected = if (isSelected) {
                        selected.filterNot { it.equals(interest, ignoreCase = true) }
                    } else {
                        selected + interest
                    }
                    onUpdateProfile(
                        selected,
                        user.availabilityWeekdayEvenings,
                        user.availabilityWeekends,
                        user.availabilityDaytime,
                        user.location
                    )
                }
            )
        }
    }
}

@Composable
private fun AvailabilitySheet(
    user: UserProfile,
    onUpdateProfile: (List<String>, Boolean, Boolean, Boolean, String) -> Unit
) {
    var weekday by remember(user.uid, user.availabilityWeekdayEvenings) { mutableStateOf(user.availabilityWeekdayEvenings) }
    var weekend by remember(user.uid, user.availabilityWeekends) { mutableStateOf(user.availabilityWeekends) }
    var daytime by remember(user.uid, user.availabilityDaytime) { mutableStateOf(user.availabilityDaytime) }

    fun persist() {
        onUpdateProfile(user.interests, weekday, weekend, daytime, user.location)
    }

    SheetTitle("Availability", "Let others know when you are usually open.")
    CheckRow("Weekday evenings", weekday) {
        weekday = it
        persist()
    }
    CheckRow("Weekends", weekend) {
        weekend = it
        persist()
    }
    CheckRow("Daytime", daytime) {
        daytime = it
        persist()
    }
}

@Composable
private fun SheetTitle(title: String, subtitle: String) {
    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)) {
        Text(text = title, style = MaterialTheme.typography.headlineSmall, color = CoffeeInk, fontWeight = FontWeight.Black)
        Text(text = subtitle, style = MaterialTheme.typography.bodyMedium, color = CoffeeMuted)
    }
}

@Composable
private fun ToggleRow(title: String, subtitle: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(CoffeeShapes.large)
            .background(CoffeeSurface)
            .border(1.dp, CoffeeBorder, CoffeeShapes.large)
            .clickable { onCheckedChange(!checked) }
            .padding(CoffeeSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, style = MaterialTheme.typography.labelLarge, color = CoffeeInk, fontWeight = FontWeight.Black)
            Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
        }
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(checkedThumbColor = CoffeeTextOnBrand, checkedTrackColor = CoffeePrimary)
        )
    }
}

@Composable
private fun CheckRow(title: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(CoffeeShapes.large)
            .background(CoffeeSurface)
            .border(1.dp, CoffeeBorder, CoffeeShapes.large)
            .clickable { onCheckedChange(!checked) }
            .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Checkbox(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = CheckboxDefaults.colors(checkedColor = CoffeePrimary)
        )
        Spacer(modifier = Modifier.width(CoffeeSpacing.xs))
        Text(text = title, style = MaterialTheme.typography.bodyMedium, color = CoffeeInk, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun HelpRow(title: String, body: String) {
    Surface(shape = CoffeeShapes.large, color = CoffeeSurface, border = BorderStroke(1.dp, CoffeeBorder)) {
        Column(modifier = Modifier.padding(CoffeeSpacing.md), verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)) {
            Text(text = title, style = MaterialTheme.typography.labelLarge, color = CoffeeInk, fontWeight = FontWeight.Black)
            Text(text = body, style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
        }
    }
}

@Composable
private fun InterestChip(interest: String, selected: Boolean, onClick: () -> Unit) {
    val accent = categoryAccent(interest)
    Surface(
        onClick = onClick,
        shape = CircleShape,
        color = if (selected) accent else accent.copy(alpha = 0.1f),
        border = BorderStroke(1.dp, if (selected) Color.Transparent else accent.copy(alpha = 0.26f))
    ) {
        Row(
            modifier = Modifier.padding(horizontal = CoffeeSpacing.sm, vertical = CoffeeSpacing.xs),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Icon(
                imageVector = CoffeeIcons.category(interest),
                contentDescription = null,
                tint = if (selected) CoffeeTextOnBrand else accent,
                modifier = Modifier.size(14.dp)
            )
            Text(
                text = interest.toDisplayLabel(),
                style = MaterialTheme.typography.labelMedium,
                color = if (selected) CoffeeTextOnBrand else CoffeeInk,
                fontWeight = FontWeight.Black
            )
        }
    }
}

@Composable
private fun HistoryDriftCard(
    drift: DriftPost,
    onDriftClick: (String) -> Unit
) {
    CoffeeDriftCard(
        title = drift.title.ifBlank { drift.hook.ifBlank { "Open Drift" } },
        location = drift.location,
        timeText = drift.date.ifBlank { drift.time },
        distanceText = "0.0 km",
        category = drift.category.firestoreValue,
        onAction = { onDriftClick(drift.id) },
        participants = drift.participantInitials,
        participantSummary = "${drift.participantCount} going",
        actionLabel = "View",
        onClick = { onDriftClick(drift.id) }
    )
}

private fun UserProfile.availabilitySummary(): String =
    listOfNotNull(
        "Weekday evenings".takeIf { availabilityWeekdayEvenings },
        "Weekends".takeIf { availabilityWeekends },
        "Daytime".takeIf { availabilityDaytime }
    ).ifEmpty { listOf("Not set") }.joinToString(", ")

private fun String.toDisplayLabel(): String =
    trim().ifBlank { "Selected" }.replaceFirstChar { it.uppercase() }

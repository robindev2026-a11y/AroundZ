package com.coffeecall.app.feature.chat

import android.app.Application
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeAvatar
import com.coffeecall.app.core.design.CoffeeButton
import com.coffeecall.app.core.design.CoffeeButtonVariant
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeDarkOverlay
import com.coffeecall.app.core.design.CoffeeError
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
import com.coffeecall.app.core.design.CoffeeTopAppBar
import com.coffeecall.app.domain.model.ChatMessage
import com.coffeecall.app.domain.model.MessageType
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatThreadScreen(
    threadId: String,
    onBack: () -> Unit,
    onNavigateToDrift: (String) -> Unit
) {
    val context = LocalContext.current
    val application = context.applicationContext as Application
    val viewModel: ChatThreadViewModel = viewModel(
        factory = ChatThreadViewModel.factory(application, threadId)
    )
    val uiState by viewModel.uiState.collectAsState()

    var menuExpanded by remember { mutableStateOf(false) }
    var showReportDialog by remember { mutableStateOf(false) }
    var reportReason by remember { mutableStateOf("") }
    var showBlockDialog by remember { mutableStateOf(false) }
    var showLeaveDialog by remember { mutableStateOf(false) }
    var showDetailSheet by remember { mutableStateOf(false) }
    var isMuted by remember { mutableStateOf(false) }
    var messageToDelete by remember { mutableStateOf<ChatMessage?>(null) }

    val scope = rememberCoroutineScope()
    val listState = rememberLazyListState()

    // Scroll to bottom on load & new messages
    LaunchedEffect(uiState.messages.size) {
        if (uiState.messages.isNotEmpty()) {
            listState.animateScrollToItem(uiState.messages.size - 1)
        }
    }

    // Photo picker launcher
    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri ->
        if (uri != null) {
            scope.launch {
                val inputStream = context.contentResolver.openInputStream(uri)
                val bytes = inputStream?.readBytes()
                if (bytes != null) {
                    viewModel.sendImageMessage(bytes)
                }
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .imePadding() // Keyboard safety padding
        ) {
            // Header spacing
            Spacer(modifier = Modifier.height(CoffeeSpacing.primaryButtonHeight))

            // Messages List
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .padding(horizontal = CoffeeSpacing.screen),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
            ) {
                item { Spacer(modifier = Modifier.height(CoffeeSpacing.sm)) }
                item {
                    ChatContextChips(
                        title = uiState.drift?.title ?: "Drift chat",
                        category = uiState.drift?.category?.firestoreValue ?: "coffee",
                        location = uiState.drift?.location.orEmpty()
                    )
                }
                items(uiState.messages, key = { it.id }) { message ->
                    val isSelf = message.senderId == uiState.currentUserId
                    val isBlocked = uiState.blockedUsers.contains(message.senderName)

                    if (!isBlocked) {
                        MessageBubble(
                            message = message,
                            isSelf = isSelf,
                            onLongClick = {
                                if (isSelf) {
                                    messageToDelete = message
                                }
                            }
                        )
                    }
                }
                item { Spacer(modifier = Modifier.height(96.dp)) } // Spacer for bottom bar
            }
        }

        // Top App Bar with dropdown menu
        Surface(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .fillMaxWidth(),
            color = CoffeeBackground.copy(alpha = 0.94f),
            shadowElevation = 0.dp
        ) {
            val driftTitle = uiState.drift?.title ?: "Chat"
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = CoffeeSpacing.xs)
                    .padding(horizontal = CoffeeSpacing.screen)
                    .height(CoffeeSpacing.primaryButtonHeight),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Back button
                Text(
                    text = "← Back",
                    color = CoffeePrimary,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier
                        .clickable(onClick = onBack)
                        .padding(vertical = CoffeeSpacing.xs)
                )

                Spacer(modifier = Modifier.width(CoffeeSpacing.md))

                CoffeeAvatar(
                    name = driftTitle,
                    size = 36.dp,
                    background = CoffeePrimary.copy(alpha = 0.12f),
                    ringColor = null
                )
                Spacer(modifier = Modifier.width(CoffeeSpacing.sm))

                // Title
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = driftTitle,
                        style = MaterialTheme.typography.titleMedium,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = "Drift Coordination",
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeeMuted
                    )
                }

                IconButton(onClick = { showDetailSheet = true }) {
                    Icon(
                        imageVector = CoffeeIcons.chevronRight,
                        contentDescription = "Thread details",
                        tint = CoffeeInk,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }
        }

        // Bottom Input bar
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
                .navigationBarsPadding()
                .padding(bottom = CoffeeSpacing.sm)
                .padding(horizontal = CoffeeSpacing.screen)
        ) {
            ChatInputBar(
                isSending = uiState.isSending,
                onSend = viewModel::sendMessage,
                onCameraAttachment = {
                    photoPickerLauncher.launch(
                        PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                    )
                },
                onAddAttachment = {
                    photoPickerLauncher.launch(
                        PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                    )
                },
                onShareLocation = {
                    viewModel.sendLocationMessage("Shared Location: Indiranagar, Bengaluru")
                }
            )
        }

        // Delete Message Dialog
        if (messageToDelete != null) {
            AlertDialog(
                onDismissRequest = { messageToDelete = null },
                title = { Text("Delete Message", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("Are you sure you want to delete this message?", color = CoffeeMuted) },
                confirmButton = {
                    CoffeeButton(
                        title = "Delete",
                        onClick = {
                            viewModel.deleteMessage(messageToDelete!!)
                            messageToDelete = null
                        },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                dismissButton = {
                    CoffeeButton(
                        title = "Cancel",
                        onClick = { messageToDelete = null },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        // Leave Dialog
        if (showLeaveDialog) {
            AlertDialog(
                onDismissRequest = { showLeaveDialog = false },
                title = { Text("Leave Drift", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("Are you sure you want to leave this Drift? You will lose access to the chat room.", color = CoffeeMuted) },
                confirmButton = {
                    CoffeeButton(
                        title = "Leave",
                        onClick = {
                            showLeaveDialog = false
                            viewModel.leaveDrift { success ->
                                if (success) onBack()
                            }
                        },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                dismissButton = {
                    CoffeeButton(
                        title = "Cancel",
                        onClick = { showLeaveDialog = false },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        // Block User Dialog
        if (showBlockDialog) {
            val hostName = uiState.drift?.creatorName ?: "Host"
            AlertDialog(
                onDismissRequest = { showBlockDialog = false },
                title = { Text("Block Siddharth", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("You will no longer see messages or drifts hosted by $hostName.", color = CoffeeMuted) },
                confirmButton = {
                    CoffeeButton(
                        title = "Block",
                        onClick = {
                            showBlockDialog = false
                            viewModel.blockUser(hostName) { success ->
                                if (success) onBack()
                            }
                        },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                dismissButton = {
                    CoffeeButton(
                        title = "Cancel",
                        onClick = { showBlockDialog = false },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        // Report Dialog
        if (showReportDialog) {
            AlertDialog(
                onDismissRequest = { showReportDialog = false },
                title = { Text("Report Drift", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)) {
                        Text("Please provide a reason for reporting this Drift:", color = CoffeeMuted)
                        OutlinedTextField(
                            value = reportReason,
                            onValueChange = { reportReason = it },
                            placeholder = { Text("Inappropriate content, spam, etc.", color = CoffeeMuted) },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = CoffeeInk,
                                unfocusedTextColor = CoffeeInk,
                                focusedBorderColor = CoffeePrimary,
                                unfocusedBorderColor = CoffeeBorder
                            )
                        )
                    }
                },
                confirmButton = {
                    CoffeeButton(
                        title = "Submit",
                        onClick = {
                            if (reportReason.isNotBlank()) {
                                showReportDialog = false
                                viewModel.reportDrift(reportReason) {
                                    reportReason = ""
                                }
                            }
                        },
                        variant = CoffeeButtonVariant.Ghost,
                        enabled = reportReason.isNotBlank(),
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                dismissButton = {
                    CoffeeButton(
                        title = "Cancel",
                        onClick = {
                            showReportDialog = false
                            reportReason = ""
                        },
                        variant = CoffeeButtonVariant.Ghost,
                        fullWidth = false,
                        height = 40.dp
                    )
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        if (showDetailSheet) {
            ChatThreadDetailSheet(
                title = uiState.drift?.title ?: "Drift chat",
                participantCount = uiState.drift?.participantCount ?: uiState.messages.map { it.senderId }.distinct().size,
                isMuted = isMuted,
                onMutedChange = { isMuted = it },
                onViewDrift = {
                    showDetailSheet = false
                    onNavigateToDrift(threadId)
                },
                onReport = {
                    showDetailSheet = false
                    showReportDialog = true
                },
                onBlock = {
                    showDetailSheet = false
                    showBlockDialog = true
                },
                onLeave = {
                    showDetailSheet = false
                    showLeaveDialog = true
                },
                onDismiss = { showDetailSheet = false }
            )
        }
    }
}

@Composable
private fun ChatContextChips(
    title: String,
    category: String,
    location: String
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
        verticalAlignment = Alignment.CenterVertically
    ) {
        ThreadContextChip(
            label = category.replaceFirstChar { it.uppercase() },
            icon = CoffeeIcons.category(category)
        )
        ThreadContextChip(
            label = title,
            icon = CoffeeIcons.chats,
            modifier = Modifier.weight(1f)
        )
        if (location.isNotBlank()) {
            ThreadContextChip(
                label = location,
                icon = CoffeeIcons.location,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun ThreadContextChip(
    label: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier.height(34.dp),
        shape = CircleShape,
        color = CoffeeSurface,
        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = CoffeeSpacing.sm),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = CoffeePrimary, modifier = Modifier.size(14.dp))
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeInk,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ChatThreadDetailSheet(
    title: String,
    participantCount: Int,
    isMuted: Boolean,
    onMutedChange: (Boolean) -> Unit,
    onViewDrift: () -> Unit,
    onReport: () -> Unit,
    onBlock: () -> Unit,
    onLeave: () -> Unit,
    onDismiss: () -> Unit
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
            Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)) {
                Text(text = title, style = MaterialTheme.typography.headlineSmall, color = CoffeeInk, fontWeight = FontWeight.Black)
                Text(text = "$participantCount participants", style = MaterialTheme.typography.bodyMedium, color = CoffeeMuted)
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(CoffeeShapes.large)
                    .background(CoffeeSurface)
                    .border(1.dp, CoffeeBorder, CoffeeShapes.large)
                    .padding(CoffeeSpacing.md),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = "Mute thread", style = MaterialTheme.typography.labelLarge, color = CoffeeInk, fontWeight = FontWeight.Black)
                    Text(text = "Pause chat notifications locally", style = MaterialTheme.typography.bodySmall, color = CoffeeMuted)
                }
                Switch(
                    checked = isMuted,
                    onCheckedChange = onMutedChange,
                    colors = SwitchDefaults.colors(checkedThumbColor = CoffeeTextOnBrand, checkedTrackColor = CoffeePrimary)
                )
            }

            DetailSheetAction("View Drift", CoffeeIcons.chevronRight, onViewDrift)
            DetailSheetAction("Report Drift", CoffeeIcons.bell, onReport, destructive = true)
            DetailSheetAction("Block Host", CoffeeIcons.close, onBlock, destructive = true)
            DetailSheetAction("Leave Chat", CoffeeIcons.close, onLeave, destructive = true)
        }
    }
}

@Composable
private fun DetailSheetAction(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit,
    destructive: Boolean = false
) {
    Surface(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = if (destructive) CoffeeError else CoffeePrimary,
                modifier = Modifier.size(CoffeeSpacing.lg)
            )
            Text(
                text = title,
                style = MaterialTheme.typography.labelLarge,
                color = if (destructive) CoffeeError else CoffeeInk,
                fontWeight = FontWeight.Black
            )
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun MessageBubble(
    message: ChatMessage,
    isSelf: Boolean,
    onLongClick: () -> Unit
) {
    if (message.type == MessageType.System) {
        Text(
            text = message.text,
            style = MaterialTheme.typography.labelSmall,
            color = CoffeeMuted,
            textAlign = TextAlign.Center,
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = CoffeeSpacing.xs)
        )
        return
    }

    val bubbleColor = if (isSelf) CoffeePrimary else CoffeeSurfaceSecondary
    val textColor = if (isSelf) CoffeeTextOnBrand else CoffeeInk
    val shape = if (isSelf) {
        RoundedCornerShape(16.dp, 16.dp, 0.dp, 16.dp)
    } else {
        RoundedCornerShape(16.dp, 16.dp, 16.dp, 0.dp)
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp),
        horizontalArrangement = if (isSelf) Arrangement.End else Arrangement.Start,
        verticalAlignment = Alignment.Bottom
    ) {
        if (!isSelf) {
            CoffeeAvatar(
                name = message.senderName,
                size = 32.dp,
                background = CoffeePurple.copy(alpha = 0.12f),
                ringColor = null,
                modifier = Modifier.padding(end = CoffeeSpacing.xs, bottom = 2.dp)
            )
        }

        Column(
            horizontalAlignment = if (isSelf) Alignment.End else Alignment.Start
        ) {
            if (!isSelf) {
                Text(
                    text = message.senderName,
                    style = MaterialTheme.typography.labelSmall,
                    color = CoffeeMuted,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(start = CoffeeSpacing.xxs, bottom = 2.dp)
                )
            }

            Surface(
                shape = shape,
                color = bubbleColor,
                border = if (isSelf) null else androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.5f)),
                modifier = Modifier
                    .widthIn(max = 280.dp)
                    .combinedClickable(
                        onClick = {},
                        onLongClick = onLongClick
                    )
            ) {
                Column(modifier = Modifier.padding(horizontal = CoffeeSpacing.sm, vertical = CoffeeSpacing.xs)) {
                    when (message.type) {
                        MessageType.Image -> {
                            AsyncImage(
                                model = message.text,
                                contentDescription = "Image attachment",
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(160.dp)
                                    .clip(CoffeeShapes.medium),
                                contentScale = ContentScale.Crop
                            )
                        }
                        MessageType.Location -> {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(CoffeeIcons.location, contentDescription = null, tint = CoffeePrimary, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(CoffeeSpacing.xxs))
                                Text(
                                    text = message.text,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = textColor,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        else -> {
                            Text(
                                text = message.text,
                                style = MaterialTheme.typography.bodyMedium,
                                color = textColor
                            )
                        }
                    }

                    // Time
                    Spacer(modifier = Modifier.height(2.dp))
                    val timeString = message.timestamp?.let {
                        SimpleDateFormat("h:mm a", Locale.getDefault()).format(it)
                    } ?: ""
                    Text(
                        text = timeString,
                        fontSize = 9.sp,
                        color = textColor.copy(alpha = 0.6f),
                        modifier = Modifier.align(Alignment.End)
                    )
                }
            }
        }
    }
}

@Composable
private fun ChatInputBar(
    isSending: Boolean,
    onSend: (String) -> Unit,
    onCameraAttachment: () -> Unit,
    onAddAttachment: () -> Unit,
    onShareLocation: () -> Unit
) {
    var text by remember { mutableStateOf("") }
    var showAttachmentMenu by remember { mutableStateOf(false) }

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(8.dp, CircleShape)
            .clip(CircleShape)
            .border(1.dp, CoffeeBorder, CircleShape),
        color = Color.White
    ) {
        Row(
            modifier = Modifier.padding(horizontal = CoffeeSpacing.xs, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Add attachment button
            Box {
                IconButton(onClick = { showAttachmentMenu = true }) {
                    Text("+", style = MaterialTheme.typography.titleLarge, color = CoffeePrimary, fontWeight = FontWeight.Bold)
                }
                DropdownMenu(
                    expanded = showAttachmentMenu,
                    onDismissRequest = { showAttachmentMenu = false },
                    modifier = Modifier.background(CoffeeSurface)
                ) {
                    DropdownMenuItem(
                        text = { Text("Camera", color = CoffeeInk) },
                        onClick = {
                            showAttachmentMenu = false
                            onCameraAttachment()
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Photo Library", color = CoffeeInk) },
                        onClick = {
                            showAttachmentMenu = false
                            onAddAttachment()
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Current Location", color = CoffeeInk) },
                        onClick = {
                            showAttachmentMenu = false
                            onShareLocation()
                        }
                    )
                }
            }

            // Input TextField
            OutlinedTextField(
                value = text,
                onValueChange = { text = it },
                placeholder = { Text("Type a message...", color = CoffeeMuted) },
                maxLines = 4,
                modifier = Modifier.weight(1f),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = CoffeeInk,
                    unfocusedTextColor = CoffeeInk,
                    focusedBorderColor = Color.Transparent,
                    unfocusedBorderColor = Color.Transparent
                ),
                shape = CircleShape
            )

            // Send Button
            if (isSending) {
                CircularProgressIndicator(color = CoffeePrimary, modifier = Modifier.size(CoffeeSpacing.xl).padding(end = CoffeeSpacing.xxs))
            } else {
                IconButton(
                    onClick = {
                        if (text.isNotBlank()) {
                            onSend(text)
                            text = ""
                        }
                    },
                    enabled = text.isNotBlank(),
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(if (text.isNotBlank()) CoffeePrimary else CoffeeSurfaceSecondary)
                ) {
                    Icon(
                        imageVector = CoffeeIcons.send,
                        contentDescription = "Send",
                        tint = if (text.isNotBlank()) CoffeeTextOnBrand else CoffeeMuted,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        }
    }
}

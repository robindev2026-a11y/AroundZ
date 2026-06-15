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
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
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
            Spacer(modifier = Modifier.height(56.dp))

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
                    .height(56.dp),
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

                // Safety Options drop down trigger
                Box {
                    IconButton(onClick = { menuExpanded = true }) {
                        Text("⋮", style = MaterialTheme.typography.titleLarge, color = CoffeeInk)
                    }
                    DropdownMenu(
                        expanded = menuExpanded,
                        onDismissRequest = { menuExpanded = false },
                        modifier = Modifier.background(CoffeeSurface)
                    ) {
                        DropdownMenuItem(
                            text = { Text("View Drift Details", color = CoffeeInk) },
                            onClick = {
                                menuExpanded = false
                                onNavigateToDrift(threadId)
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Leave Drift", color = CoffeeError) },
                            onClick = {
                                menuExpanded = false
                                showLeaveDialog = true
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Block Host", color = CoffeeError) },
                            onClick = {
                                menuExpanded = false
                                showBlockDialog = true
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Report Drift", color = CoffeeError) },
                            onClick = {
                                menuExpanded = false
                                showReportDialog = true
                            }
                        )
                    }
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
                    TextButton(onClick = {
                        viewModel.deleteMessage(messageToDelete!!)
                        messageToDelete = null
                    }) {
                        Text("Delete", color = CoffeeError)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { messageToDelete = null }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
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
                    TextButton(onClick = {
                        showLeaveDialog = false
                        viewModel.leaveDrift { success ->
                            if (success) onBack()
                        }
                    }) {
                        Text("Leave", color = CoffeeError)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showLeaveDialog = false }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
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
                    TextButton(onClick = {
                        showBlockDialog = false
                        viewModel.blockUser(hostName) { success ->
                            if (success) onBack()
                        }
                    }) {
                        Text("Block", color = CoffeeError)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showBlockDialog = false }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
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
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
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
                    TextButton(
                        onClick = {
                            if (reportReason.isNotBlank()) {
                                showReportDialog = false
                                viewModel.reportDrift(reportReason) {
                                    reportReason = ""
                                }
                            }
                        },
                        enabled = reportReason.isNotBlank()
                    ) {
                        Text("Submit", color = CoffeeError)
                    }
                },
                dismissButton = {
                    TextButton(onClick = {
                        showReportDialog = false
                        reportReason = ""
                    }) {
                        Text("Cancel", color = CoffeeMuted)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
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
    val alignment = if (isSelf) Alignment.End else Alignment.Start
    val shape = if (isSelf) {
        RoundedCornerShape(16.dp, 16.dp, 0.dp, 16.dp)
    } else {
        RoundedCornerShape(16.dp, 16.dp, 16.dp, 0.dp)
    }

    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = alignment
    ) {
        // Sender info (for others)
        if (!isSelf) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(start = 4.dp, bottom = 2.dp)
            ) {
                // Mini Avatar
                val initials = message.senderName.split(" ")
                    .mapNotNull { it.firstOrNull()?.toString() }
                    .joinToString("")
                    .uppercase()
                Box(
                    modifier = Modifier
                        .size(20.dp)
                        .clip(CircleShape)
                        .background(CoffeePurple.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = if (initials.isEmpty()) "P" else initials.take(2),
                        fontSize = 10.sp,
                        color = CoffeePurple,
                        fontWeight = FontWeight.Bold
                    )
                }
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = message.senderName,
                    style = MaterialTheme.typography.labelSmall,
                    color = CoffeeMuted,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        // Bubble Content
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
            Column(modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)) {
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
                            Text(text = "📍", fontSize = 16.sp)
                            Spacer(modifier = Modifier.width(4.dp))
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

@Composable
private fun ChatInputBar(
    isSending: Boolean,
    onSend: (String) -> Unit,
    onAddAttachment: () -> Unit,
    onShareLocation: () -> Unit
) {
    var text by remember { mutableStateOf("") }
    var showAttachmentMenu by remember { mutableStateOf(false) }

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(16.dp, CoffeeShapes.large, spotColor = CoffeeDarkOverlay.copy(alpha = 0.12f))
            .clip(CoffeeShapes.large)
            .border(1.dp, CoffeeBorder.copy(alpha = 0.72f), CoffeeShapes.large),
        color = CoffeeSurface.copy(alpha = 0.94f)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = CoffeeSpacing.sm, vertical = CoffeeSpacing.xs),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
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
                        text = { Text("📤 Photo Attachment", color = CoffeeInk) },
                        onClick = {
                            showAttachmentMenu = false
                            onAddAttachment()
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("📍 Share Location", color = CoffeeInk) },
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
                CircularProgressIndicator(color = CoffeePrimary, modifier = Modifier.size(24.dp).padding(end = 4.dp))
            } else {
                IconButton(
                    onClick = {
                        if (text.isNotBlank()) {
                            onSend(text)
                            text = ""
                        }
                    },
                    enabled = text.isNotBlank()
                ) {
                    Text(
                        text = "Send",
                        color = if (text.isNotBlank()) CoffeePrimary else CoffeeMuted,
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.labelLarge
                    )
                }
            }
        }
    }
}

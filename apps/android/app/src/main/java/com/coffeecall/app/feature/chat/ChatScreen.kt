package com.coffeecall.app.feature.chat

import android.app.Application
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.google.firebase.auth.FirebaseAuth
import com.coffeecall.app.core.design.CoffeeAvatar
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeDarkOverlay
import com.coffeecall.app.core.design.CoffeeEmptyState
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePeach
import com.coffeecall.app.core.design.CoffeePrimary
import com.coffeecall.app.core.design.CoffeePurple
import com.coffeecall.app.core.design.CoffeeShapes
import com.coffeecall.app.core.design.CoffeeSpacing
import com.coffeecall.app.core.design.CoffeeSurface
import com.coffeecall.app.core.design.CoffeeTopAppBar
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.MessageThread

private enum class ChatStatusFilter(val label: String) {
    Active("Active"),
    Joined("Joined"),
    Hosted("Hosted"),
    Expired("Expired")
}

@Composable
fun ChatScreen(
    onThreadClick: (String) -> Unit = {}
) {
    val context = LocalContext.current
    val application = context.applicationContext as Application
    val viewModel: ChatsListViewModel = viewModel(
        factory = ChatsListViewModel.factory(application)
    )
    val uiState by viewModel.uiState.collectAsState()
    var selectedFilter by remember { mutableStateOf(ChatStatusFilter.Active) }
    val visibleThreads = remember(uiState.threads, selectedFilter) {
        val currentUserId = com.google.firebase.auth.FirebaseAuth.getInstance().currentUser?.uid
        uiState.threads.filter { item ->
            val status = item.post?.status ?: DriftStatus.Open
            val isCreator = item.post?.creatorId == currentUserId
            when (selectedFilter) {
                ChatStatusFilter.Active -> status == DriftStatus.Open
                ChatStatusFilter.Joined -> status == DriftStatus.Open && !isCreator
                ChatStatusFilter.Hosted -> status == DriftStatus.Open && isCreator
                ChatStatusFilter.Expired -> status == DriftStatus.Ended
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.xs),
            shape = androidx.compose.foundation.shape.RoundedCornerShape(32.dp),
            color = androidx.compose.ui.graphics.Color.White,
            shadowElevation = 8.dp
        ) {
            CoffeeTopAppBar(
                title = "Chats",
                subtitle = "Drift rooms",
                modifier = Modifier
            )
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = CoffeeSpacing.screen)
                .padding(top = CoffeeSpacing.sm, bottom = CoffeeSpacing.screenBottomSpacer),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
        if (uiState.isLoading) {
            Box(modifier = Modifier.fillMaxWidth().height(200.dp), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = CoffeePrimary)
            }
        } else if (uiState.threads.isEmpty()) {
            CoffeeEmptyState(
                title = "No Drift chats yet",
                subtitle = "Chats unlock automatically after you host or join an active Drift.",
                icon = CoffeeIcons.chats,
                actionLabel = null,
                onAction = {}
            )
        } else {
            ChatFilterRow(
                selected = selectedFilter,
                onSelected = { selectedFilter = it }
            )

            if (visibleThreads.isEmpty()) {
                CoffeeEmptyState(
                    title = "No ${selectedFilter.label.lowercase()} chats",
                    subtitle = "Switch filters to see another set of drift conversations.",
                    icon = CoffeeIcons.chats,
                    actionLabel = null,
                    onAction = {}
                )
            }

            visibleThreads.forEach { item ->
                ChatThreadCard(item = item, onClick = { onThreadClick(item.thread.id) })
            }
        }
    }
    }
}

@Composable
private fun ChatFilterRow(
    selected: ChatStatusFilter,
    onSelected: (ChatStatusFilter) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
    ) {
        ChatStatusFilter.entries.forEach { filter ->
            val isSelected = selected == filter
            Surface(
                onClick = { onSelected(filter) },
                modifier = Modifier.weight(1f).height(CoffeeSpacing.minTouchTarget),
                shape = CircleShape,
                color = if (isSelected) CoffeePrimary else CoffeeSurface,
                border = androidx.compose.foundation.BorderStroke(1.dp, if (isSelected) Color.Transparent else CoffeeBorder)
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = CoffeeSpacing.sm),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = when (filter) {
                            ChatStatusFilter.Active -> CoffeeIcons.chats
                            ChatStatusFilter.Joined -> CoffeeIcons.people
                            ChatStatusFilter.Hosted -> CoffeeIcons.drifts
                            ChatStatusFilter.Expired -> CoffeeIcons.clock
                        },
                        contentDescription = null,
                        tint = if (isSelected) Color.White else CoffeeMuted,
                        modifier = Modifier.size(CoffeeSpacing.md)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = filter.label,
                        style = MaterialTheme.typography.labelMedium,
                        color = if (isSelected) Color.White else CoffeeInk,
                        fontWeight = FontWeight.Black,
                        maxLines = 1
                    )
                }
            }
        }
    }
}

@Composable
private fun ChatThreadCard(
    item: ChatThreadItem,
    onClick: () -> Unit
) {
    val thread = item.thread
    val post = item.post
    val category = post?.category ?: DriftCategory.Coffee

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .shadow(
                elevation = 2.dp,
                shape = CoffeeShapes.large,
                ambientColor = CoffeeDarkOverlay.copy(alpha = 0.08f),
                spotColor = CoffeeDarkOverlay.copy(alpha = 0.08f)
            )
            .border(1.dp, CoffeeBorder, CoffeeShapes.large),
        shape = CoffeeShapes.large,
        color = CoffeeSurface
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            // Host Avatar with Category Badge overlay
            Box(
                modifier = Modifier.size(52.dp)
            ) {
                CoffeeAvatar(
                    name = post?.creatorName ?: "Host",
                    imageUrl = post?.creatorImageUrl?.ifBlank { null },
                    size = 46.dp,
                    background = CoffeePurple.copy(alpha = 0.12f),
                    ringColor = null
                )

                Box(
                    modifier = Modifier
                        .size(CoffeeSpacing.lg)
                        .align(Alignment.BottomEnd)
                        .clip(CircleShape)
                        .background(categoryColor(category))
                        .border(1.5.dp, Color.White, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(categorySymbol(category), contentDescription = null, tint = Color.White, modifier = Modifier.size(10.dp))
                }
            }

            // Info
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = post?.title ?: "Specialty Coffee Tasting",
                        style = MaterialTheme.typography.titleMedium,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Spacer(modifier = Modifier.width(CoffeeSpacing.xxs))
                    Text(
                        text = formatRelativeTime(thread.lastMessage?.timestamp),
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeeMuted
                    )
                }

                Text(
                    text = "Hosted by ${post?.creatorName ?: "Host"}",
                    style = MaterialTheme.typography.labelSmall,
                    color = CoffeeMuted
                )

                Spacer(modifier = Modifier.height(2.dp))

                // Last Message Snippet
                val lastMsgText = thread.lastMessage?.text ?: "Welcome to the chat room!"
                Text(
                    text = lastMsgText,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeInk.copy(alpha = 0.72f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // Unread indicator
            val currentUserId = FirebaseAuth.getInstance().currentUser?.uid.orEmpty()
            val isFromSelf = thread.lastMessage?.senderId == currentUserId
            if (!isFromSelf && thread.lastMessage != null) {
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .clip(CircleShape)
                        .background(CoffeePrimary)
                )
            }
        }
    }
}

private fun initialsFrom(name: String): String =
    name.split(" ")
        .filter { it.isNotBlank() }
        .mapNotNull { it.firstOrNull()?.uppercaseChar()?.toString() }
        .take(2)
        .joinToString("")
        .ifBlank { "U" }

// Helpers
private fun categorySymbol(cat: DriftCategory): androidx.compose.ui.graphics.vector.ImageVector =
    CoffeeIcons.category(cat.name)

private fun categoryColor(cat: DriftCategory): Color =
    when (cat) {
        DriftCategory.Coffee -> CoffeePrimary
        DriftCategory.Walk -> CoffeePeach
        DriftCategory.Movie -> CoffeePurple
        else -> CoffeePrimary
    }

private fun formatRelativeTime(date: java.util.Date?): String {
    if (date == null) return ""
    val diff = System.currentTimeMillis() - date.time
    val diffSec = diff / 1000
    val diffMin = diffSec / 60
    val diffHour = diffMin / 60
    val diffDay = diffHour / 24

    return when {
        diffMin < 1 -> "just now"
        diffMin < 60 -> "${diffMin}m ago"
        diffHour < 24 -> "${diffHour}h ago"
        else -> "${diffDay}d ago"
    }
}

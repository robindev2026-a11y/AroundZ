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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.google.firebase.auth.FirebaseAuth
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeDarkOverlay
import com.coffeecall.app.core.design.CoffeeEmptyState
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePeach
import com.coffeecall.app.core.design.CoffeePrimary
import com.coffeecall.app.core.design.CoffeePurple
import com.coffeecall.app.core.design.CoffeeShapes
import com.coffeecall.app.core.design.CoffeeSpacing
import com.coffeecall.app.core.design.CoffeeSurface
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.MessageThread

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

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = CoffeeSpacing.screen)
            .padding(top = 104.dp, bottom = CoffeeSpacing.screenBottomSpacer),
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
                symbol = "C",
                actionLabel = null,
                onAction = {}
            )
        } else {
            uiState.threads.forEach { item ->
                ChatThreadCard(item = item, onClick = { onThreadClick(item.thread.id) })
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
                elevation = 8.dp,
                shape = CoffeeShapes.large,
                ambientColor = CoffeeDarkOverlay.copy(alpha = 0.08f),
                spotColor = CoffeeDarkOverlay.copy(alpha = 0.08f)
            ),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            // Category Icon
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(categoryColor(category).copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = categorySymbol(category),
                    style = MaterialTheme.typography.titleMedium,
                    color = categoryColor(category)
                )
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
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = formatRelativeTime(thread.lastMessage?.timestamp),
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeeMuted
                    )
                }

                Text(
                    text = "Hosted by ${post?.creatorName ?: "Siddharth"}",
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

            // Unread indicator (simply render a dot if a message exists but is not from self)
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

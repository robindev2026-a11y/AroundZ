package com.coffeecall.app.feature.discovery

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeButton
import com.coffeecall.app.core.design.CoffeeButtonVariant
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePrimary
import com.coffeecall.app.core.design.CoffeeShapes
import com.coffeecall.app.core.design.CoffeeSpacing
import com.coffeecall.app.core.design.CoffeeSurface
import com.coffeecall.app.core.design.CoffeeSurfaceSecondary

data class DiscoveryNotification(
    val id: String,
    val driftId: String,
    val title: String,
    val body: String,
    val timestamp: String,
    val category: String,
    val isUnread: Boolean = true
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationsSheet(
    notifications: List<DiscoveryNotification>,
    onDismiss: () -> Unit,
    onNotificationClick: (DiscoveryNotification) -> Unit
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
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = "Notifications",
                    style = MaterialTheme.typography.headlineSmall,
                    color = CoffeeInk,
                    fontWeight = FontWeight.Black
                )
                Text(
                    text = "Join requests and drift updates",
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeMuted
                )
            }

            if (notifications.isEmpty()) {
                NotificationsEmptyState(onDismiss = onDismiss)
            } else {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(max = 520.dp),
                    verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
                ) {
                    items(notifications, key = { it.id }) { notification ->
                        NotificationRow(
                            notification = notification,
                            onClick = { onNotificationClick(notification) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun NotificationRow(
    notification: DiscoveryNotification,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurface,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.7f)),
        shadowElevation = 1.dp
    ) {
        Row(
            modifier = Modifier.padding(CoffeeSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(CoffeePrimary.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.category(notification.category),
                    contentDescription = null,
                    tint = CoffeePrimary,
                    modifier = Modifier.size(22.dp)
                )
            }

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(3.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
                ) {
                    Text(
                        text = notification.title,
                        modifier = Modifier.weight(1f),
                        style = MaterialTheme.typography.labelLarge,
                        color = CoffeeInk,
                        fontWeight = FontWeight.Black,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = notification.timestamp,
                        style = MaterialTheme.typography.labelSmall,
                        color = CoffeeMuted,
                        maxLines = 1
                    )
                }
                Text(
                    text = notification.body,
                    style = MaterialTheme.typography.bodySmall,
                    color = CoffeeMuted,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            if (notification.isUnread) {
                Box(
                    modifier = Modifier
                        .size(9.dp)
                        .clip(CircleShape)
                        .background(CoffeePrimary)
                )
            }
        }
    }
}

@Composable
private fun NotificationsEmptyState(onDismiss: () -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = CoffeeShapes.large,
        color = CoffeeSurfaceSecondary,
        border = BorderStroke(1.dp, CoffeeBorder.copy(alpha = 0.6f))
    ) {
        Column(
            modifier = Modifier.padding(CoffeeSpacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)
        ) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.bell,
                    contentDescription = null,
                    tint = CoffeeMuted,
                    modifier = Modifier.size(24.dp)
                )
            }
            Text(
                text = "All caught up",
                style = MaterialTheme.typography.titleMedium,
                color = CoffeeInk,
                fontWeight = FontWeight.Black
            )
            Text(
                text = "Requests and drift updates will show up here.",
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted
            )
            Spacer(modifier = Modifier.height(CoffeeSpacing.xs))
            CoffeeButton(
                title = "Done",
                onClick = onDismiss,
                variant = CoffeeButtonVariant.Secondary
            )
        }
    }
}

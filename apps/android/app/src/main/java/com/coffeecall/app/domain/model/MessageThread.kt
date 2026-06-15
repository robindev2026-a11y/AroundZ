package com.coffeecall.app.domain.model

import java.util.Date

data class MessageThread(
    val id: String,
    val postId: String,
    val participants: List<String> = emptyList(),
    val lastMessage: ThreadLastMessage? = null,
    val createdAt: Date? = null,
    val updatedAt: Date? = null
)

data class ThreadLastMessage(
    val text: String = "",
    val senderId: String = "",
    val senderName: String = "",
    val timestamp: Date? = null
)

data class ChatMessage(
    val id: String,
    val senderId: String = "",
    val senderName: String = "",
    val text: String = "",
    val timestamp: Date? = null,
    val type: MessageType = MessageType.Text
)

enum class MessageType(val firestoreValue: String) {
    Text("text"),
    System("system"),
    Image("image"),
    Location("location");

    companion object {
        fun fromFirestore(value: String?): MessageType =
            entries.firstOrNull { it.firestoreValue.equals(value, ignoreCase = true) } ?: Text
    }
}

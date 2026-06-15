package com.coffeecall.app.data.remote.dto

import com.google.firebase.Timestamp

data class MessageThreadDto(
    val id: String = "",
    val postId: String = "",
    val participants: List<String> = emptyList(),
    val lastMessage: LastMessageDto? = null,
    val createdAt: Timestamp? = null,
    val updatedAt: Timestamp? = null
)

data class LastMessageDto(
    val text: String = "",
    val senderId: String = "",
    val senderName: String = "",
    val timestamp: Timestamp? = null
)

data class ChatMessageDto(
    val id: String = "",
    val senderId: String = "",
    val senderName: String = "",
    val text: String = "",
    val timestamp: Timestamp? = null,
    val type: String = "text"
)

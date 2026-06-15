package com.coffeecall.app.data.mapper

import com.coffeecall.app.data.remote.dto.ChatMessageDto
import com.coffeecall.app.data.remote.dto.LastMessageDto
import com.coffeecall.app.data.remote.dto.MessageThreadDto
import com.coffeecall.app.domain.model.ChatMessage
import com.coffeecall.app.domain.model.MessageThread
import com.coffeecall.app.domain.model.MessageType
import com.coffeecall.app.domain.model.ThreadLastMessage
import com.google.firebase.firestore.DocumentSnapshot

fun DocumentSnapshot.toMessageThreadDto(): MessageThreadDto {
    val data = data.orEmpty()
    return MessageThreadDto(
        id = id,
        postId = data["postId"] as? String ?: id,
        participants = data["participants"].asStringList(),
        lastMessage = (data["lastMessage"] as? Map<*, *>)?.let { raw ->
            LastMessageDto(
                text = raw["text"] as? String ?: "",
                senderId = raw["senderId"] as? String ?: "",
                senderName = raw["senderName"] as? String ?: "",
                timestamp = raw["timestamp"] as? com.google.firebase.Timestamp
            )
        },
        createdAt = getTimestamp("createdAt"),
        updatedAt = getTimestamp("updatedAt")
    )
}

fun DocumentSnapshot.toChatMessageDto(): ChatMessageDto {
    val data = data.orEmpty()
    return ChatMessageDto(
        id = id,
        senderId = data["senderId"] as? String ?: "",
        senderName = data["senderName"] as? String ?: "",
        text = data["text"] as? String ?: "",
        timestamp = getTimestamp("timestamp"),
        type = data["type"] as? String ?: "text"
    )
}

fun MessageThreadDto.toDomain(): MessageThread =
    MessageThread(
        id = id,
        postId = postId,
        participants = participants,
        lastMessage = lastMessage?.toDomain(),
        createdAt = createdAt.toDateOrNull(),
        updatedAt = updatedAt.toDateOrNull()
    )

fun LastMessageDto.toDomain(): ThreadLastMessage =
    ThreadLastMessage(
        text = text,
        senderId = senderId,
        senderName = senderName,
        timestamp = timestamp.toDateOrNull()
    )

fun ChatMessageDto.toDomain(): ChatMessage =
    ChatMessage(
        id = id,
        senderId = senderId,
        senderName = senderName,
        text = text,
        timestamp = timestamp.toDateOrNull(),
        type = MessageType.fromFirestore(type)
    )

fun MessageThread.toDto(): MessageThreadDto =
    MessageThreadDto(
        id = id,
        postId = postId,
        participants = participants,
        lastMessage = lastMessage?.toDto(),
        createdAt = createdAt.toTimestampOrNull(),
        updatedAt = updatedAt.toTimestampOrNull()
    )

fun ThreadLastMessage.toDto(): LastMessageDto =
    LastMessageDto(
        text = text,
        senderId = senderId,
        senderName = senderName,
        timestamp = timestamp.toTimestampOrNull()
    )

fun ChatMessage.toDto(): ChatMessageDto =
    ChatMessageDto(
        id = id,
        senderId = senderId,
        senderName = senderName,
        text = text,
        timestamp = timestamp.toTimestampOrNull(),
        type = type.firestoreValue
    )

fun MessageThreadDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "postId" to postId,
        "participants" to participants,
        "lastMessage" to lastMessage?.toFirestoreMap(),
        "createdAt" to createdAt,
        "updatedAt" to updatedAt
    ).withoutNullValues()

fun LastMessageDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "text" to text,
        "senderId" to senderId,
        "senderName" to senderName,
        "timestamp" to timestamp
    ).withoutNullValues()

fun ChatMessageDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "senderId" to senderId,
        "senderName" to senderName,
        "text" to text,
        "timestamp" to timestamp,
        "type" to type
    ).withoutNullValues()

package com.coffeecall.app.data.repository.mock

import com.coffeecall.app.domain.model.ChatMessage
import com.coffeecall.app.domain.model.MessageThread
import com.coffeecall.app.domain.model.ThreadLastMessage
import com.coffeecall.app.domain.repository.MessageThreadRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.flowOf
import java.util.Date
import java.util.UUID

class MockMessageThreadRepository : MessageThreadRepository {
    private val threads = mutableMapOf<String, MessageThread>()
    private val messages = mutableMapOf<String, MutableList<ChatMessage>>()

    init {
        val mockThreadId = "mock_thread_1"
        threads[mockThreadId] = MessageThread(
            id = mockThreadId,
            postId = "mock_joined_1",
            participants = listOf("mock_user", "mock_host_123"),
            lastMessage = ThreadLastMessage(
                text = "See you there!",
                senderId = "mock_host_123",
                senderName = "Siddharth",
                timestamp = Date()
            )
        )
        messages[mockThreadId] = mutableListOf(
            ChatMessage(
                id = UUID.randomUUID().toString(),
                senderId = "system",
                senderName = "System",
                text = "Drift created! Welcome to the chat room.",
                timestamp = Date(),
                type = com.coffeecall.app.domain.model.MessageType.System
            ),
            ChatMessage(
                id = UUID.randomUUID().toString(),
                senderId = "mock_host_123",
                senderName = "Siddharth",
                text = "Hey everyone, excited for the coffee tasting!",
                timestamp = Date()
            )
        )
    }

    override suspend fun getThread(threadId: String): MessageThread? = threads[threadId]

    override suspend fun upsertThread(thread: MessageThread) {
        threads[thread.id] = thread
    }

    override suspend fun getMessages(threadId: String): List<ChatMessage> =
        messages[threadId]?.toList() ?: emptyList()

    override suspend fun addMessage(threadId: String, message: ChatMessage): String {
        val id = message.id.ifBlank { UUID.randomUUID().toString() }
        val msg = message.copy(id = id)
        messages.getOrPut(threadId) { mutableListOf() }.add(msg)
        threads[threadId]?.let { thread ->
            threads[threadId] = thread.copy(
                lastMessage = ThreadLastMessage(
                    text = msg.text,
                    senderId = msg.senderId,
                    senderName = msg.senderName,
                    timestamp = msg.timestamp
                )
            )
        }
        return id
    }

    override fun observeThreads(currentUserId: String): Flow<List<MessageThread>> =
        flowOf(threads.values.filter { it.participants.contains(currentUserId) }.toList())

    override fun observeMessages(threadId: String): Flow<List<ChatMessage>> =
        flowOf(messages[threadId]?.toList() ?: emptyList())

    override suspend fun deleteMessage(threadId: String, messageId: String) {
        messages[threadId]?.removeAll { it.id == messageId }
    }

    override suspend fun uploadChatImage(threadId: String, photoId: String, imageBytes: ByteArray): String =
        "mock://chat_attachments/$threadId/$photoId.jpg"
}

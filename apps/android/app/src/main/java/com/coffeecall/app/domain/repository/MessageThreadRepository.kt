package com.coffeecall.app.domain.repository

import com.coffeecall.app.domain.model.ChatMessage
import com.coffeecall.app.domain.model.MessageThread
import kotlinx.coroutines.flow.Flow

interface MessageThreadRepository {
    suspend fun getThread(threadId: String): MessageThread?
    suspend fun upsertThread(thread: MessageThread)
    suspend fun getMessages(threadId: String): List<ChatMessage>
    suspend fun addMessage(threadId: String, message: ChatMessage): String
    fun observeThreads(currentUserId: String): Flow<List<MessageThread>>
    fun observeMessages(threadId: String): Flow<List<ChatMessage>>
    suspend fun deleteMessage(threadId: String, messageId: String)
    suspend fun uploadChatImage(threadId: String, photoId: String, imageBytes: ByteArray): String
}

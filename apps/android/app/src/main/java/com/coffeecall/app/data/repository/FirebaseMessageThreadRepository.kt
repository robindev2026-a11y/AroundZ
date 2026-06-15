package com.coffeecall.app.data.repository

import com.coffeecall.app.core.firebase.FirebaseCollections
import com.coffeecall.app.data.mapper.toChatMessageDto
import com.coffeecall.app.data.mapper.toDomain
import com.coffeecall.app.data.mapper.toDto
import com.coffeecall.app.data.mapper.toFirestoreMap
import com.coffeecall.app.data.mapper.toMessageThreadDto
import com.coffeecall.app.core.firebase.FirebaseInitializationState
import com.coffeecall.app.core.firebase.FirebaseInitializer
import com.coffeecall.app.domain.model.ChatMessage
import com.coffeecall.app.domain.model.MessageThread
import com.coffeecall.app.domain.repository.MessageThreadRepository
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.SetOptions
import com.google.firebase.storage.FirebaseStorage
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class FirebaseMessageThreadRepository(
    private val firestoreProvider: () -> FirebaseFirestore = { FirebaseFirestore.getInstance() }
) : MessageThreadRepository {
    override suspend fun getThread(threadId: String): MessageThread? {
        requireFirebaseConfigured()
        val snapshot = firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .document(threadId)
            .get()
            .await()

        return if (snapshot.exists()) snapshot.toMessageThreadDto().toDomain() else null
    }

    override suspend fun upsertThread(thread: MessageThread) {
        requireFirebaseConfigured()
        val data = thread.toDto().toFirestoreMap().toMutableMap()
        data["updatedAt"] = FieldValue.serverTimestamp()
        if (thread.createdAt == null) {
            data.putIfAbsent("createdAt", FieldValue.serverTimestamp())
        }

        firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .document(thread.id)
            .set(data, SetOptions.merge())
            .await()
    }

    override suspend fun getMessages(threadId: String): List<ChatMessage> {
        requireFirebaseConfigured()
        return firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .document(threadId)
            .collection(FirebaseCollections.MESSAGES)
            .orderBy("timestamp", Query.Direction.ASCENDING)
            .get()
            .await()
            .documents
            .mapNotNull { snapshot ->
                if (snapshot.exists()) snapshot.toChatMessageDto().toDomain() else null
            }
    }

    override suspend fun addMessage(threadId: String, message: ChatMessage): String {
        requireFirebaseConfigured()
        val data = message.toDto().toFirestoreMap().toMutableMap()
        data["timestamp"] = FieldValue.serverTimestamp()

        val threadRef = firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .document(threadId)

        val messageRef = threadRef
            .collection(FirebaseCollections.MESSAGES)
            .add(data)
            .await()

        threadRef.update(
            mapOf(
                "lastMessage" to mapOf(
                    "text" to message.text,
                    "senderId" to message.senderId,
                    "senderName" to message.senderName,
                    "timestamp" to FieldValue.serverTimestamp()
                ),
                "updatedAt" to FieldValue.serverTimestamp()
            )
        ).await()

        return messageRef.id
    }

    override fun observeThreads(currentUserId: String): Flow<List<MessageThread>> = callbackFlow {
        val state = FirebaseInitializer.currentState()
        if (state is FirebaseInitializationState.NotConfigured) {
            trySend(emptyList())
            close()
            return@callbackFlow
        }

        val listener = firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .whereArrayContains("participants", currentUserId)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    close(error)
                    return@addSnapshotListener
                }
                if (snapshot != null) {
                    val threads = snapshot.documents.mapNotNull { doc ->
                        if (doc.exists()) doc.toMessageThreadDto().toDomain() else null
                    }
                    trySend(threads)
                }
            }

        awaitClose {
            listener.remove()
        }
    }

    override fun observeMessages(threadId: String): Flow<List<ChatMessage>> = callbackFlow {
        val state = FirebaseInitializer.currentState()
        if (state is FirebaseInitializationState.NotConfigured) {
            trySend(emptyList())
            close()
            return@callbackFlow
        }

        val listener = firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .document(threadId)
            .collection(FirebaseCollections.MESSAGES)
            .orderBy("timestamp", Query.Direction.ASCENDING)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    close(error)
                    return@addSnapshotListener
                }
                if (snapshot != null) {
                    val messages = snapshot.documents.mapNotNull { doc ->
                        if (doc.exists()) doc.toChatMessageDto().toDomain() else null
                    }
                    trySend(messages)
                }
            }

        awaitClose {
            listener.remove()
        }
    }

    override suspend fun deleteMessage(threadId: String, messageId: String) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.MESSAGE_THREADS)
            .document(threadId)
            .collection(FirebaseCollections.MESSAGES)
            .document(messageId)
            .delete()
            .await()
    }

    override suspend fun uploadChatImage(threadId: String, photoId: String, imageBytes: ByteArray): String {
        requireFirebaseConfigured()
        val storageRef = FirebaseStorage.getInstance().reference
        val photoRef = storageRef.child("chat_attachments/$threadId/$photoId.jpg")
        photoRef.putBytes(imageBytes).await()
        return photoRef.downloadUrl.await().toString()
    }
}

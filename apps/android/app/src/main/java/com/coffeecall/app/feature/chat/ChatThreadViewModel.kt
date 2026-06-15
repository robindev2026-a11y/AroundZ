package com.coffeecall.app.feature.chat

import android.app.Application
import android.content.Context
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.core.session.SessionPreferencesRepository
import com.coffeecall.app.data.repository.FirebaseMessageThreadRepository
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.data.repository.FirebaseReportRepository
import com.coffeecall.app.data.repository.FirebaseUserRepository
import com.coffeecall.app.domain.model.ChatMessage
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.MessageType
import com.coffeecall.app.domain.repository.MessageThreadRepository
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.domain.repository.ReportRepository
import com.coffeecall.app.domain.repository.UserRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID

data class ChatThreadUiState(
    val messages: List<ChatMessage> = emptyList(),
    val drift: DriftPost? = null,
    val isLoading: Boolean = false,
    val isSending: Boolean = false,
    val error: String? = null,
    val currentUserId: String = "",
    val currentUserName: String = "",
    val blockedUsers: List<String> = emptyList()
)

class ChatThreadViewModel(
    application: Application,
    private val threadId: String,
    private val threadRepository: MessageThreadRepository = FirebaseMessageThreadRepository(),
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val reportRepository: ReportRepository = FirebaseReportRepository(),
    private val sessionRepository: SessionPreferencesRepository = SessionPreferencesRepository(application),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
) : AndroidViewModel(application) {

    private val _uiState = MutableStateFlow(ChatThreadUiState())
    val uiState: StateFlow<ChatThreadUiState> = _uiState.asStateFlow()

    private val sharedPrefs = application.getSharedPreferences("coffeecall_blocked", Context.MODE_PRIVATE)

    init {
        loadData()
        observeMessages()
        loadBlockedUsers()
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val currentUid = auth.currentUser?.uid ?: ""
            val session = sessionRepository.currentState()
            _uiState.update {
                it.copy(
                    currentUserId = currentUid,
                    currentUserName = session.profileName.ifBlank { "You" }
                )
            }

            runCatching {
                val post = postRepository.getPost(threadId) // Thread ID matches post ID
                if (post != null) {
                    _uiState.update { it.copy(drift = post) }
                } else {
                    loadMockPost()
                }
            }.onFailure {
                loadMockPost()
            }
            _uiState.update { it.copy(isLoading = false) }
        }
    }

    private fun loadMockPost() {
        val mockPost = DriftPost(
            id = threadId,
            title = "Specialty Coffee Tasting",
            creatorId = "mock_host_123",
            creatorName = "Siddharth",
            category = com.coffeecall.app.domain.model.DriftCategory.Coffee,
            location = "Koramangala, Bangalore",
            meetingPoint = "Third Wave Coffee"
        )
        _uiState.update { it.copy(drift = mockPost) }
    }

    private fun observeMessages() {
        val currentUid = auth.currentUser?.uid
        if (currentUid.isNullOrBlank()) {
            loadMockMessages()
            return
        }

        threadRepository.observeMessages(threadId)
            .onEach { messagesList ->
                _uiState.update { it.copy(messages = messagesList) }
            }
            .catch { exception ->
                if (exception is FirebaseUnavailableException) {
                    loadMockMessages()
                } else {
                    _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to observe messages") }
                }
            }
            .launchIn(viewModelScope)
    }

    private fun loadMockMessages() {
        val mockMessages = listOf(
            ChatMessage(
                id = "m1",
                senderId = "mock_host_123",
                senderName = "Siddharth",
                text = "Welcome to the tasting thread! Looking forward to meeting everyone.",
                timestamp = java.util.Date(System.currentTimeMillis() - 600000),
                type = MessageType.Text
            ),
            ChatMessage(
                id = "m2",
                senderId = "system",
                senderName = "System",
                text = "Albin joined the Drift!",
                timestamp = java.util.Date(System.currentTimeMillis() - 300000),
                type = MessageType.System
            )
        )
        _uiState.update { it.copy(messages = mockMessages) }
    }

    fun sendMessage(text: String) {
        val trimmed = text.trim()
        if (trimmed.isEmpty()) return

        viewModelScope.launch {
            _uiState.update { it.copy(isSending = true) }
            val currentUid = uiState.value.currentUserId
            val currentName = uiState.value.currentUserName

            val message = ChatMessage(
                id = UUID.randomUUID().toString(),
                senderId = currentUid,
                senderName = currentName,
                text = trimmed,
                type = MessageType.Text
            )

            runCatching {
                threadRepository.addMessage(threadId, message)
            }.onFailure { exception ->
                if (exception is FirebaseUnavailableException) {
                    val updated = uiState.value.messages.toMutableList().apply {
                        add(message.copy(timestamp = java.util.Date()))
                    }
                    _uiState.update { it.copy(messages = updated) }
                } else {
                    _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to send message") }
                }
            }
            _uiState.update { it.copy(isSending = false) }
        }
    }

    fun sendImageMessage(imageBytes: ByteArray) {
        viewModelScope.launch {
            _uiState.update { it.copy(isSending = true) }
            val currentUid = uiState.value.currentUserId
            val currentName = uiState.value.currentUserName
            val photoId = UUID.randomUUID().toString()

            runCatching {
                val downloadUrl = threadRepository.uploadChatImage(threadId, photoId, imageBytes)
                val message = ChatMessage(
                    id = photoId,
                    senderId = currentUid,
                    senderName = currentName,
                    text = downloadUrl,
                    type = MessageType.Image
                )
                threadRepository.addMessage(threadId, message)
            }.onFailure { exception ->
                _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to upload image") }
            }
            _uiState.update { it.copy(isSending = false) }
        }
    }

    fun sendLocationMessage(locationDescription: String) {
        val trimmed = locationDescription.trim()
        if (trimmed.isEmpty()) return

        viewModelScope.launch {
            _uiState.update { it.copy(isSending = true) }
            val currentUid = uiState.value.currentUserId
            val currentName = uiState.value.currentUserName

            val message = ChatMessage(
                id = UUID.randomUUID().toString(),
                senderId = currentUid,
                senderName = currentName,
                text = trimmed,
                type = MessageType.Location
            )

            runCatching {
                threadRepository.addMessage(threadId, message)
            }.onFailure { exception ->
                _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to send location") }
            }
            _uiState.update { it.copy(isSending = false) }
        }
    }

    fun deleteMessage(message: ChatMessage) {
        viewModelScope.launch {
            runCatching {
                threadRepository.deleteMessage(threadId, message.id)
            }.onFailure { exception ->
                if (exception is FirebaseUnavailableException) {
                    val updated = uiState.value.messages.filter { it.id != message.id }
                    _uiState.update { it.copy(messages = updated) }
                } else {
                    _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to delete message") }
                }
            }
        }
    }

    fun reportDrift(reason: String, onDone: (Boolean) -> Unit) {
        viewModelScope.launch {
            val currentUid = uiState.value.currentUserId
            runCatching {
                reportRepository.reportPost(threadId, currentUid, reason)
                onDone(true)
            }.onFailure {
                onDone(false)
            }
        }
    }

    fun blockUser(name: String, onDone: (Boolean) -> Unit) {
        viewModelScope.launch {
            val currentUid = uiState.value.currentUserId
            val blocked = uiState.value.blockedUsers.toMutableList()
            if (!blocked.contains(name)) {
                blocked.add(name)
                sharedPrefs.edit().putStringSet("blocked_users", blocked.toSet()).apply()
                _uiState.update { it.copy(blockedUsers = blocked) }
            }

            runCatching {
                userRepository.blockUser(currentUid, name)
                onDone(true)
            }.onFailure {
                onDone(false)
            }
        }
    }

    fun leaveDrift(onDone: (Boolean) -> Unit) {
        viewModelScope.launch {
            val currentUid = uiState.value.currentUserId
            val session = sessionRepository.currentState()
            val initials = session.profileInitials.ifBlank { "U" }
            runCatching {
                postRepository.leavePost(threadId, currentUid, initials)
                onDone(true)
            }.onFailure {
                onDone(false)
            }
        }
    }

    private fun loadBlockedUsers() {
        val set = sharedPrefs.getStringSet("blocked_users", emptySet()) ?: emptySet()
        _uiState.update { it.copy(blockedUsers = set.toList()) }
    }

    companion object {
        fun factory(application: Application, threadId: String): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    ChatThreadViewModel(application, threadId) as T
            }
    }
}

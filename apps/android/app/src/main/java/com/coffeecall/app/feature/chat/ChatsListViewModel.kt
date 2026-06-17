package com.coffeecall.app.feature.chat

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.data.repository.RepositoryProvider
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.MessageThread
import com.coffeecall.app.domain.repository.MessageThreadRepository
import com.coffeecall.app.domain.repository.PostRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.update

data class ChatThreadItem(
    val thread: MessageThread,
    val post: DriftPost?
)

data class ChatsListUiState(
    val threads: List<ChatThreadItem> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

class ChatsListViewModel(
    application: Application,
    private val threadRepository: MessageThreadRepository = RepositoryProvider.messageThreadRepository,
    private val postRepository: PostRepository = RepositoryProvider.postRepository,
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
) : AndroidViewModel(application) {

    private val _uiState = MutableStateFlow(ChatsListUiState())
    val uiState: StateFlow<ChatsListUiState> = _uiState.asStateFlow()

    init {
        observeThreads()
    }

    private fun observeThreads() {
        val currentUserId = auth.currentUser?.uid
        if (currentUserId.isNullOrBlank()) {
            loadMockThreads()
            return
        }

        _uiState.update { it.copy(isLoading = true, error = null) }

        threadRepository.observeThreads(currentUserId)
            .onEach { threads ->
                val items = threads.map { thread ->
                    val post = postRepository.getPost(thread.postId)
                    ChatThreadItem(thread, post)
                }
                _uiState.update { it.copy(threads = items, isLoading = false) }
            }
            .catch { exception ->
                if (exception is FirebaseUnavailableException) {
                    loadMockThreads()
                } else {
                    _uiState.update { it.copy(isLoading = false, error = exception.localizedMessage ?: "Failed to load chats") }
                }
            }
            .launchIn(viewModelScope)
    }

    private fun loadMockThreads() {
        val mockThread = MessageThread(
            id = "mock_thread_1",
            postId = "mock_post_1",
            participants = listOf("user123", "host456"),
            lastMessage = com.coffeecall.app.domain.model.ThreadLastMessage(
                text = "Let's meet near the entrance!",
                senderId = "host456",
                senderName = "Siddharth",
                timestamp = java.util.Date()
            )
        )
        val mockPost = DriftPost(
            id = "mock_post_1",
            title = "Specialty Coffee Tasting",
            creatorId = "host456",
            creatorName = "Siddharth",
            category = com.coffeecall.app.domain.model.DriftCategory.Coffee
        )
        _uiState.update {
            it.copy(
                threads = listOf(ChatThreadItem(mockThread, mockPost)),
                isLoading = false
            )
        }
    }

    companion object {
        fun factory(application: Application): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    ChatsListViewModel(application) as T
            }
    }
}

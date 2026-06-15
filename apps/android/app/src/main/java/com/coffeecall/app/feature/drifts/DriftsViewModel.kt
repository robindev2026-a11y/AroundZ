package com.coffeecall.app.feature.drifts

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.repository.PostRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID

data class DriftsUiState(
    val hostedDrifts: List<DriftPost> = emptyList(),
    val joinedDrifts: List<DriftPost> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

class DriftsViewModel(
    application: Application,
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
) : AndroidViewModel(application) {

    private val _uiState = MutableStateFlow(DriftsUiState())
    val uiState: StateFlow<DriftsUiState> = _uiState.asStateFlow()

    init {
        loadDrifts()
    }

    fun loadDrifts() {
        val currentUserId = auth.currentUser?.uid
        if (currentUserId.isNullOrBlank()) {
            loadMockDrifts()
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            runCatching {
                val hosted = postRepository.getHostedPosts(currentUserId)
                val joined = postRepository.getJoinedPosts(currentUserId)
                    .filter { it.creatorId != currentUserId }
                _uiState.update {
                    it.copy(
                        hostedDrifts = hosted,
                        joinedDrifts = joined,
                        isLoading = false
                    )
                }
            }.onFailure { exception ->
                if (exception is FirebaseUnavailableException) {
                    loadMockDrifts()
                } else {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = exception.localizedMessage ?: "Failed to load Drifts"
                        )
                    }
                }
            }
        }
    }

    private fun loadMockDrifts() {
        val mockHosted = listOf(
            DriftPost(
                id = UUID.randomUUID().toString(),
                title = "Morning Stroll & Filter Coffee",
                location = "Indiranagar, Bangalore",
                time = "7:00 AM",
                date = "Tomorrow",
                creatorId = "mock_user",
                creatorName = "You",
                category = com.coffeecall.app.domain.model.DriftCategory.Walk,
                spotsLeft = 4,
                capacity = 5,
                participantCount = 1,
                participantInitials = listOf("Y")
            )
        )
        val mockJoined = listOf(
            DriftPost(
                id = "mock_joined_1",
                title = "Specialty Coffee Tasting",
                location = "Koramangala, Bangalore",
                time = "4:00 PM",
                date = "Today",
                creatorId = "mock_host_123",
                creatorName = "Siddharth",
                category = com.coffeecall.app.domain.model.DriftCategory.Coffee,
                spotsLeft = 3,
                capacity = 5,
                participantCount = 2,
                participantInitials = listOf("AP", "SR")
            )
        )
        _uiState.update {
            it.copy(
                hostedDrifts = mockHosted,
                joinedDrifts = mockJoined,
                isLoading = false
            )
        }
    }

    companion object {
        fun factory(application: Application): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    DriftsViewModel(application) as T
            }
    }
}

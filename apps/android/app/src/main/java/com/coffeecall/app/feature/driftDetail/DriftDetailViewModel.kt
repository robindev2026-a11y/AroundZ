package com.coffeecall.app.feature.driftDetail

import android.app.Application
import android.content.Context
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.core.session.SessionPreferencesRepository
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.data.repository.FirebaseUserRepository
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.JoinRequest
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.domain.repository.UserRepository
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

data class DriftDetailUiState(
    val drift: DriftPost? = null,
    val joinStatus: JoinStatus = JoinStatus.NotJoined,
    val participants: List<ParticipantDetail> = emptyList(),
    val otherActiveDrifts: List<DriftPost> = emptyList(),
    val hostProfile: UserProfile? = null,
    val isLoading: Boolean = false,
    val isActionLoading: Boolean = false,
    val error: String? = null,
    val isReminderSet: Boolean = false,
    val showCalendarConfirmation: Boolean = false,
    val showCalendarDisclaimer: Boolean = false,
    val currentUserId: String = ""
)

enum class JoinStatus {
    NotJoined,
    Requested,
    Joined,
    Full,
    Ended
}

data class ParticipantDetail(
    val name: String,
    val initials: String,
    val interests: List<String>,
    val joinTimeDescription: String = "Joined recently"
)

class DriftDetailViewModel(
    application: Application,
    private val postId: String,
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val sessionRepository: SessionPreferencesRepository = SessionPreferencesRepository(application),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
) : AndroidViewModel(application) {

    private val _uiState = MutableStateFlow(DriftDetailUiState())
    val uiState: StateFlow<DriftDetailUiState> = _uiState.asStateFlow()

    private val sharedPrefs = application.getSharedPreferences("coffeecall_reminders", Context.MODE_PRIVATE)

    init {
        loadData()
        checkReminderStatus()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val currentUid = auth.currentUser?.uid ?: ""
            _uiState.update { it.copy(currentUserId = currentUid) }

            val session = sessionRepository.currentState()
            val userInitials = session.profileInitials.ifBlank { "U" }

            runCatching {
                val post = postRepository.getPost(postId)
                if (post != null) {
                    val status = computeJoinStatus(post, currentUid, userInitials)
                    _uiState.update {
                        it.copy(
                            drift = post,
                            joinStatus = status,
                            isLoading = false
                        )
                    }
                    fetchParticipants(post)
                    fetchHostDetails(post.creatorId)
                } else {
                    // Fallback to Mock Drift if offline or not found
                    loadMockDrift()
                }
            }.onFailure { exception ->
                if (exception is FirebaseUnavailableException) {
                    loadMockDrift()
                } else {
                    _uiState.update { it.copy(isLoading = false, error = exception.localizedMessage ?: "Failed to load post") }
                }
            }
        }
    }

    private fun checkReminderStatus() {
        val key = "calendar_added_$postId"
        val isSet = sharedPrefs.getBoolean(key, false)
        _uiState.update { it.copy(isReminderSet = isSet) }
    }

    fun setReminder() {
        val state = uiState.value
        if (state.isReminderSet) {
            _uiState.update { it.copy(showCalendarDisclaimer = true) }
        } else {
            _uiState.update { it.copy(showCalendarConfirmation = true) }
        }
    }

    fun dismissCalendarConfirmation() {
        _uiState.update { it.copy(showCalendarConfirmation = false) }
    }

    fun dismissCalendarDisclaimer() {
        _uiState.update { it.copy(showCalendarDisclaimer = false) }
    }

    fun confirmAddReminder() {
        _uiState.update { it.copy(showCalendarConfirmation = false, isReminderSet = true) }
        sharedPrefs.edit().putBoolean("calendar_added_$postId", true).apply()
    }

    fun requestToJoin(message: String = "Hey, I'd love to join your drift!") {
        val drift = uiState.value.drift ?: return
        if (uiState.value.joinStatus != JoinStatus.NotJoined) return

        viewModelScope.launch {
            _uiState.update { it.copy(isActionLoading = true) }
            val currentUid = auth.currentUser?.uid ?: ""
            val session = sessionRepository.currentState()
            val currentName = session.profileName.ifBlank { "User" }
            val currentInitials = session.profileInitials.ifBlank { "U" }

            val timestamp = SimpleDateFormat("h:mm a", Locale.getDefault()).format(Date())
            val joinRequest = JoinRequest(
                id = UUID.randomUUID().toString(),
                userId = currentUid,
                userName = currentName,
                userInitials = currentInitials,
                userRole = "Member",
                message = message,
                timestamp = timestamp
            )

            runCatching {
                if (drift.joinMode == JoinMode.Open) {
                    postRepository.acceptJoinRequest(postId, joinRequest)
                } else {
                    postRepository.requestToJoin(postId, joinRequest)
                }
                loadData()
            }.onFailure { exception ->
                _uiState.update { it.copy(isActionLoading = false, error = exception.localizedMessage ?: "Action failed") }
            }
        }
    }

    fun cancelJoinRequest() {
        if (uiState.value.joinStatus != JoinStatus.Requested) return

        viewModelScope.launch {
            _uiState.update { it.copy(isActionLoading = true) }
            val currentUid = auth.currentUser?.uid ?: ""

            runCatching {
                postRepository.cancelJoinRequest(postId, currentUid)
                loadData()
            }.onFailure { exception ->
                _uiState.update { it.copy(isActionLoading = false, error = exception.localizedMessage ?: "Failed to cancel request") }
            }
        }
    }

    fun leaveDrift() {
        if (uiState.value.joinStatus != JoinStatus.Joined) return

        viewModelScope.launch {
            _uiState.update { it.copy(isActionLoading = true) }
            val currentUid = auth.currentUser?.uid ?: ""
            val session = sessionRepository.currentState()
            val initials = session.profileInitials.ifBlank { "U" }

            runCatching {
                postRepository.leavePost(postId, currentUid, initials)
                loadData()
            }.onFailure { exception ->
                _uiState.update { it.copy(isActionLoading = false, error = exception.localizedMessage ?: "Failed to leave drift") }
            }
        }
    }

    fun acceptJoinRequest(request: JoinRequest) {
        viewModelScope.launch {
            _uiState.update { it.copy(isActionLoading = true) }
            runCatching {
                postRepository.acceptJoinRequest(postId, request)
                loadData()
            }.onFailure { exception ->
                _uiState.update { it.copy(isActionLoading = false, error = exception.localizedMessage ?: "Failed to accept request") }
            }
        }
    }

    fun rejectJoinRequest(requestId: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isActionLoading = true) }
            runCatching {
                postRepository.rejectJoinRequest(postId, requestId)
                loadData()
            }.onFailure { exception ->
                _uiState.update { it.copy(isActionLoading = false, error = exception.localizedMessage ?: "Failed to reject request") }
            }
        }
    }

    private fun computeJoinStatus(drift: DriftPost, currentUid: String, userInitials: String): JoinStatus {
        val initialsClean = userInitials.trim().uppercase()
        val isMine = drift.creatorId == currentUid

        val isParticipant = drift.participantIds.contains(currentUid) ||
            (drift.participantIds.isEmpty() && drift.participantInitials.any { it.trim().uppercase() == initialsClean })

        val hasPendingRequest = drift.pendingRequests.any { req ->
            if (req.userId.isNotEmpty()) req.userId == currentUid
            else req.userInitials.trim().uppercase() == initialsClean
        }

        return when {
            drift.status == DriftStatus.Ended -> JoinStatus.Ended
            isMine -> JoinStatus.Joined
            isParticipant -> JoinStatus.Joined
            hasPendingRequest -> JoinStatus.Requested
            drift.spotsLeft == 0 -> JoinStatus.Full
            else -> JoinStatus.NotJoined
        }
    }

    private suspend fun fetchParticipants(post: DriftPost) {
        runCatching {
            val db = FirebaseFirestore.getInstance()
            val snap = db.collection("messageThreads").document(postId).get().await()
            if (snap.exists()) {
                val participantsList = snap.get("participants") as? List<*> ?: emptyList<Any>()
                val guestIds = participantsList.mapNotNull { it?.toString() }.filter { it != post.creatorId }

                if (guestIds.isEmpty()) {
                    _uiState.update { it.copy(participants = emptyList()) }
                    return
                }

                val details = mutableListOf<ParticipantDetail>()
                for (uid in guestIds) {
                    val userSnap = db.collection("users").document(uid).get().await()
                    if (userSnap.exists()) {
                        val name = userSnap.getString("name") ?: "Someone"
                        val initials = name.split(" ")
                            .mapNotNull { it.firstOrNull()?.toString() }
                            .joinToString("")
                            .uppercase()
                        val interests = userSnap.get("interestTags") as? List<*> ?: emptyList<Any>()
                        details.add(
                            ParticipantDetail(
                                name = name,
                                initials = if (initials.isEmpty()) "P" else initials,
                                interests = interests.mapNotNull { it?.toString() },
                                joinTimeDescription = "Joined recently"
                            )
                        )
                    }
                }
                _uiState.update { it.copy(participants = details) }
            } else {
                generateFallbackParticipants(post)
            }
        }.onFailure {
            generateFallbackParticipants(post)
        }
    }

    private fun generateFallbackParticipants(post: DriftPost) {
        val namesMap = mapOf(
            "LJ" to "Liam", "MM" to "Maya", "SJ" to "Sarah", "DG" to "Dev",
            "AL" to "Albin", "RI" to "Riya", "MA" to "Maya A.", "SR" to "Sneha", "KM" to "Karthik"
        )
        val interestsMap = mapOf(
            "LJ" to listOf("Walks", "Coffee", "Music"),
            "MM" to listOf("Coffee", "Walks", "Music"),
            "SJ" to listOf("Walks", "Coffee", "Music"),
            "DG" to listOf("Music", "Coffee", "Walks"),
            "AL" to listOf("Walks", "Coffee"),
            "RI" to listOf("Coffee", "Music"),
            "MA" to listOf("Movies", "Music"),
            "SR" to listOf("Walks", "Coffee"),
            "KM" to listOf("Movies", "Coffee")
        )

        val details = post.participantInitials.map { initials ->
            ParticipantDetail(
                name = namesMap[initials] ?: "Member",
                initials = initials,
                interests = interestsMap[initials] ?: listOf("Coffee")
            )
        }
        _uiState.update { it.copy(participants = details) }
    }

    private suspend fun fetchHostDetails(hostId: String) {
        runCatching {
            val profile = userRepository.getUser(hostId)
            if (profile != null) {
                _uiState.update { it.copy(hostProfile = profile) }
            }

            // Fetch other active drifts from host
            val db = FirebaseFirestore.getInstance()
            val snap = db.collection("posts")
                .whereEqualTo("creatorId", hostId)
                .get()
                .await()

            val otherDrifts = snap.documents.mapNotNull { doc ->
                if (doc.id == postId) return@mapNotNull null
                val data = doc.data ?: return@mapNotNull null
                val statusStr = data["status"] as? String ?: "OPEN"
                if (statusStr.uppercase() == "ENDED") return@mapNotNull null
                
                // Construct a post model from doc
                val title = data["title"] as? String ?: ""
                val desc = data["description"] as? String ?: ""
                val loc = data["location"] as? String ?: ""
                val time = data["time"] as? String ?: ""
                val date = data["date"] as? String ?: ""
                
                DriftPost(
                    id = doc.id,
                    title = title,
                    description = desc,
                    location = loc,
                    time = time,
                    date = date,
                    status = DriftStatus.fromFirestore(statusStr)
                )
            }
            _uiState.update { it.copy(otherActiveDrifts = otherDrifts) }
        }
    }

    private fun loadMockDrift() {
        val mockPost = DriftPost(
            id = postId,
            title = "Specialty Coffee Tasting",
            description = "Let's explore some local light roasts and chat about brew methods. Perfect for coffee nerds or beginners!",
            location = "Koramangala, Bangalore",
            meetingPoint = "Third Wave Coffee, Koramangala 4th Block",
            time = "4:00 PM",
            endTime = "5:30 PM",
            date = "Today",
            creatorId = "mock_host_123",
            creatorName = "Siddharth",
            creatorImageUrl = "",
            creatorVerified = true,
            participantCount = 2,
            capacity = 5,
            spotsLeft = 3,
            vibeTags = listOf("Educational", "Casual", "Coffee Nerd"),
            whatToBring = listOf("An open palate", "Questions"),
            participantInitials = listOf("AP", "SR"),
            participantIds = listOf("AP", "SR"),
            latitude = 12.9352,
            longitude = 77.6245,
            joinMode = JoinMode.Approval
        )
        val mockProfile = UserProfile(
            uid = "mock_host_123",
            name = "Siddharth",
            bio = "Always hunting for the cleanest filter coffee. In love with Yirgacheffe profiles.",
            initials = "S",
            interests = listOf("Filter Coffee", "Roasting", "Indie Music"),
            availabilityWeekdayEvenings = true
        )
        val mockOther = listOf(
            DriftPost(
                id = UUID.randomUUID().toString(),
                title = "Morning Stroll & Filter Coffee",
                location = "Indiranagar, Bangalore",
                time = "7:00 AM",
                date = "Tomorrow"
            )
        )

        _uiState.update {
            it.copy(
                drift = mockPost,
                joinStatus = JoinStatus.NotJoined,
                hostProfile = mockProfile,
                otherActiveDrifts = mockOther,
                isLoading = false
            )
        }
        generateFallbackParticipants(mockPost)
    }

    companion object {
        fun factory(application: Application, postId: String): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    DriftDetailViewModel(application, postId) as T
            }
    }
}

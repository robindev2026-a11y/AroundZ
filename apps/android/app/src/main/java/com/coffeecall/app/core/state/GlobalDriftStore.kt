package com.coffeecall.app.core.state

import android.app.Application
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinRequest
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.feature.discovery.DiscoveryNotification
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class GlobalDriftStore(
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    private val _drifts = MutableStateFlow<List<DriftPost>>(emptyList())
    val drifts: StateFlow<List<DriftPost>> = _drifts.asStateFlow()

    private val _notifications = MutableStateFlow<List<DiscoveryNotification>>(emptyList())
    val notifications: StateFlow<List<DiscoveryNotification>> = _notifications.asStateFlow()

    val hostedDrifts: StateFlow<List<DriftPost>> = MutableStateFlow(emptyList())
    val joinedDrifts: StateFlow<List<DriftPost>> = MutableStateFlow(emptyList())

    suspend fun fetch() {
        val userId = auth.currentUser?.uid ?: return
        runCatching {
            val hosted = postRepository.getHostedPosts(userId)
            val joined = postRepository.getJoinedPosts(userId).filter { it.creatorId != userId }
            _drifts.value = hosted + joined
            updateDerivedStates()
        }.onFailure { error ->
            if (error is FirebaseUnavailableException) {
                _drifts.value = emptyList()
                updateDerivedStates()
            }
        }
    }

    suspend fun refresh() {
        fetch()
    }

    fun getPost(postId: String): DriftPost? =
        _drifts.value.firstOrNull { it.id == postId }

    suspend fun fetchPost(postId: String): DriftPost? {
        getPost(postId)?.let { return it }
        return runCatching {
            postRepository.getPost(postId)?.also { post ->
                _drifts.value = _drifts.value + post
                updateDerivedStates()
            }
        }.getOrNull()
    }

    suspend fun createPost(post: DriftPost) {
        postRepository.createPostWithThread(post)
        refresh()
    }

    suspend fun requestToJoin(postId: String, request: JoinRequest) {
        val post = _drifts.value.firstOrNull { it.id == postId } ?: return
        if (post.joinMode == com.coffeecall.app.domain.model.JoinMode.Open) {
            postRepository.acceptJoinRequest(postId, request)
        } else {
            postRepository.requestToJoin(postId, request)
        }
        refresh()
    }

    suspend fun cancelJoinRequest(postId: String, userId: String) {
        postRepository.cancelJoinRequest(postId, userId)
        refresh()
    }

    suspend fun acceptJoinRequest(postId: String, request: JoinRequest) {
        postRepository.acceptJoinRequest(postId, request)
        refresh()
    }

    suspend fun rejectJoinRequest(postId: String, requestId: String) {
        postRepository.rejectJoinRequest(postId, requestId)
        refresh()
    }

    suspend fun leavePost(postId: String, userId: String, userInitials: String) {
        postRepository.leavePost(postId, userId, userInitials)
        refresh()
    }

    suspend fun updatePostStatus(postId: String, status: DriftStatus) {
        postRepository.updatePostStatus(postId, status)
        refresh()
    }

    suspend fun upsertPost(post: DriftPost) {
        postRepository.upsertPost(post)
        refresh()
    }

    private fun updateDerivedStates() {
        val userId = auth.currentUser?.uid ?: ""
        val allDrifts = _drifts.value
        (hostedDrifts as MutableStateFlow).value = allDrifts.filter { it.creatorId == userId }
        (joinedDrifts as MutableStateFlow).value = allDrifts.filter {
            it.creatorId != userId && (it.participantIds.contains(userId) || it.participantInitials.isNotEmpty())
        }
        _notifications.value = buildNotifications(allDrifts)
    }

    private fun buildNotifications(drifts: List<DriftPost>): List<DiscoveryNotification> {
        val notifications = mutableListOf<DiscoveryNotification>()
        for (drift in drifts) {
            for (request in drift.pendingRequests) {
                notifications.add(
                    DiscoveryNotification(
                        id = "request-${drift.id}-${request.id}",
                        driftId = drift.id,
                        title = "${request.userName.ifBlank { "Someone" }} wants to join",
                        body = drift.title.ifBlank { drift.hook.ifBlank { "Your ${drift.category.firestoreValue} drift" } },
                        timestamp = request.timestamp.ifBlank { "Just now" },
                        category = drift.category.firestoreValue
                    )
                )
            }
            if (drift.status != DriftStatus.Open || drift.updatedAt != null) {
                val title = when (drift.status) {
                    DriftStatus.StartingSoon -> "Starting soon"
                    DriftStatus.Tonight -> "Happening tonight"
                    DriftStatus.Ended -> "Drift ended"
                    DriftStatus.Open -> "Drift updated"
                }
                notifications.add(
                    DiscoveryNotification(
                        id = "update-${drift.id}-${drift.updatedAt?.time ?: drift.status.firestoreValue}",
                        driftId = drift.id,
                        title = title,
                        body = drift.title.ifBlank { drift.hook.ifBlank { "Open this drift for details" } },
                        timestamp = drift.updatedAt.notificationTimestamp(),
                        category = drift.category.firestoreValue
                    )
                )
            }
        }
        return notifications
    }

    private fun Date?.notificationTimestamp(): String =
        this?.let { SimpleDateFormat("MMM d", Locale.getDefault()).format(it) } ?: "Recently"

    companion object {
        @Volatile
        private var INSTANCE: GlobalDriftStore? = null

        fun getInstance(application: Application): GlobalDriftStore =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: GlobalDriftStore().also { INSTANCE = it }
            }
    }
}

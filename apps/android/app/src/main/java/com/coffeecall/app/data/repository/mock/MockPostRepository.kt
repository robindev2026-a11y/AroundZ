package com.coffeecall.app.data.repository.mock

import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.JoinRequest
import com.coffeecall.app.domain.repository.PostRepository
import java.util.UUID

class MockPostRepository : PostRepository {
    private val posts = mutableMapOf<String, DriftPost>()

    init {
        val mockHosted = DriftPost(
            id = "mock_hosted_1",
            title = "Morning Stroll & Filter Coffee",
            description = "A relaxed morning walk followed by filter coffee at a local café.",
            location = "Indiranagar, Bangalore",
            meetingPoint = "Third Wave Coffee, 100 Feet Road",
            time = "7:00 AM",
            date = "Tomorrow",
            creatorId = "mock_user",
            creatorName = "You",
            category = DriftCategory.Walk,
            spotsLeft = 3,
            capacity = 5,
            participantCount = 2,
            participantInitials = listOf("Y", "AP"),
            participantIds = listOf("mock_user", "mock_albin"),
            latitude = 12.9719,
            longitude = 77.6412,
            joinMode = JoinMode.Open,
            locationGeoHash = "tdrb1"
        )
        val mockJoined = DriftPost(
            id = "mock_joined_1",
            title = "Specialty Coffee Tasting",
            description = "Let's explore some local light roasts and chat about brew methods.",
            location = "Koramangala, Bangalore",
            meetingPoint = "Third Wave Coffee, Koramangala 4th Block",
            time = "4:00 PM",
            date = "Today",
            creatorId = "mock_host_123",
            creatorName = "Siddharth",
            category = DriftCategory.Coffee,
            spotsLeft = 3,
            capacity = 5,
            participantCount = 2,
            participantInitials = listOf("AP", "SR"),
            participantIds = listOf("mock_albin", "mock_sneha"),
            latitude = 12.9352,
            longitude = 77.6245,
            joinMode = JoinMode.Approval,
            locationGeoHash = "tdrbc"
        )
        val mockDiscovery = DriftPost(
            id = "mock_discovery_1",
            title = "Evening Board Games & Chai",
            description = "Bring your favorite board game or try ours. Chai and snacks provided!",
            location = "HSR Layout, Bangalore",
            time = "6:30 PM",
            date = "Tonight",
            creatorId = "mock_host_456",
            creatorName = "Priya",
            category = DriftCategory.Gaming,
            spotsLeft = 2,
            capacity = 6,
            participantCount = 4,
            participantInitials = listOf("PK", "RJ", "DG", "MA"),
            latitude = 12.9141,
            longitude = 77.6411,
            joinMode = JoinMode.Open,
            locationGeoHash = "tdrb2"
        )
        posts[mockHosted.id] = mockHosted
        posts[mockJoined.id] = mockJoined
        posts[mockDiscovery.id] = mockDiscovery
    }

    override suspend fun getPost(postId: String): DriftPost? = posts[postId]

    override suspend fun fetchRecentPosts(limit: Long): List<DriftPost> =
        posts.values.sortedByDescending { it.createdAt }.take(limit.toInt())

    override suspend fun fetchNearbyPosts(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        limit: Long
    ): List<DriftPost> =
        posts.values.filter { it.status != DriftStatus.Ended }.take(limit.toInt())

    override suspend fun upsertPost(post: DriftPost) {
        posts[post.id] = post
    }

    override suspend fun createPostWithThread(post: DriftPost) {
        posts[post.id] = post
    }

    override suspend fun updatePostStatus(postId: String, status: DriftStatus) {
        posts[postId]?.let { posts[postId] = it.copy(status = status) }
    }

    override suspend fun requestToJoin(postId: String, request: JoinRequest) {
        posts[postId]?.let { post ->
            posts[postId] = post.copy(pendingRequests = post.pendingRequests + request)
        }
    }

    override suspend fun cancelJoinRequest(postId: String, userId: String) {
        posts[postId]?.let { post ->
            posts[postId] = post.copy(
                pendingRequests = post.pendingRequests.filter { it.userId != userId }
            )
        }
    }

    override suspend fun acceptJoinRequest(postId: String, request: JoinRequest) {
        posts[postId]?.let { post ->
            val newInitials = if (request.userInitials.isNotBlank() && request.userInitials !in post.participantInitials) {
                post.participantInitials + request.userInitials
            } else post.participantInitials
            val newIds = if (request.userId.isNotBlank() && request.userId !in post.participantIds) {
                post.participantIds + request.userId
            } else post.participantIds
            posts[postId] = post.copy(
                pendingRequests = post.pendingRequests.filter { it.id != request.id },
                participantInitials = newInitials,
                participantIds = newIds,
                participantCount = post.participantCount + 1,
                spotsLeft = maxOf(post.spotsLeft - 1, 0)
            )
        }
    }

    override suspend fun rejectJoinRequest(postId: String, requestId: String) {
        posts[postId]?.let { post ->
            posts[postId] = post.copy(
                pendingRequests = post.pendingRequests.filter { it.id != requestId }
            )
        }
    }

    override suspend fun leavePost(postId: String, userId: String, userInitials: String) {
        posts[postId]?.let { post ->
            val cleanInitials = userInitials.trim().uppercase()
            posts[postId] = post.copy(
                participantIds = post.participantIds.filter { it != userId },
                participantInitials = post.participantInitials.filter { it.trim().uppercase() != cleanInitials },
                participantCount = maxOf(post.participantCount - 1, 1),
                spotsLeft = post.spotsLeft + 1
            )
        }
    }

    override suspend fun getHostedPosts(userId: String): List<DriftPost> =
        posts.values.filter { it.creatorId == userId }

    override suspend fun getJoinedPosts(userId: String): List<DriftPost> =
        posts.values.filter { it.participantIds.contains(userId) || it.creatorId == userId }

    override suspend fun fetchAllPosts(): List<DriftPost> =
        posts.values.toList()
}

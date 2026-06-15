package com.coffeecall.app.domain.repository

import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinRequest

interface PostRepository {
    suspend fun getPost(postId: String): DriftPost?
    suspend fun fetchRecentPosts(limit: Long = 50): List<DriftPost>
    suspend fun fetchNearbyPosts(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 10.0,
        limit: Long = 80
    ): List<DriftPost>
    suspend fun upsertPost(post: DriftPost)
    suspend fun createPostWithThread(post: DriftPost)
    suspend fun updatePostStatus(postId: String, status: DriftStatus)
    suspend fun requestToJoin(postId: String, request: JoinRequest)
    suspend fun cancelJoinRequest(postId: String, userId: String)
    suspend fun acceptJoinRequest(postId: String, request: JoinRequest)
    suspend fun rejectJoinRequest(postId: String, requestId: String)
    suspend fun leavePost(postId: String, userId: String, userInitials: String)
    suspend fun getHostedPosts(userId: String): List<DriftPost>
    suspend fun getJoinedPosts(userId: String): List<DriftPost>
}

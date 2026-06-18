package com.coffeecall.app.data.repository

import com.coffeecall.app.core.firebase.FirebaseCollections
import com.coffeecall.app.core.location.GeoHash
import com.coffeecall.app.core.location.haversineDistanceKm
import com.coffeecall.app.data.mapper.toDomain
import com.coffeecall.app.data.mapper.toDto
import com.coffeecall.app.data.mapper.toFirestoreMap
import com.coffeecall.app.data.mapper.toPostDto
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinRequest
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.domain.repository.PostRepository
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.SetOptions
import kotlinx.coroutines.tasks.await

class FirebasePostRepository(
    private val firestoreProvider: () -> FirebaseFirestore = { FirebaseFirestore.getInstance() }
) : PostRepository {
    override suspend fun getPost(postId: String): DriftPost? {
        requireFirebaseConfigured()
        val snapshot = firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .document(postId)
            .get()
            .await()

        return if (snapshot.exists()) snapshot.toPostDto().toDomain() else null
    }

    override suspend fun fetchRecentPosts(limit: Long): List<DriftPost> {
        requireFirebaseConfigured()
        return firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)
            .get()
            .await()
            .documents
            .mapNotNull { snapshot ->
                if (snapshot.exists()) snapshot.toPostDto().toDomain() else null
            }
    }

    override suspend fun fetchNearbyPosts(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        limit: Long
    ): List<DriftPost> {
        requireFirebaseConfigured()
        val geoHashPrefix = GeoHash.encode(latitude, longitude).take(GEOHASH_DISCOVERY_PREFIX_LENGTH)
        val firestore = firestoreProvider()
        val geoHashMatches = firestore
            .collection(FirebaseCollections.POSTS)
            .whereGreaterThanOrEqualTo("locationGeoHash", geoHashPrefix)
            .whereLessThanOrEqualTo("locationGeoHash", "$geoHashPrefix\uf8ff")
            .orderBy("locationGeoHash")
            .limit(limit)
            .get()
            .await()
            .documents
            .mapNotNull { snapshot ->
                if (snapshot.exists()) snapshot.toPostDto().toDomain() else null
            }

        val recentFallback = if (geoHashMatches.isEmpty()) fetchRecentPosts(limit) else emptyList()

        return (geoHashMatches + recentFallback)
            .distinctBy { it.id }
            .mapNotNull { post ->
                val postLatitude = post.latitude ?: return@mapNotNull null
                val postLongitude = post.longitude ?: return@mapNotNull null
                val distance = haversineDistanceKm(latitude, longitude, postLatitude, postLongitude)
                if (distance <= radiusKm) post.copy(distance = distance) else null
            }
            .filter { it.status != DriftStatus.Ended }
            .sortedBy { it.distance }
    }

    override suspend fun upsertPost(post: DriftPost) {
        requireFirebaseConfigured()
        val data = post.toDto().toFirestoreMap().toMutableMap()
        data["updatedAt"] = FieldValue.serverTimestamp()
        if (post.createdAt == null) {
            data.putIfAbsent("createdAt", FieldValue.serverTimestamp())
        }

        firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .document(post.id)
            .set(data, SetOptions.merge())
            .await()
    }

    override suspend fun createPostWithThread(post: DriftPost) {
        requireFirebaseConfigured()
        val firestore = firestoreProvider()
        val postRef = firestore.collection(FirebaseCollections.POSTS).document(post.id)
        val threadRef = firestore.collection(FirebaseCollections.MESSAGE_THREADS).document(post.id)
        val postData = post.toDto().toFirestoreMap().toMutableMap()

        postData["createdAt"] = FieldValue.serverTimestamp()
        postData.remove("updatedAt")

        // Write sequentially to avoid Code 7 permission errors
        postRef.set(postData).await()
        
        threadRef.set(
            mapOf(
                "postId" to post.id,
                "participants" to post.participantIds,
                "lastMessage" to mapOf(
                    "text" to "Drift created! Welcome to the chat room.",
                    "timestamp" to FieldValue.serverTimestamp(),
                    "senderId" to "system",
                    "senderName" to "System"
                )
            )
        ).await()
    }

    override suspend fun updatePostStatus(postId: String, status: DriftStatus) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .document(postId)
            .update(
                mapOf(
                    "status" to status.firestoreValue,
                    "updatedAt" to FieldValue.serverTimestamp()
                )
            )
            .await()
    }

    override suspend fun requestToJoin(postId: String, request: JoinRequest) {
        requireFirebaseConfigured()
        val requestMap = request.toDto().toFirestoreMap()
        firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .document(postId)
            .update("pendingRequests", FieldValue.arrayUnion(requestMap))
            .await()
    }

    override suspend fun cancelJoinRequest(postId: String, userId: String) {
        requireFirebaseConfigured()
        val firestore = firestoreProvider()
        val postRef = firestore.collection(FirebaseCollections.POSTS).document(postId)
        
        firestore.runTransaction { transaction ->
            val snapshot = transaction.get(postRef)
            if (!snapshot.exists()) {
                throw FirebaseUnavailableException("Post document not found")
            }
            val data = snapshot.data.orEmpty()
            @Suppress("UNCHECKED_CAST")
            val pendingRequestsData = data["pendingRequests"] as? List<Map<String, Any?>> ?: emptyList()
            val updatedPendingRequests = pendingRequestsData.filter { dict ->
                (dict["userId"] as? String) != userId
            }
            transaction.update(postRef, "pendingRequests", updatedPendingRequests)
            null
        }.await()
    }

    override suspend fun acceptJoinRequest(postId: String, request: JoinRequest) {
        requireFirebaseConfigured()
        val firestore = firestoreProvider()
        val postRef = firestore.collection(FirebaseCollections.POSTS).document(postId)
        val threadRef = firestore.collection(FirebaseCollections.MESSAGE_THREADS).document(postId)

        firestore.runTransaction { transaction ->
            val postDoc = transaction.get(postRef)
            if (!postDoc.exists()) {
                throw FirebaseUnavailableException("Post document not found")
            }
            val postData = postDoc.data.orEmpty()

            @Suppress("UNCHECKED_CAST")
            val pendingRequestsData = postData["pendingRequests"] as? List<Map<String, Any?>> ?: emptyList()
            val updatedPendingRequests = pendingRequestsData.filter { dict ->
                (dict["id"] as? String) != request.id
            }

            val requestInitials = request.userInitials.trim()
            @Suppress("UNCHECKED_CAST")
            val participantInitials = (postData["participantInitials"] as? List<*>)?.mapNotNull { it?.toString() } ?: emptyList()
            val updatedInitials = participantInitials.toMutableList()
            if (requestInitials.isNotEmpty() && !updatedInitials.contains(requestInitials)) {
                updatedInitials.add(requestInitials)
            }

            val participantCount = (postData["participantCount"] as? Number)?.toInt() ?: 1
            val capacity = (postData["capacity"] as? Number)?.toInt() ?: 5
            val newParticipantCount = participantCount + 1
            val newSpotsLeft = maxOf(capacity - newParticipantCount, 0)

            transaction.update(
                postRef,
                mapOf(
                    "pendingRequests" to updatedPendingRequests,
                    "participantInitials" to updatedInitials,
                    "participantIds" to FieldValue.arrayUnion(request.userId),
                    "participantCount" to newParticipantCount,
                    "spotsLeft" to newSpotsLeft
                )
            )
            null
        }.await()

        if (request.userId.isNotEmpty()) {
            threadRef.update(
                "participants", FieldValue.arrayUnion(request.userId)
            ).await()
        }
    }

    override suspend fun rejectJoinRequest(postId: String, requestId: String) {
        requireFirebaseConfigured()
        val firestore = firestoreProvider()
        val postRef = firestore.collection(FirebaseCollections.POSTS).document(postId)

        firestore.runTransaction { transaction ->
            val postDoc = transaction.get(postRef)
            if (!postDoc.exists()) {
                throw FirebaseUnavailableException("Post document not found")
            }
            val postData = postDoc.data.orEmpty()

            @Suppress("UNCHECKED_CAST")
            val pendingRequestsData = postData["pendingRequests"] as? List<Map<String, Any?>> ?: emptyList()
            val updatedPendingRequests = pendingRequestsData.filter { dict ->
                (dict["id"] as? String) != requestId
            }

            transaction.update(postRef, "pendingRequests", updatedPendingRequests)
            null
        }.await()
    }

    override suspend fun leavePost(postId: String, userId: String, userInitials: String) {
        requireFirebaseConfigured()
        val db = firestoreProvider()
        val postRef = db.collection(FirebaseCollections.POSTS).document(postId)
        val threadRef = db.collection(FirebaseCollections.MESSAGE_THREADS).document(postId)

        // 1. Remove from Message Thread FIRST
        threadRef.update(
            "participants", FieldValue.arrayRemove(userId)
        ).await()

        // 2. Delete Acceptance Documents
        val acceptancesSnap = db.collection(FirebaseCollections.ACCEPTANCES)
            .whereEqualTo("postId", postId)
            .whereEqualTo("acceptorId", userId)
            .get()
            .await()
        for (doc in acceptancesSnap.documents) {
            doc.reference.delete().await()
        }

        // 3. Update Post Metadata
        val postDoc = postRef.get().await()
        if (!postDoc.exists()) {
            throw FirebaseUnavailableException("Post document not found")
        }
        val postData = postDoc.data.orEmpty()

        val cleanInitials = userInitials.trim().uppercase()
        @Suppress("UNCHECKED_CAST")
        val participantInitials = (postData["participantInitials"] as? List<*>)?.mapNotNull { it?.toString() } ?: emptyList()
        val newInitials = participantInitials.filter { it.trim().uppercase() != cleanInitials }

        val participantCount = (postData["participantCount"] as? Number)?.toInt() ?: 1
        val newParticipantCount = maxOf(participantCount - 1, 1)

        val updateData = mutableMapOf<String, Any>(
            "participantInitials" to newInitials,
            "participantCount" to newParticipantCount,
            "spotsLeft" to FieldValue.increment(1),
            "participantIds" to FieldValue.arrayRemove(userId.trim())
        )

        postRef.update(updateData).await()
    }

    override suspend fun getHostedPosts(userId: String): List<DriftPost> {
        requireFirebaseConfigured()
        val snapshot = firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .whereEqualTo("creatorId", userId)
            .get()
            .await()
        return snapshot.documents.mapNotNull { doc ->
            if (doc.exists()) doc.toPostDto().toDomain() else null
        }
    }

    override suspend fun getJoinedPosts(userId: String): List<DriftPost> {
        requireFirebaseConfigured()
        val snapshot = firestoreProvider()
            .collection(FirebaseCollections.POSTS)
            .whereArrayContains("participantIds", userId)
            .get()
            .await()
        return snapshot.documents.mapNotNull { doc ->
            if (doc.exists()) doc.toPostDto().toDomain() else null
        }
    }

    private companion object {
        const val GEOHASH_DISCOVERY_PREFIX_LENGTH = 4
    }
}

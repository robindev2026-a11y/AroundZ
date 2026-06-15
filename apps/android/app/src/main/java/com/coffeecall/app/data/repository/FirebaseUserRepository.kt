package com.coffeecall.app.data.repository

import com.coffeecall.app.core.firebase.FirebaseCollections
import com.coffeecall.app.data.mapper.toDomain
import com.coffeecall.app.data.mapper.toDto
import com.coffeecall.app.data.mapper.toFirestoreMap
import com.coffeecall.app.data.mapper.toUserProfileDto
import com.coffeecall.app.domain.model.GeoLocation
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.UserRepository
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.GeoPoint
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.SetOptions
import com.google.firebase.storage.FirebaseStorage
import kotlinx.coroutines.tasks.await

class FirebaseUserRepository(
    private val firestoreProvider: () -> FirebaseFirestore = { FirebaseFirestore.getInstance() }
) : UserRepository {
    override suspend fun getUser(uid: String): UserProfile? {
        requireFirebaseConfigured()
        val snapshot = firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(uid)
            .get()
            .await()

        return if (snapshot.exists()) snapshot.toUserProfileDto().toDomain() else null
    }

    override suspend fun fetchRecentRadarProfiles(limit: Long): List<UserProfile> {
        requireFirebaseConfigured()
        return firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .orderBy("lastLocationUpdate", Query.Direction.DESCENDING)
            .limit(limit)
            .get()
            .await()
            .documents
            .mapNotNull { snapshot ->
                if (snapshot.exists()) snapshot.toUserProfileDto().toDomain() else null
            }
            .filter { it.isRadarVisible }
    }

    override suspend fun upsertUser(profile: UserProfile) {
        requireFirebaseConfigured()
        val data = profile.toDto().toFirestoreMap().toMutableMap()
        data["updatedAt"] = FieldValue.serverTimestamp()
        if (profile.createdAt == null) {
            data.putIfAbsent("createdAt", FieldValue.serverTimestamp())
        }

        firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(profile.uid)
            .set(data, SetOptions.merge())
            .await()
    }

    override suspend fun updateRadarVisibility(uid: String, isVisible: Boolean) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(uid)
            .set(
                mapOf(
                    "isRadarVisible" to isVisible,
                    "radarVisibilityUpdatedAt" to FieldValue.serverTimestamp()
                ),
                SetOptions.merge()
            )
            .await()
    }

    override suspend fun updateLastLocation(uid: String, location: GeoLocation, geoHash: String, isRadarVisible: Boolean) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(uid)
            .set(
                mapOf(
                    "lastLocation" to GeoPoint(location.latitude, location.longitude),
                    "lastLocationGeoHash" to geoHash,
                    "lastLocationUpdate" to FieldValue.serverTimestamp(),
                    "isRadarVisible" to isRadarVisible
                ),
                SetOptions.merge()
            )
            .await()
    }

    override suspend fun blockUser(uid: String, nameToBlock: String) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(uid)
            .update("blockedUsers", FieldValue.arrayUnion(nameToBlock))
            .await()
    }

    override suspend fun uploadProfilePhoto(uid: String, imageBytes: ByteArray): String {
        requireFirebaseConfigured()
        val storageRef = FirebaseStorage.getInstance().reference
        val photoRef = storageRef.child("profile_photos/$uid.jpg")
        photoRef.putBytes(imageBytes).await()
        return photoRef.downloadUrl.await().toString()
    }

    override suspend fun updateProfilePhotoUrl(uid: String, url: String) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(uid)
            .update("profilePhotoUrl", url)
            .await()
    }

    override suspend fun updateFcmToken(uid: String, token: String) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.USERS)
            .document(uid)
            .update("fcmToken", token)
            .await()
    }
}

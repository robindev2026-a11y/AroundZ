package com.coffeecall.app.domain.repository

import com.coffeecall.app.domain.model.GeoLocation
import com.coffeecall.app.domain.model.UserProfile

interface UserRepository {
    suspend fun getUser(uid: String): UserProfile?
    suspend fun fetchRecentRadarProfiles(limit: Long = 40): List<UserProfile>
    suspend fun upsertUser(profile: UserProfile)
    suspend fun updateRadarVisibility(uid: String, isVisible: Boolean)
    suspend fun updateLastLocation(uid: String, location: GeoLocation, geoHash: String, isRadarVisible: Boolean)
    suspend fun blockUser(uid: String, nameToBlock: String)
    suspend fun uploadProfilePhoto(uid: String, imageBytes: ByteArray): String
    suspend fun updateProfilePhotoUrl(uid: String, url: String)
    suspend fun updateFcmToken(uid: String, token: String)
}

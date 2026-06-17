package com.coffeecall.app.data.repository.mock

import com.coffeecall.app.domain.model.GeoLocation
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.UserRepository

class MockUserRepository : UserRepository {
    private val users = mutableMapOf<String, UserProfile>()

    init {
        users["mock_user"] = UserProfile(
            uid = "mock_user",
            name = "Robin",
            bio = "Coffee enthusiast and morning walker.",
            initials = "R",
            location = "Indiranagar, Bangalore",
            interests = listOf("Coffee", "Walks", "Music"),
            interestTags = listOf("Coffee", "Walks", "Music"),
            availabilityWeekdayEvenings = true,
            availabilityWeekends = true,
            isRadarVisible = true
        )
        users["mock_host_123"] = UserProfile(
            uid = "mock_host_123",
            name = "Siddharth",
            bio = "Always hunting for the cleanest filter coffee.",
            initials = "S",
            location = "Koramangala, Bangalore",
            interests = listOf("Filter Coffee", "Roasting", "Indie Music"),
            interestTags = listOf("Filter Coffee", "Roasting", "Indie Music"),
            availabilityWeekdayEvenings = true,
            isRadarVisible = true
        )
        users["mock_host_456"] = UserProfile(
            uid = "mock_host_456",
            name = "Priya",
            bio = "Board game lover and chai addict.",
            initials = "PK",
            location = "HSR Layout, Bangalore",
            interests = listOf("Gaming", "Coffee", "Books"),
            interestTags = listOf("Gaming", "Coffee", "Books"),
            isRadarVisible = true
        )
        users["mock_albin"] = UserProfile(
            uid = "mock_albin",
            name = "Albin",
            initials = "AL",
            interests = listOf("Walks", "Coffee"),
            interestTags = listOf("Walks", "Coffee"),
            isRadarVisible = true
        )
        users["mock_sneha"] = UserProfile(
            uid = "mock_sneha",
            name = "Sneha",
            initials = "SR",
            interests = listOf("Walks", "Coffee"),
            interestTags = listOf("Walks", "Coffee"),
            isRadarVisible = true
        )
    }

    override suspend fun getUser(uid: String): UserProfile? = users[uid]

    override suspend fun fetchRecentRadarProfiles(limit: Long): List<UserProfile> =
        users.values.filter { it.isRadarVisible }.take(limit.toInt())

    override suspend fun upsertUser(profile: UserProfile) {
        users[profile.uid] = profile
    }

    override suspend fun updateRadarVisibility(uid: String, isVisible: Boolean) {
        users[uid]?.let { users[uid] = it.copy(isRadarVisible = isVisible) }
    }

    override suspend fun updateLastLocation(uid: String, location: GeoLocation, geoHash: String, isRadarVisible: Boolean) {
        users[uid]?.let {
            users[uid] = it.copy(
                lastLocation = location,
                lastLocationGeoHash = geoHash,
                isRadarVisible = isRadarVisible
            )
        }
    }

    override suspend fun blockUser(uid: String, nameToBlock: String) {
        users[uid]?.let { user ->
            users[uid] = user.copy(blockedUsers = user.blockedUsers + nameToBlock)
        }
    }

    override suspend fun uploadProfilePhoto(uid: String, imageBytes: ByteArray): String =
        "mock://profile_photos/$uid.jpg"

    override suspend fun updateProfilePhotoUrl(uid: String, url: String) {
        users[uid]?.let { users[uid] = it.copy(profilePhotoUrl = url) }
    }

    override suspend fun updateFcmToken(uid: String, token: String) {
        // Mock: no-op for FCM token
    }
}

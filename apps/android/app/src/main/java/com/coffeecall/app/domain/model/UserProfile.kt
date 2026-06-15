package com.coffeecall.app.domain.model

import java.util.Date

data class UserProfile(
    val uid: String,
    val name: String = "",
    val bio: String = "",
    val initials: String = "",
    val location: String = "",
    val availabilityWeekdayEvenings: Boolean = true,
    val availabilityWeekends: Boolean = true,
    val availabilityDaytime: Boolean = false,
    val interests: List<String> = emptyList(),
    val interestTags: List<String> = emptyList(),
    val profilePhotoUrl: String = "",
    val lastLocation: GeoLocation? = null,
    val lastLocationGeoHash: String = "",
    val lastLocationUpdate: Date? = null,
    val isRadarVisible: Boolean = true,
    val blockedUsers: List<String> = emptyList(),
    val createdAt: Date? = null,
    val updatedAt: Date? = null
)

data class GeoLocation(
    val latitude: Double,
    val longitude: Double
)

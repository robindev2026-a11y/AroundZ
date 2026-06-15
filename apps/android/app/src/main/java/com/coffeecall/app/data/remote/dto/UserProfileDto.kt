package com.coffeecall.app.data.remote.dto

import com.google.firebase.Timestamp
import com.google.firebase.firestore.GeoPoint

data class UserProfileDto(
    val uid: String = "",
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
    val lastLocation: GeoPoint? = null,
    val lastLocationGeoHash: String = "",
    val lastLocationUpdate: Timestamp? = null,
    val isRadarVisible: Boolean = true,
    val blockedUsers: List<String> = emptyList(),
    val createdAt: Timestamp? = null,
    val updatedAt: Timestamp? = null
)

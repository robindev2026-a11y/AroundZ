package com.coffeecall.app.data.mapper

import com.coffeecall.app.data.remote.dto.UserProfileDto
import com.coffeecall.app.domain.model.GeoLocation
import com.coffeecall.app.domain.model.UserProfile
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.GeoPoint

fun DocumentSnapshot.toUserProfileDto(): UserProfileDto {
    val data = data.orEmpty()
    return UserProfileDto(
        uid = data["uid"] as? String ?: id,
        name = data["name"] as? String ?: "",
        bio = data["bio"] as? String ?: "",
        initials = data["initials"] as? String ?: "",
        location = data["location"] as? String ?: "",
        availabilityWeekdayEvenings = data["availabilityWeekdayEvenings"] as? Boolean ?: true,
        availabilityWeekends = data["availabilityWeekends"] as? Boolean ?: true,
        availabilityDaytime = data["availabilityDaytime"] as? Boolean ?: false,
        interests = data["interests"].asStringList(),
        interestTags = data["interestTags"].asStringList(),
        profilePhotoUrl = data["profilePhotoUrl"] as? String ?: "",
        lastLocation = data["lastLocation"] as? GeoPoint,
        lastLocationGeoHash = data["lastLocationGeoHash"] as? String ?: "",
        lastLocationUpdate = getTimestamp("lastLocationUpdate"),
        isRadarVisible = data["isRadarVisible"] as? Boolean ?: true,
        blockedUsers = data["blockedUsers"].asStringList(),
        createdAt = getTimestamp("createdAt"),
        updatedAt = getTimestamp("updatedAt")
    )
}

fun UserProfileDto.toDomain(): UserProfile =
    UserProfile(
        uid = uid,
        name = name,
        bio = bio,
        initials = initials,
        location = location,
        availabilityWeekdayEvenings = availabilityWeekdayEvenings,
        availabilityWeekends = availabilityWeekends,
        availabilityDaytime = availabilityDaytime,
        interests = interests,
        interestTags = interestTags,
        profilePhotoUrl = profilePhotoUrl,
        lastLocation = lastLocation?.let { GeoLocation(it.latitude, it.longitude) },
        lastLocationGeoHash = lastLocationGeoHash,
        lastLocationUpdate = lastLocationUpdate.toDateOrNull(),
        isRadarVisible = isRadarVisible,
        blockedUsers = blockedUsers,
        createdAt = createdAt.toDateOrNull(),
        updatedAt = updatedAt.toDateOrNull()
    )

fun UserProfile.toDto(): UserProfileDto =
    UserProfileDto(
        uid = uid,
        name = name,
        bio = bio,
        initials = initials,
        location = location,
        availabilityWeekdayEvenings = availabilityWeekdayEvenings,
        availabilityWeekends = availabilityWeekends,
        availabilityDaytime = availabilityDaytime,
        interests = interests,
        interestTags = interestTags,
        profilePhotoUrl = profilePhotoUrl,
        lastLocation = lastLocation?.let { GeoPoint(it.latitude, it.longitude) },
        lastLocationGeoHash = lastLocationGeoHash,
        lastLocationUpdate = lastLocationUpdate.toTimestampOrNull(),
        isRadarVisible = isRadarVisible,
        blockedUsers = blockedUsers,
        createdAt = createdAt.toTimestampOrNull(),
        updatedAt = updatedAt.toTimestampOrNull()
    )

fun UserProfileDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "uid" to uid,
        "name" to name,
        "bio" to bio,
        "initials" to initials,
        "location" to location,
        "availabilityWeekdayEvenings" to availabilityWeekdayEvenings,
        "availabilityWeekends" to availabilityWeekends,
        "availabilityDaytime" to availabilityDaytime,
        "interests" to interests,
        "interestTags" to interestTags,
        "profilePhotoUrl" to profilePhotoUrl,
        "lastLocation" to lastLocation,
        "lastLocationGeoHash" to lastLocationGeoHash,
        "lastLocationUpdate" to lastLocationUpdate,
        "isRadarVisible" to isRadarVisible,
        "blockedUsers" to blockedUsers,
        "createdAt" to createdAt,
        "updatedAt" to updatedAt
    ).withoutNullValues()

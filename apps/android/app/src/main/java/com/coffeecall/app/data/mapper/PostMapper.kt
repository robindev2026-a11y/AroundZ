package com.coffeecall.app.data.mapper

import com.coffeecall.app.data.remote.dto.JoinRequestDto
import com.coffeecall.app.data.remote.dto.PostDto
import com.coffeecall.app.domain.model.DriftCategory
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.DriftStatus
import com.coffeecall.app.domain.model.JoinMode
import com.coffeecall.app.domain.model.JoinRequest
import com.google.firebase.firestore.DocumentSnapshot

fun DocumentSnapshot.toPostDto(): PostDto {
    val data = data.orEmpty()
    return PostDto(
        id = id,
        title = data["title"] as? String ?: "",
        description = data["description"] as? String ?: "",
        location = data["location"] as? String ?: "",
        meetingPoint = data["meetingPoint"] as? String ?: "",
        time = data["time"] as? String ?: "",
        endTime = data["endTime"] as? String ?: "",
        date = data["date"] as? String ?: "",
        distance = data["distance"].asDouble(0.0),
        status = data["status"] as? String ?: "OPEN",
        category = data["category"] as? String ?: "coffee",
        hook = data["hook"] as? String ?: "",
        creatorId = data["creatorId"] as? String ?: "",
        creatorName = data["creatorName"] as? String ?: "",
        creatorImageUrl = data["creatorImageUrl"] as? String ?: "",
        creatorVerified = data["creatorVerified"] as? Boolean ?: false,
        participantCount = data["participantCount"].asInt(1),
        capacity = data["capacity"].asInt(5),
        spotsLeft = data["spotsLeft"].asInt(4),
        vibeTags = data["vibeTags"].asStringList(),
        whatToBring = data["whatToBring"].asStringList(),
        participantInitials = data["participantInitials"].asStringList(),
        participantIds = data["participantIds"].asStringList(),
        imageUrl = data["imageUrl"] as? String ?: "",
        pendingRequests = data["pendingRequests"].asMapList().map { it.toJoinRequestDto() },
        latitude = data["latitude"]?.asDouble(),
        longitude = data["longitude"]?.asDouble(),
        joinMode = data["joinMode"] as? String ?: "open",
        locationGeoHash = data["locationGeoHash"] as? String ?: "",
        createdAt = getTimestamp("createdAt"),
        updatedAt = getTimestamp("updatedAt")
    )
}

private fun Map<String, Any?>.toJoinRequestDto(): JoinRequestDto =
    JoinRequestDto(
        id = this["id"] as? String ?: "",
        userId = this["userId"] as? String ?: "",
        userName = this["userName"] as? String ?: "",
        userInitials = this["userInitials"] as? String ?: "",
        userRole = this["userRole"] as? String ?: "",
        message = this["message"] as? String ?: "",
        timestamp = this["timestamp"] as? String ?: ""
    )

fun PostDto.toDomain(): DriftPost =
    DriftPost(
        id = id,
        title = title,
        description = description,
        location = location,
        meetingPoint = meetingPoint,
        time = time,
        endTime = endTime,
        date = date,
        distance = distance,
        status = DriftStatus.fromFirestore(status),
        category = DriftCategory.fromFirestore(category),
        hook = hook,
        creatorId = creatorId,
        creatorName = creatorName,
        creatorImageUrl = creatorImageUrl,
        creatorVerified = creatorVerified,
        participantCount = participantCount,
        capacity = capacity,
        spotsLeft = spotsLeft,
        vibeTags = vibeTags,
        whatToBring = whatToBring,
        participantInitials = participantInitials,
        participantIds = participantIds,
        imageUrl = imageUrl,
        pendingRequests = pendingRequests.map { it.toDomain() },
        latitude = latitude,
        longitude = longitude,
        joinMode = JoinMode.fromFirestore(joinMode),
        locationGeoHash = locationGeoHash,
        createdAt = createdAt.toDateOrNull(),
        updatedAt = updatedAt.toDateOrNull()
    )

fun JoinRequestDto.toDomain(): JoinRequest =
    JoinRequest(
        id = id,
        userId = userId,
        userName = userName,
        userInitials = userInitials,
        userRole = userRole,
        message = message,
        timestamp = timestamp
    )

fun DriftPost.toDto(): PostDto =
    PostDto(
        id = id,
        title = title,
        description = description,
        location = location,
        meetingPoint = meetingPoint,
        time = time,
        endTime = endTime,
        date = date,
        distance = distance,
        status = status.firestoreValue,
        category = category.firestoreValue,
        hook = hook,
        creatorId = creatorId,
        creatorName = creatorName,
        creatorImageUrl = creatorImageUrl,
        creatorVerified = creatorVerified,
        participantCount = participantCount,
        capacity = capacity,
        spotsLeft = spotsLeft,
        vibeTags = vibeTags,
        whatToBring = whatToBring,
        participantInitials = participantInitials,
        participantIds = participantIds,
        imageUrl = imageUrl,
        pendingRequests = pendingRequests.map { it.toDto() },
        latitude = latitude,
        longitude = longitude,
        joinMode = joinMode.firestoreValue,
        locationGeoHash = locationGeoHash,
        createdAt = createdAt.toTimestampOrNull(),
        updatedAt = updatedAt.toTimestampOrNull()
    )

fun JoinRequest.toDto(): JoinRequestDto =
    JoinRequestDto(
        id = id,
        userId = userId,
        userName = userName,
        userInitials = userInitials,
        userRole = userRole,
        message = message,
        timestamp = timestamp
    )

fun PostDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "title" to title,
        "description" to description,
        "location" to location,
        "meetingPoint" to meetingPoint,
        "time" to time,
        "endTime" to endTime,
        "date" to date,
        "distance" to distance,
        "status" to status,
        "category" to category,
        "hook" to hook,
        "creatorId" to creatorId,
        "creatorName" to creatorName,
        "creatorImageUrl" to creatorImageUrl,
        "creatorVerified" to creatorVerified,
        "participantCount" to participantCount,
        "capacity" to capacity,
        "spotsLeft" to spotsLeft,
        "vibeTags" to vibeTags,
        "whatToBring" to whatToBring,
        "participantInitials" to participantInitials,
        "participantIds" to participantIds,
        "imageUrl" to imageUrl,
        "pendingRequests" to pendingRequests.map { it.toFirestoreMap() },
        "latitude" to latitude,
        "longitude" to longitude,
        "joinMode" to joinMode,
        "locationGeoHash" to locationGeoHash,
        "createdAt" to createdAt,
        "updatedAt" to updatedAt
    ).withoutNullValues()

fun JoinRequestDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "id" to id,
        "userId" to userId,
        "userName" to userName,
        "userInitials" to userInitials,
        "userRole" to userRole,
        "message" to message,
        "timestamp" to timestamp
    )

package com.coffeecall.app.data.remote.dto

import com.google.firebase.Timestamp

data class PostDto(
    val id: String = "",
    val title: String = "",
    val description: String = "",
    val location: String = "",
    val meetingPoint: String = "",
    val time: String = "",
    val endTime: String = "",
    val date: String = "",
    val distance: Double = 0.0,
    val status: String = "OPEN",
    val category: String = "coffee",
    val hook: String = "",
    val creatorId: String = "",
    val creatorName: String = "",
    val creatorImageUrl: String = "",
    val creatorVerified: Boolean = false,
    val participantCount: Int = 1,
    val capacity: Int = 5,
    val spotsLeft: Int = 4,
    val vibeTags: List<String> = emptyList(),
    val whatToBring: List<String> = emptyList(),
    val participantInitials: List<String> = emptyList(),
    val participantIds: List<String> = emptyList(),
    val imageUrl: String = "",
    val pendingRequests: List<JoinRequestDto> = emptyList(),
    val latitude: Double? = null,
    val longitude: Double? = null,
    val joinMode: String = "open",
    val locationGeoHash: String = "",
    val createdAt: Timestamp? = null,
    val updatedAt: Timestamp? = null
)

data class JoinRequestDto(
    val id: String = "",
    val userId: String = "",
    val userName: String = "",
    val userInitials: String = "",
    val userRole: String = "",
    val message: String = "",
    val timestamp: String = ""
)

package com.coffeecall.app.domain.model

import java.util.Date

data class DriftPost(
    val id: String,
    val title: String = "",
    val description: String = "",
    val location: String = "",
    val meetingPoint: String = "",
    val time: String = "",
    val endTime: String = "",
    val date: String = "",
    val distance: Double = 0.0,
    val status: DriftStatus = DriftStatus.Open,
    val category: DriftCategory = DriftCategory.Coffee,
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
    val pendingRequests: List<JoinRequest> = emptyList(),
    val latitude: Double? = null,
    val longitude: Double? = null,
    val joinMode: JoinMode = JoinMode.Open,
    val locationGeoHash: String = "",
    val createdAt: Date? = null,
    val updatedAt: Date? = null
)

enum class DriftStatus(val firestoreValue: String) {
    Open("OPEN"),
    StartingSoon("STARTING SOON"),
    Tonight("TONIGHT"),
    Ended("ENDED");

    companion object {
        fun fromFirestore(value: String?): DriftStatus =
            entries.firstOrNull { it.firestoreValue.equals(value, ignoreCase = true) } ?: Open
    }
}

enum class DriftCategory(val firestoreValue: String) {
    Coffee("coffee"),
    Walk("walk"),
    Movie("movie"),
    Food("food"),
    Study("study"),
    Gaming("gaming"),
    Music("music"),
    Yoga("yoga"),
    Event("event");

    companion object {
        fun fromFirestore(value: String?): DriftCategory =
            entries.firstOrNull { it.firestoreValue.equals(value, ignoreCase = true) } ?: Coffee
    }
}

enum class JoinMode(val firestoreValue: String) {
    Open("open"),
    Approval("approval");

    companion object {
        fun fromFirestore(value: String?): JoinMode =
            when {
                value.equals("request", ignoreCase = true) -> Approval
                else -> entries.firstOrNull { it.firestoreValue.equals(value, ignoreCase = true) } ?: Open
            }
    }
}

data class JoinRequest(
    val id: String,
    val userId: String = "",
    val userName: String = "",
    val userInitials: String = "",
    val userRole: String = "",
    val message: String = "",
    val timestamp: String = ""
)

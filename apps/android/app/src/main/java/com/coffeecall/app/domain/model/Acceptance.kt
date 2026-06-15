package com.coffeecall.app.domain.model

import java.util.Date

data class Acceptance(
    val id: String,
    val postId: String,
    val acceptorId: String,
    val acceptorName: String = "",
    val acceptorInitials: String = "",
    val status: AcceptanceStatus = AcceptanceStatus.Pending,
    val createdAt: Date? = null,
    val updatedAt: Date? = null
)

enum class AcceptanceStatus(val firestoreValue: String) {
    Pending("pending"),
    Accepted("accepted"),
    Rejected("rejected"),
    Cancelled("cancelled");

    companion object {
        fun fromFirestore(value: String?): AcceptanceStatus =
            entries.firstOrNull { it.firestoreValue.equals(value, ignoreCase = true) } ?: Pending
    }
}

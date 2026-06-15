package com.coffeecall.app.data.remote.dto

import com.google.firebase.Timestamp

data class AcceptanceDto(
    val id: String = "",
    val postId: String = "",
    val acceptorId: String = "",
    val acceptorName: String = "",
    val acceptorInitials: String = "",
    val status: String = "pending",
    val createdAt: Timestamp? = null,
    val updatedAt: Timestamp? = null
)

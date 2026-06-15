package com.coffeecall.app.data.mapper

import com.coffeecall.app.data.remote.dto.AcceptanceDto
import com.coffeecall.app.domain.model.Acceptance
import com.coffeecall.app.domain.model.AcceptanceStatus
import com.google.firebase.firestore.DocumentSnapshot

fun DocumentSnapshot.toAcceptanceDto(): AcceptanceDto {
    val data = data.orEmpty()
    return AcceptanceDto(
        id = id,
        postId = data["postId"] as? String ?: "",
        acceptorId = data["acceptorId"] as? String ?: "",
        acceptorName = data["acceptorName"] as? String ?: "",
        acceptorInitials = data["acceptorInitials"] as? String ?: "",
        status = data["status"] as? String ?: "pending",
        createdAt = getTimestamp("createdAt"),
        updatedAt = getTimestamp("updatedAt")
    )
}

fun AcceptanceDto.toDomain(): Acceptance =
    Acceptance(
        id = id,
        postId = postId,
        acceptorId = acceptorId,
        acceptorName = acceptorName,
        acceptorInitials = acceptorInitials,
        status = AcceptanceStatus.fromFirestore(status),
        createdAt = createdAt.toDateOrNull(),
        updatedAt = updatedAt.toDateOrNull()
    )

fun Acceptance.toDto(): AcceptanceDto =
    AcceptanceDto(
        id = id,
        postId = postId,
        acceptorId = acceptorId,
        acceptorName = acceptorName,
        acceptorInitials = acceptorInitials,
        status = status.firestoreValue,
        createdAt = createdAt.toTimestampOrNull(),
        updatedAt = updatedAt.toTimestampOrNull()
    )

fun AcceptanceDto.toFirestoreMap(): Map<String, Any> =
    mapOf(
        "postId" to postId,
        "acceptorId" to acceptorId,
        "acceptorName" to acceptorName,
        "acceptorInitials" to acceptorInitials,
        "status" to status,
        "createdAt" to createdAt,
        "updatedAt" to updatedAt
    ).withoutNullValues()

package com.coffeecall.app.domain.model

data class AuthVerification(
    val verificationId: String,
    val isMock: Boolean = false
)

data class AuthenticatedUser(
    val uid: String,
    val isNewUser: Boolean
)

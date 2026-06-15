package com.coffeecall.app.core.session

data class SessionState(
    val hasLaunchedBefore: Boolean = false,
    val hasCompletedOnboarding: Boolean = false,
    val verificationId: String = "",
    val profileName: String = "",
    val profileInitials: String = ""
)

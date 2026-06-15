package com.coffeecall.app.core.firebase

sealed interface FirebaseInitializationState {
    data object Configured : FirebaseInitializationState
    data class NotConfigured(val reason: String) : FirebaseInitializationState
}

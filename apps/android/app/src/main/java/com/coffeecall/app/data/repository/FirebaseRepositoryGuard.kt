package com.coffeecall.app.data.repository

import com.coffeecall.app.core.firebase.FirebaseInitializationState
import com.coffeecall.app.core.firebase.FirebaseInitializer
import com.coffeecall.app.core.firebase.FirebaseUnavailableException

internal fun requireFirebaseConfigured() {
    val state = FirebaseInitializer.currentState()
    if (state is FirebaseInitializationState.NotConfigured) {
        throw FirebaseUnavailableException(state.reason)
    }
}

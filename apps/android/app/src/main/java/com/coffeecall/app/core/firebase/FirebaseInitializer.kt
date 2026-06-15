package com.coffeecall.app.core.firebase

import android.content.Context
import com.google.firebase.FirebaseApp

object FirebaseInitializer {
    private var state: FirebaseInitializationState? = null

    fun initialize(context: Context): FirebaseInitializationState {
        state?.let { return it }

        val initializedApp = runCatching {
            FirebaseApp.initializeApp(context)
        }.getOrNull()

        val nextState = if (initializedApp != null || FirebaseApp.getApps(context).isNotEmpty()) {
            FirebaseInitializationState.Configured
        } else {
            FirebaseInitializationState.NotConfigured(
                reason = "Missing Firebase Android config. Add apps/android/app/google-services.json for local/dev builds."
            )
        }

        state = nextState
        return nextState
    }

    fun currentState(): FirebaseInitializationState =
        state ?: FirebaseInitializationState.NotConfigured(
            reason = "FirebaseInitializer.initialize(context) has not run yet."
        )
}

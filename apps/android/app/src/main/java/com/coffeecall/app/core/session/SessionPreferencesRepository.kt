package com.coffeecall.app.core.session

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.io.IOException

private val Context.sessionDataStore: DataStore<Preferences> by preferencesDataStore(
    name = "coffee_call_session"
)

class SessionPreferencesRepository(
    context: Context
) {
    private val dataStore = context.applicationContext.sessionDataStore

    val sessionState: Flow<SessionState> = dataStore.data
        .catch { error ->
            if (error is IOException) {
                emit(emptyPreferences())
            } else {
                throw error
            }
        }
        .map { preferences ->
            SessionState(
                hasLaunchedBefore = preferences[Keys.HAS_LAUNCHED_BEFORE] ?: false,
                hasCompletedOnboarding = preferences[Keys.HAS_COMPLETED_ONBOARDING] ?: false,
                verificationId = preferences[Keys.AUTH_VERIFICATION_ID].orEmpty(),
                profileName = preferences[Keys.PROFILE_NAME].orEmpty(),
                profileInitials = preferences[Keys.PROFILE_INITIALS].orEmpty()
            )
        }

    suspend fun currentState(): SessionState = sessionState.first()

    suspend fun markLaunchedBefore() {
        dataStore.edit { preferences ->
            preferences[Keys.HAS_LAUNCHED_BEFORE] = true
        }
    }

    suspend fun setCompletedOnboarding(completed: Boolean) {
        dataStore.edit { preferences ->
            preferences[Keys.HAS_COMPLETED_ONBOARDING] = completed
        }
    }

    suspend fun saveVerificationId(verificationId: String) {
        dataStore.edit { preferences ->
            preferences[Keys.AUTH_VERIFICATION_ID] = verificationId
        }
    }

    suspend fun clearVerificationId() {
        dataStore.edit { preferences ->
            preferences.remove(Keys.AUTH_VERIFICATION_ID)
        }
    }

    suspend fun saveProfileName(name: String, initials: String) {
        dataStore.edit { preferences ->
            preferences[Keys.PROFILE_NAME] = name
            preferences[Keys.PROFILE_INITIALS] = initials
        }
    }

    suspend fun clearSignedInSession() {
        dataStore.edit { preferences ->
            preferences[Keys.HAS_COMPLETED_ONBOARDING] = false
            preferences.remove(Keys.AUTH_VERIFICATION_ID)
        }
    }

    private object Keys {
        val HAS_LAUNCHED_BEFORE = booleanPreferencesKey("hasLaunchedBefore")
        val HAS_COMPLETED_ONBOARDING = booleanPreferencesKey("hasCompletedOnboarding")
        val AUTH_VERIFICATION_ID = stringPreferencesKey("authVerificationID")
        val PROFILE_NAME = stringPreferencesKey("profile_name")
        val PROFILE_INITIALS = stringPreferencesKey("profile_initials")
    }
}

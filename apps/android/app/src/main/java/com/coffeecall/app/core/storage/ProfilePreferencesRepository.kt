package com.coffeecall.app.core.storage

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.coffeecall.app.domain.model.UserProfile
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.io.IOException

private val Context.profileDataStore: DataStore<Preferences> by preferencesDataStore(
    name = "coffee_call_profile"
)

class ProfilePreferencesRepository(
    context: Context
) {
    private val dataStore = context.applicationContext.profileDataStore

    val profileState: Flow<UserProfile?> = dataStore.data
        .catch { error ->
            if (error is IOException) {
                emit(emptyPreferences())
            } else {
                throw error
            }
        }
        .map { preferences ->
            val uid = preferences[Keys.PROFILE_UID]
            if (uid.isNullOrBlank()) {
                null
            } else {
                UserProfile(
                    uid = uid,
                    name = preferences[Keys.PROFILE_NAME].orEmpty(),
                    bio = preferences[Keys.PROFILE_BIO].orEmpty(),
                    initials = preferences[Keys.PROFILE_INITIALS].orEmpty(),
                    location = preferences[Keys.PROFILE_LOCATION].orEmpty(),
                    availabilityWeekdayEvenings = preferences[Keys.PROFILE_AVAILABILITY_WEEKDAY_EVENINGS] ?: true,
                    availabilityWeekends = preferences[Keys.PROFILE_AVAILABILITY_WEEKENDS] ?: true,
                    availabilityDaytime = preferences[Keys.PROFILE_AVAILABILITY_DAYTIME] ?: false,
                    interests = preferences[Keys.PROFILE_INTERESTS]?.toList() ?: emptyList(),
                    profilePhotoUrl = preferences[Keys.PROFILE_PHOTO_URL].orEmpty()
                )
            }
        }

    suspend fun currentProfile(): UserProfile? = profileState.first()

    suspend fun saveProfile(profile: UserProfile) {
        dataStore.edit { preferences ->
            preferences[Keys.PROFILE_UID] = profile.uid
            preferences[Keys.PROFILE_NAME] = profile.name
            preferences[Keys.PROFILE_BIO] = profile.bio
            preferences[Keys.PROFILE_INITIALS] = profile.initials
            preferences[Keys.PROFILE_LOCATION] = profile.location
            preferences[Keys.PROFILE_AVAILABILITY_WEEKDAY_EVENINGS] = profile.availabilityWeekdayEvenings
            preferences[Keys.PROFILE_AVAILABILITY_WEEKENDS] = profile.availabilityWeekends
            preferences[Keys.PROFILE_AVAILABILITY_DAYTIME] = profile.availabilityDaytime
            preferences[Keys.PROFILE_INTERESTS] = profile.interests.toSet()
            preferences[Keys.PROFILE_PHOTO_URL] = profile.profilePhotoUrl
        }
    }

    suspend fun clearProfile() {
        dataStore.edit { preferences ->
            preferences.clear()
        }
    }

    private object Keys {
        val PROFILE_UID = stringPreferencesKey("profile_uid")
        val PROFILE_NAME = stringPreferencesKey("profile_name")
        val PROFILE_BIO = stringPreferencesKey("profile_bio")
        val PROFILE_INITIALS = stringPreferencesKey("profile_initials")
        val PROFILE_LOCATION = stringPreferencesKey("profile_location")
        val PROFILE_AVAILABILITY_WEEKDAY_EVENINGS = booleanPreferencesKey("profile_availability_weekday_evenings")
        val PROFILE_AVAILABILITY_WEEKENDS = booleanPreferencesKey("profile_availability_weekends")
        val PROFILE_AVAILABILITY_DAYTIME = booleanPreferencesKey("profile_availability_daytime")
        val PROFILE_INTERESTS = stringSetPreferencesKey("profile_interests")
        val PROFILE_PHOTO_URL = stringPreferencesKey("profile_photo_url")
    }
}

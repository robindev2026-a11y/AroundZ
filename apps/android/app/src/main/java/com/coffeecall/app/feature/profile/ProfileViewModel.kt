package com.coffeecall.app.feature.profile

import android.app.Application
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.coffeecall.app.core.firebase.FirebaseUnavailableException
import com.coffeecall.app.core.location.AndroidLocationProvider
import com.coffeecall.app.core.storage.ProfileImageHelper
import com.coffeecall.app.core.storage.ProfilePreferencesRepository
import com.coffeecall.app.data.repository.FirebaseMessageThreadRepository
import com.coffeecall.app.data.repository.FirebasePostRepository
import com.coffeecall.app.data.repository.FirebaseUserRepository
import com.coffeecall.app.domain.model.DriftPost
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.MessageThreadRepository
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.domain.repository.UserRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

data class ProfileUiState(
    val user: UserProfile? = null,
    val isLoading: Boolean = false,
    val isSaving: Boolean = false,
    val driftsHosted: Int = 0,
    val driftsJoined: Int = 0,
    val historyDrifts: List<DriftPost> = emptyList(),
    val error: String? = null,
    val success: Boolean = false
)

class ProfileViewModel(
    application: Application,
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val postRepository: PostRepository = FirebasePostRepository(),
    private val threadRepository: MessageThreadRepository = FirebaseMessageThreadRepository(),
    private val profilePrefs: ProfilePreferencesRepository = ProfilePreferencesRepository(application),
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
) : AndroidViewModel(application) {

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    private val locationProvider = AndroidLocationProvider(application)

    init {
        loadProfile()
    }

    fun loadProfile() {
        val currentUid = auth.currentUser?.uid
        if (currentUid.isNullOrBlank()) {
            loadMockProfile()
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            // 1. Load local preferences first
            val cachedProfile = profilePrefs.currentProfile()
            if (cachedProfile != null) {
                _uiState.update { it.copy(user = cachedProfile) }
            }

            // 2. Fetch remote and save
            runCatching {
                val remoteProfile = userRepository.getUser(currentUid)
                if (remoteProfile != null) {
                    profilePrefs.saveProfile(remoteProfile)
                    _uiState.update { it.copy(user = remoteProfile) }
                } else {
                    // Create basic if missing
                    val newProfile = UserProfile(
                        uid = currentUid,
                        name = cachedProfile?.name ?: "User",
                        initials = cachedProfile?.initials ?: "U"
                    )
                    userRepository.upsertUser(newProfile)
                    profilePrefs.saveProfile(newProfile)
                    _uiState.update { it.copy(user = newProfile) }
                }
            }.onFailure { exception ->
                if (exception is FirebaseUnavailableException) {
                    if (uiState.value.user == null) {
                        loadMockProfile()
                    }
                } else {
                    _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to load profile") }
                }
            }

            // 3. Load stats & history
            loadStatsAndHistory(currentUid)
            _uiState.update { it.copy(isLoading = false) }
        }
    }

    private fun loadStatsAndHistory(uid: String) {
        // Query hosted drifts
        viewModelScope.launch {
            runCatching {
                val hosted = postRepository.getHostedPosts(uid)
                _uiState.update { it.copy(driftsHosted = hosted.size) }
                updateHistory()
            }
        }

        // Query joined drifts (via observeThreads flow or one-shot getJoinedPosts)
        viewModelScope.launch {
            runCatching {
                val joined = postRepository.getJoinedPosts(uid)
                val joinedCount = joined.filter { it.creatorId != uid }.size
                _uiState.update { it.copy(driftsJoined = joinedCount) }
                updateHistory()
            }
        }
    }

    private suspend fun updateHistory() {
        val uid = auth.currentUser?.uid ?: return
        runCatching {
            val hosted = postRepository.getHostedPosts(uid)
            val joined = postRepository.getJoinedPosts(uid)
            val combined = (hosted + joined).distinctBy { it.id }.sortedByDescending { it.createdAt }
            _uiState.update { it.copy(historyDrifts = combined) }
        }
    }

    private fun loadMockProfile() {
        val mockUser = UserProfile(
            uid = "mock_user_123",
            name = "John Doe",
            bio = "Love specialty coffee and outdoor walks. CoffeeCall creator.",
            initials = "JD",
            location = "Bengaluru, India",
            availabilityWeekdayEvenings = true,
            availabilityWeekends = true,
            availabilityDaytime = false,
            interests = listOf("coffee", "walk", "food")
        )
        val mockHistory = listOf(
            DriftPost(
                id = "mock_post_1",
                title = "Sunday Coffee at Third Wave",
                creatorId = "mock_user_123",
                creatorName = "John Doe",
                category = com.coffeecall.app.domain.model.DriftCategory.Coffee,
                location = "Indiranagar, Bangalore",
                meetingPoint = "Third Wave Coffee"
            ),
            DriftPost(
                id = "mock_post_2",
                title = "Evening walk at Cubbon Park",
                creatorId = "host456",
                creatorName = "Siddharth",
                category = com.coffeecall.app.domain.model.DriftCategory.Walk,
                location = "Cubbon Park, Bangalore",
                meetingPoint = "Entrance Gate"
            )
        )
        _uiState.update {
            it.copy(
                user = mockUser,
                driftsHosted = 8,
                driftsJoined = 24,
                historyDrifts = mockHistory,
                isLoading = false
            )
        }
    }

    fun updateProfile(
        name: String,
        bio: String,
        location: String,
        availabilityWeekdayEvenings: Boolean,
        availabilityWeekends: Boolean,
        availabilityDaytime: Boolean,
        interests: List<String>,
        photoUri: Uri?,
        removePhoto: Boolean
    ) {
        val currentUser = uiState.value.user ?: return
        val computedInitials = computeInitials(name)

        viewModelScope.launch {
            _uiState.update { it.copy(isSaving = true, success = false, error = null) }

            var updatedUrl = currentUser.profilePhotoUrl
            val context = getApplication<Application>().applicationContext

            if (removePhoto) {
                ProfileImageHelper.clearProfileImage(context)
                updatedUrl = ""
                runCatching {
                    userRepository.updateProfilePhotoUrl(currentUser.uid, "")
                }
            } else if (photoUri != null) {
                val bytes = compressImage(context, photoUri)
                if (bytes != null) {
                    ProfileImageHelper.saveProfileImage(context, bytes)
                    runCatching {
                        val url = userRepository.uploadProfilePhoto(currentUser.uid, bytes)
                        userRepository.updateProfilePhotoUrl(currentUser.uid, url)
                        updatedUrl = url
                    }.onFailure { exception ->
                        _uiState.update { it.copy(error = "Photo upload failed: ${exception.localizedMessage}") }
                    }
                }
            }

            val updatedProfile = currentUser.copy(
                name = name,
                bio = bio,
                initials = computedInitials,
                location = location,
                availabilityWeekdayEvenings = availabilityWeekdayEvenings,
                availabilityWeekends = availabilityWeekends,
                availabilityDaytime = availabilityDaytime,
                interests = interests,
                profilePhotoUrl = updatedUrl
            )

            runCatching {
                userRepository.upsertUser(updatedProfile)
                profilePrefs.saveProfile(updatedProfile)
                _uiState.update { it.copy(user = updatedProfile, success = true) }
            }.onFailure { exception ->
                _uiState.update { it.copy(error = exception.localizedMessage ?: "Failed to save profile") }
            }

            _uiState.update { it.copy(isSaving = false) }
        }
    }

    fun fetchLocationAndAddress(onAddressResolved: (String) -> Unit) {
        viewModelScope.launch {
            if (!locationProvider.hasLocationPermission()) {
                _uiState.update { it.copy(error = "Location permissions not granted") }
                return@launch
            }

            val location = locationProvider.currentLocation()
            if (location == null) {
                _uiState.update { it.copy(error = "Unable to determine current location") }
                return@launch
            }

            val address = withContext(Dispatchers.IO) {
                val geocoder = android.location.Geocoder(getApplication(), java.util.Locale.getDefault())
                runCatching {
                    @Suppress("DEPRECATION")
                    val addresses = geocoder.getFromLocation(location.latitude, location.longitude, 1)
                    val first = addresses?.firstOrNull()
                    if (first != null) {
                        val locality = first.locality
                        val adminArea = first.adminArea
                        if (locality != null && adminArea != null) {
                            "$locality, $adminArea"
                        } else locality ?: adminArea ?: "Unknown Location"
                    } else null
                }.getOrNull()
            }

            if (address != null) {
                onAddressResolved(address)
            } else {
                _uiState.update { it.copy(error = "Failed to reverse geocode location") }
            }
        }
    }

    fun signOut(onDone: () -> Unit) {
        viewModelScope.launch {
            val context = getApplication<Application>().applicationContext
            ProfileImageHelper.clearProfileImage(context)
            profilePrefs.clearProfile()
            onDone()
        }
    }

    private fun computeInitials(name: String): String {
        val parts = name.split(" ").filter { it.isNotBlank() }
        val firstLetter = parts.firstOrNull()?.firstOrNull() ?: return "U"
        val lastLetter = if (parts.size > 1) parts.lastOrNull()?.firstOrNull() else null
        return if (lastLetter != null) {
            "$firstLetter$lastLetter".uppercase()
        } else {
            firstLetter.toString().uppercase()
        }
    }

    private suspend fun compressImage(context: Context, uri: Uri): ByteArray? = withContext(Dispatchers.IO) {
        try {
            val inputStream = context.contentResolver.openInputStream(uri)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
            outputStream.toByteArray()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    fun clearSuccess() {
        _uiState.update { it.copy(success = false) }
    }

    companion object {
        fun factory(application: Application): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    ProfileViewModel(application) as T
            }
    }
}

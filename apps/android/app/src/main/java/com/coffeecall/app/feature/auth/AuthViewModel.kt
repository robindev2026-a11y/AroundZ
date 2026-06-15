package com.coffeecall.app.feature.auth

import android.app.Activity
import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.coffeecall.app.core.storage.ProfilePreferencesRepository
import com.coffeecall.app.core.storage.ProfileImageHelper
import com.coffeecall.app.core.session.SessionPreferencesRepository
import com.coffeecall.app.data.repository.FirebaseAuthRepository
import com.coffeecall.app.data.repository.FirebaseUserRepository
import com.coffeecall.app.domain.model.UserProfile
import com.coffeecall.app.domain.repository.AuthRepository
import com.coffeecall.app.domain.repository.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class AuthViewModel(
    application: Application,
    private val authRepository: AuthRepository = FirebaseAuthRepository(),
    private val userRepository: UserRepository = FirebaseUserRepository(),
    private val sessionRepository: SessionPreferencesRepository =
        SessionPreferencesRepository(application)
) : AndroidViewModel(application) {
    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    private var activeUid: String? = null

    init {
        restoreSession()
    }

    fun updatePhoneNumber(phoneNumber: String) {
        _uiState.update { it.copy(phoneNumber = phoneNumber, errorMessage = null) }
    }

    fun updateOtpCode(code: String) {
        _uiState.update { it.copy(otpCode = code, errorMessage = null) }
    }

    fun updateProfileName(name: String) {
        _uiState.update { it.copy(profileName = name, errorMessage = null) }
    }

    fun continueFromOnboarding() {
        _uiState.update { it.copy(route = AuthRoute.Auth, errorMessage = null) }
    }

    fun sendOtp(activity: Activity) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            runCatching {
                authRepository.sendOtp(activity, _uiState.value.phoneNumber)
            }.onSuccess { verification ->
                sessionRepository.saveVerificationId(verification.verificationId)
                _uiState.update {
                    it.copy(
                        verificationSent = true,
                        isLoading = false,
                        errorMessage = null
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = error.message ?: "Could not send verification code."
                    )
                }
            }
        }
    }

    fun verifyOtp() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            val verificationId = sessionRepository.currentState().verificationId
            runCatching {
                authRepository.verifyOtp(verificationId, _uiState.value.otpCode)
            }.onSuccess { authenticated ->
                activeUid = authenticated.uid
                sessionRepository.clearVerificationId()

                if (!authenticated.isNewUser && hasExistingProfile(authenticated.uid)) {
                    sessionRepository.setCompletedOnboarding(true)
                    _uiState.update {
                        it.copy(
                            route = AuthRoute.App,
                            isLoading = false,
                            verificationSent = false,
                            errorMessage = null
                        )
                    }
                } else if (!authenticated.isNewUser) {
                    sessionRepository.setCompletedOnboarding(true)
                    _uiState.update {
                        it.copy(
                            route = AuthRoute.App,
                            isLoading = false,
                            verificationSent = false,
                            errorMessage = null
                        )
                    }
                } else {
                    val profile = maybeGetProfile(authenticated.uid)
                    if (!profile?.name.isNullOrBlank()) {
                        sessionRepository.setCompletedOnboarding(true)
                        sessionRepository.saveProfileName(
                            name = profile?.name.orEmpty(),
                            initials = profile?.initials.orEmpty()
                        )
                        _uiState.update {
                            it.copy(
                                route = AuthRoute.App,
                                isLoading = false,
                                verificationSent = false,
                                errorMessage = null
                            )
                        }
                    } else {
                        _uiState.update {
                            it.copy(
                                route = AuthRoute.ProfileSetup,
                                isLoading = false,
                                verificationSent = false,
                                errorMessage = null
                            )
                        }
                    }
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = error.message ?: "Could not verify code."
                    )
                }
            }
        }
    }

    fun saveProfile(photoBytes: ByteArray? = null) {
        viewModelScope.launch {
            val trimmedName = _uiState.value.profileName.trim()
            if (trimmedName.isBlank()) {
                _uiState.update { it.copy(errorMessage = "Enter your name.") }
                return@launch
            }

            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            val uid = activeUid ?: authRepository.currentUserId() ?: MOCK_UID
            val initials = computeInitials(trimmedName)

            runCatching {
                var photoUrl = ""
                if (authRepository.isFirebaseConfigured) {
                    if (photoBytes != null) {
                        photoUrl = userRepository.uploadProfilePhoto(uid, photoBytes)
                    }
                    userRepository.upsertUser(
                        UserProfile(
                            uid = uid,
                            name = trimmedName,
                            initials = initials,
                            profilePhotoUrl = photoUrl
                        )
                    )
                }
                sessionRepository.saveProfileName(trimmedName, initials)
                
                val context = getApplication<Application>().applicationContext
                val profilePrefs = ProfilePreferencesRepository(context)
                profilePrefs.saveProfile(
                    UserProfile(
                        uid = uid,
                        name = trimmedName,
                        initials = initials,
                        profilePhotoUrl = photoUrl
                    )
                )
                if (photoBytes != null) {
                    ProfileImageHelper.saveProfileImage(context, photoBytes)
                }
                
                sessionRepository.setCompletedOnboarding(true)
            }.onSuccess {
                _uiState.update {
                    it.copy(
                        route = AuthRoute.App,
                        isLoading = false,
                        errorMessage = null
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = error.message ?: "Could not save profile."
                    )
                }
            }
        }
    }

    fun signOut() {
        viewModelScope.launch {
            runCatching { authRepository.signOut() }
            activeUid = null
            sessionRepository.clearSignedInSession()
            _uiState.update {
                it.copy(
                    route = AuthRoute.Auth,
                    verificationSent = false,
                    otpCode = "",
                    errorMessage = null,
                    isLoading = false
                )
            }
        }
    }

    private fun restoreSession() {
        viewModelScope.launch {
            val session = sessionRepository.currentState()
            val isFirstLaunch = !session.hasLaunchedBefore
            if (isFirstLaunch) {
                sessionRepository.markLaunchedBefore()
            }

            val firebaseUid = authRepository.currentUserId()
            val route = when {
                firebaseUid != null -> {
                    activeUid = firebaseUid
                    sessionRepository.setCompletedOnboarding(true)
                    AuthRoute.App
                }
                session.hasCompletedOnboarding -> {
                    if (authRepository.isFirebaseConfigured) AuthRoute.Auth else AuthRoute.App
                }
                isFirstLaunch -> AuthRoute.Onboarding
                else -> AuthRoute.Auth
            }

            _uiState.update {
                it.copy(
                    route = route,
                    profileName = session.profileName,
                    isFirebaseConfigured = authRepository.isFirebaseConfigured
                )
            }
        }
    }

    private suspend fun hasExistingProfile(uid: String): Boolean =
        maybeGetProfile(uid)?.name?.isNotBlank() == true

    private suspend fun maybeGetProfile(uid: String): UserProfile? =
        if (authRepository.isFirebaseConfigured) {
            runCatching { userRepository.getUser(uid) }.getOrNull()
        } else {
            null
        }

    private fun computeInitials(name: String): String {
        val parts = name.split(" ").filter { it.isNotBlank() }
        val first = parts.firstOrNull()?.firstOrNull() ?: return "U"
        val last = parts.takeIf { it.size > 1 }?.lastOrNull()?.firstOrNull()
        return listOfNotNull(first, last).joinToString("").uppercase()
    }

    companion object {
        private const val MOCK_UID = "mock-android-user"

        fun factory(application: Application): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T {
                    return AuthViewModel(application) as T
                }
            }
    }
}

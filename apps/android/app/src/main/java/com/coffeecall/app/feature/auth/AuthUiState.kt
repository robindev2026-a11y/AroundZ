package com.coffeecall.app.feature.auth

data class AuthUiState(
    val route: AuthRoute = AuthRoute.Loading,
    val phoneNumber: String = "",
    val otpCode: String = "",
    val profileName: String = "",
    val verificationSent: Boolean = false,
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val isFirebaseConfigured: Boolean = false
)

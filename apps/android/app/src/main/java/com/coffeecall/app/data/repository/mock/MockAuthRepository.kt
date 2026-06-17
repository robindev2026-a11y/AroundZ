package com.coffeecall.app.data.repository.mock

import android.app.Activity
import com.coffeecall.app.domain.model.AuthVerification
import com.coffeecall.app.domain.model.AuthenticatedUser
import com.coffeecall.app.domain.repository.AuthRepository

class MockAuthRepository : AuthRepository {
    override val isFirebaseConfigured: Boolean = false

    private var signedInUserId: String? = null

    override fun currentUserId(): String? = signedInUserId

    override suspend fun sendOtp(activity: Activity, phoneNumber: String): AuthVerification {
        return AuthVerification(verificationId = MOCK_VERIFICATION_ID, isMock = true)
    }

    override suspend fun verifyOtp(verificationId: String, code: String): AuthenticatedUser {
        signedInUserId = MOCK_UID
        return AuthenticatedUser(uid = MOCK_UID, isNewUser = false)
    }

    override suspend fun signOut() {
        signedInUserId = null
    }

    private companion object {
        const val MOCK_VERIFICATION_ID = "mock-verification-id"
        const val MOCK_UID = "mock-android-user"
    }
}

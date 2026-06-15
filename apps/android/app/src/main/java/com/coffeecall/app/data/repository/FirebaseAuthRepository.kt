package com.coffeecall.app.data.repository

import android.app.Activity
import com.coffeecall.app.core.firebase.FirebaseInitializationState
import com.coffeecall.app.core.firebase.FirebaseInitializer
import com.coffeecall.app.domain.model.AuthVerification
import com.coffeecall.app.domain.model.AuthenticatedUser
import com.coffeecall.app.domain.repository.AuthRepository
import com.google.firebase.FirebaseException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.PhoneAuthOptions
import com.google.firebase.auth.PhoneAuthProvider
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.tasks.await
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class FirebaseAuthRepository(
    private val authProvider: () -> FirebaseAuth = { FirebaseAuth.getInstance() },
    private val firebaseStateProvider: () -> FirebaseInitializationState = {
        FirebaseInitializer.currentState()
    }
) : AuthRepository {
    override val isFirebaseConfigured: Boolean
        get() = firebaseStateProvider() is FirebaseInitializationState.Configured

    override fun currentUserId(): String? =
        if (isFirebaseConfigured) authProvider().currentUser?.uid else null

    override suspend fun sendOtp(activity: Activity, phoneNumber: String): AuthVerification {
        val normalizedPhone = phoneNumber.replace(Regex("[^0-9+]"), "")
        require(isValidPhoneNumber(normalizedPhone)) {
            "Enter a phone number with country code, like +917012655068."
        }

        if (!isFirebaseConfigured) {
            return AuthVerification(verificationId = MOCK_VERIFICATION_ID, isMock = true)
        }

        return suspendCancellableCoroutine { continuation ->
            val callbacks = object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                override fun onVerificationCompleted(credential: PhoneAuthCredential) {
                    authProvider().signInWithCredential(credential)
                }

                override fun onVerificationFailed(error: FirebaseException) {
                    if (continuation.isActive) {
                        continuation.resumeWithException(error)
                    }
                }

                override fun onCodeSent(
                    verificationId: String,
                    token: PhoneAuthProvider.ForceResendingToken
                ) {
                    if (continuation.isActive) {
                        continuation.resume(AuthVerification(verificationId = verificationId))
                    }
                }
            }

            val options = PhoneAuthOptions.newBuilder(authProvider())
                .setPhoneNumber(normalizedPhone)
                .setTimeout(60L, TimeUnit.SECONDS)
                .setActivity(activity)
                .setCallbacks(callbacks)
                .build()

            PhoneAuthProvider.verifyPhoneNumber(options)
        }
    }

    override suspend fun verifyOtp(verificationId: String, code: String): AuthenticatedUser {
        require(code.trim().length in 4..8) {
            "Enter the verification code."
        }

        if (!isFirebaseConfigured || verificationId == MOCK_VERIFICATION_ID) {
            return AuthenticatedUser(uid = MOCK_UID, isNewUser = true)
        }

        val credential = PhoneAuthProvider.getCredential(verificationId, code.trim())
        val result = authProvider().signInWithCredential(credential).await()
        val uid = result.user?.uid ?: error("Firebase did not return a signed-in user.")
        return AuthenticatedUser(
            uid = uid,
            isNewUser = result.additionalUserInfo?.isNewUser ?: true
        )
    }

    override suspend fun signOut() {
        if (isFirebaseConfigured) {
            authProvider().signOut()
        }
    }

    private fun isValidPhoneNumber(phoneNumber: String): Boolean {
        val digits = phoneNumber.drop(1)
        return phoneNumber.startsWith("+") &&
            digits.all { it.isDigit() } &&
            digits.length in 8..15
    }

    private companion object {
        const val MOCK_VERIFICATION_ID = "mock-verification-id"
        const val MOCK_UID = "mock-android-user"
    }
}

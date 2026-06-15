package com.coffeecall.app.domain.repository

import android.app.Activity
import com.coffeecall.app.domain.model.AuthVerification
import com.coffeecall.app.domain.model.AuthenticatedUser

interface AuthRepository {
    val isFirebaseConfigured: Boolean
    fun currentUserId(): String?
    suspend fun sendOtp(activity: Activity, phoneNumber: String): AuthVerification
    suspend fun verifyOtp(verificationId: String, code: String): AuthenticatedUser
    suspend fun signOut()
}

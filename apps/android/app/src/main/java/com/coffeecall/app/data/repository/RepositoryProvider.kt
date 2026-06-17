package com.coffeecall.app.data.repository

import com.coffeecall.app.core.firebase.FirebaseInitializationState
import com.coffeecall.app.core.firebase.FirebaseInitializer
import com.coffeecall.app.data.repository.mock.MockAcceptanceRepository
import com.coffeecall.app.data.repository.mock.MockAuthRepository
import com.coffeecall.app.data.repository.mock.MockMessageThreadRepository
import com.coffeecall.app.data.repository.mock.MockPostRepository
import com.coffeecall.app.data.repository.mock.MockReportRepository
import com.coffeecall.app.data.repository.mock.MockUserRepository
import com.coffeecall.app.domain.repository.AcceptanceRepository
import com.coffeecall.app.domain.repository.AuthRepository
import com.coffeecall.app.domain.repository.MessageThreadRepository
import com.coffeecall.app.domain.repository.PostRepository
import com.coffeecall.app.domain.repository.ReportRepository
import com.coffeecall.app.domain.repository.UserRepository

object RepositoryProvider {
    private val isFirebaseReady: Boolean
        get() = FirebaseInitializer.currentState() is FirebaseInitializationState.Configured

    val userRepository: UserRepository by lazy {
        if (isFirebaseReady) FirebaseUserRepository() else MockUserRepository()
    }

    val postRepository: PostRepository by lazy {
        if (isFirebaseReady) FirebasePostRepository() else MockPostRepository()
    }

    val acceptanceRepository: AcceptanceRepository by lazy {
        if (isFirebaseReady) FirebaseAcceptanceRepository() else MockAcceptanceRepository()
    }

    val messageThreadRepository: MessageThreadRepository by lazy {
        if (isFirebaseReady) FirebaseMessageThreadRepository() else MockMessageThreadRepository()
    }

    val authRepository: AuthRepository by lazy {
        if (isFirebaseReady) FirebaseAuthRepository() else MockAuthRepository()
    }

    val reportRepository: ReportRepository by lazy {
        if (isFirebaseReady) FirebaseReportRepository() else MockReportRepository()
    }
}

package com.coffeecall.app.data.repository

import com.coffeecall.app.domain.repository.ReportRepository
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

class FirebaseReportRepository(
    private val firestoreProvider: () -> FirebaseFirestore = { FirebaseFirestore.getInstance() }
) : ReportRepository {
    override suspend fun reportPost(postId: String, reporterId: String, reason: String) {
        requireFirebaseConfigured()
        val reportData = mapOf(
            "postId" to postId,
            "reporterId" to reporterId,
            "reason" to reason,
            "createdAt" to FieldValue.serverTimestamp()
        )
        firestoreProvider()
            .collection("reports")
            .add(reportData)
            .await()
    }
}

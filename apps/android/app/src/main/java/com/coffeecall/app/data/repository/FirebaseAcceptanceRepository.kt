package com.coffeecall.app.data.repository

import com.coffeecall.app.core.firebase.FirebaseCollections
import com.coffeecall.app.data.mapper.toAcceptanceDto
import com.coffeecall.app.data.mapper.toDomain
import com.coffeecall.app.data.mapper.toDto
import com.coffeecall.app.data.mapper.toFirestoreMap
import com.coffeecall.app.domain.model.Acceptance
import com.coffeecall.app.domain.model.AcceptanceStatus
import com.coffeecall.app.domain.repository.AcceptanceRepository
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

class FirebaseAcceptanceRepository(
    private val firestoreProvider: () -> FirebaseFirestore = { FirebaseFirestore.getInstance() }
) : AcceptanceRepository {
    override suspend fun getAcceptance(acceptanceId: String): Acceptance? {
        requireFirebaseConfigured()
        val snapshot = firestoreProvider()
            .collection(FirebaseCollections.ACCEPTANCES)
            .document(acceptanceId)
            .get()
            .await()

        return if (snapshot.exists()) snapshot.toAcceptanceDto().toDomain() else null
    }

    override suspend fun createAcceptance(acceptance: Acceptance): String {
        requireFirebaseConfigured()
        val data = acceptance.toDto().toFirestoreMap().toMutableMap()
        data["createdAt"] = FieldValue.serverTimestamp()
        data["updatedAt"] = FieldValue.serverTimestamp()

        val collection = firestoreProvider().collection(FirebaseCollections.ACCEPTANCES)
        return if (acceptance.id.isBlank()) {
            collection.add(data).await().id
        } else {
            collection.document(acceptance.id).set(data).await()
            acceptance.id
        }
    }

    override suspend fun updateAcceptanceStatus(acceptanceId: String, status: AcceptanceStatus) {
        requireFirebaseConfigured()
        firestoreProvider()
            .collection(FirebaseCollections.ACCEPTANCES)
            .document(acceptanceId)
            .update(
                mapOf(
                    "status" to status.firestoreValue,
                    "updatedAt" to FieldValue.serverTimestamp()
                )
            )
            .await()
    }

    override suspend fun findForPostAndAcceptor(postId: String, acceptorId: String): List<Acceptance> {
        requireFirebaseConfigured()
        return firestoreProvider()
            .collection(FirebaseCollections.ACCEPTANCES)
            .whereEqualTo("postId", postId)
            .whereEqualTo("acceptorId", acceptorId)
            .get()
            .await()
            .documents
            .mapNotNull { snapshot ->
                if (snapshot.exists()) snapshot.toAcceptanceDto().toDomain() else null
            }
    }
}

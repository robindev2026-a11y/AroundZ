package com.coffeecall.app.data.repository.mock

import com.coffeecall.app.domain.model.Acceptance
import com.coffeecall.app.domain.model.AcceptanceStatus
import com.coffeecall.app.domain.repository.AcceptanceRepository
import java.util.UUID

class MockAcceptanceRepository : AcceptanceRepository {
    private val acceptances = mutableMapOf<String, Acceptance>()

    override suspend fun getAcceptance(acceptanceId: String): Acceptance? =
        acceptances[acceptanceId]

    override suspend fun createAcceptance(acceptance: Acceptance): String {
        val id = acceptance.id.ifBlank { UUID.randomUUID().toString() }
        acceptances[id] = acceptance.copy(id = id)
        return id
    }

    override suspend fun updateAcceptanceStatus(acceptanceId: String, status: AcceptanceStatus) {
        acceptances[acceptanceId]?.let { acceptance ->
            acceptances[acceptanceId] = acceptance.copy(status = status)
        }
    }

    override suspend fun findForPostAndAcceptor(postId: String, acceptorId: String): List<Acceptance> =
        acceptances.values.filter { it.postId == postId && it.acceptorId == acceptorId }
}

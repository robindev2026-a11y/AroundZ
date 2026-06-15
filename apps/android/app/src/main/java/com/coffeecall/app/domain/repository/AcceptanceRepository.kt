package com.coffeecall.app.domain.repository

import com.coffeecall.app.domain.model.Acceptance
import com.coffeecall.app.domain.model.AcceptanceStatus

interface AcceptanceRepository {
    suspend fun getAcceptance(acceptanceId: String): Acceptance?
    suspend fun createAcceptance(acceptance: Acceptance): String
    suspend fun updateAcceptanceStatus(acceptanceId: String, status: AcceptanceStatus)
    suspend fun findForPostAndAcceptor(postId: String, acceptorId: String): List<Acceptance>
}

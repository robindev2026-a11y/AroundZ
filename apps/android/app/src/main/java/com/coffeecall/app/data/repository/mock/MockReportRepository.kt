package com.coffeecall.app.data.repository.mock

import com.coffeecall.app.domain.repository.ReportRepository

class MockReportRepository : ReportRepository {
    private val reports = mutableListOf<Map<String, String>>()

    override suspend fun reportPost(postId: String, reporterId: String, reason: String) {
        reports.add(mapOf("postId" to postId, "reporterId" to reporterId, "reason" to reason))
    }
}

package com.coffeecall.app.domain.repository

interface ReportRepository {
    suspend fun reportPost(postId: String, reporterId: String, reason: String)
}

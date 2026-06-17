package com.coffeecall.app.core.navigation

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class NavigationManager {
    private val _isTabBarHidden = MutableStateFlow(false)
    val isTabBarHidden: StateFlow<Boolean> = _isTabBarHidden.asStateFlow()

    private val _activeInterestFilter = MutableStateFlow<String?>(null)
    val activeInterestFilter: StateFlow<String?> = _activeInterestFilter.asStateFlow()

    fun setTabBarHidden(hidden: Boolean) {
        _isTabBarHidden.value = hidden
    }

    fun setActiveInterestFilter(filter: String?) {
        _activeInterestFilter.value = filter
    }

    fun clearInterestFilter() {
        _activeInterestFilter.value = null
    }

    companion object {
        @Volatile
        private var INSTANCE: NavigationManager? = null

        fun getInstance(): NavigationManager =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: NavigationManager().also { INSTANCE = it }
            }
    }
}

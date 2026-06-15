package com.coffeecall.app.core.location

data class CoffeeLocation(
    val latitude: Double,
    val longitude: Double
)

sealed interface LocationState {
    data object Loading : LocationState
    data object Denied : LocationState
    data object Unavailable : LocationState
    data class Available(val location: CoffeeLocation) : LocationState
}

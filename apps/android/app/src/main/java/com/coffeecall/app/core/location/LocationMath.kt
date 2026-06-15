package com.coffeecall.app.core.location

import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

fun haversineDistanceKm(
    fromLatitude: Double,
    fromLongitude: Double,
    toLatitude: Double,
    toLongitude: Double
): Double {
    val radiusKm = 6371.0
    val dLat = Math.toRadians(toLatitude - fromLatitude)
    val dLon = Math.toRadians(toLongitude - fromLongitude)
    val lat1 = Math.toRadians(fromLatitude)
    val lat2 = Math.toRadians(toLatitude)

    val a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
    val c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return radiusKm * c
}

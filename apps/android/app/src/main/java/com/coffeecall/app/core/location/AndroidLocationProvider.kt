package com.coffeecall.app.core.location

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import kotlinx.coroutines.tasks.await

class AndroidLocationProvider(
    context: Context
) {
    private val appContext = context.applicationContext
    private val fusedLocationClient = LocationServices.getFusedLocationProviderClient(appContext)

    fun hasLocationPermission(): Boolean =
        ContextCompat.checkSelfPermission(appContext, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(appContext, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED

    @SuppressLint("MissingPermission")
    suspend fun currentLocation(): CoffeeLocation? {
        if (!hasLocationPermission()) return null

        val lastLocation = runCatching {
            fusedLocationClient.lastLocation.await()
        }.getOrNull()

        val freshEnough = lastLocation?.let { System.currentTimeMillis() - it.time <= LOCATION_MAX_AGE_MS } == true
        val bestLocation = if (freshEnough) {
            lastLocation
        } else {
            runCatching {
                fusedLocationClient.getCurrentLocation(
                    Priority.PRIORITY_BALANCED_POWER_ACCURACY,
                    CancellationTokenSource().token
                ).await()
            }.getOrNull() ?: lastLocation
        }

        return bestLocation?.let { CoffeeLocation(it.latitude, it.longitude) }
    }

    private companion object {
        const val LOCATION_MAX_AGE_MS = 15 * 60 * 1000L
    }
}

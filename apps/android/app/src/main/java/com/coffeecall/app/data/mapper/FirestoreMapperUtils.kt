package com.coffeecall.app.data.mapper

import com.google.firebase.Timestamp
import java.util.Date

internal fun Any?.asStringList(): List<String> =
    (this as? List<*>)?.mapNotNull { it as? String }.orEmpty()

internal fun Any?.asMapList(): List<Map<String, Any?>> =
    (this as? List<*>)?.mapNotNull { it as? Map<*, *> }
        ?.map { map -> map.entries.associate { it.key.toString() to it.value } }
        .orEmpty()

internal fun Any?.asInt(default: Int = 0): Int =
    when (this) {
        is Int -> this
        is Long -> toInt()
        is Double -> toInt()
        is Number -> toInt()
        else -> default
    }

internal fun Any?.asDouble(default: Double = 0.0): Double =
    when (this) {
        is Double -> this
        is Float -> toDouble()
        is Long -> toDouble()
        is Int -> toDouble()
        is Number -> toDouble()
        else -> default
    }

internal fun Timestamp?.toDateOrNull(): Date? = this?.toDate()

internal fun Date?.toTimestampOrNull(): Timestamp? = this?.let { Timestamp(it) }

internal fun Map<String, Any?>.withoutNullValues(): Map<String, Any> =
    filterValues { it != null }.mapValues { it.value as Any }

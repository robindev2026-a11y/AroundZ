package com.coffeecall.app.core.location

object GeoHash {
    private val base32 = "0123456789bcdefghjkmnpqrstuvwxyz".toCharArray()

    fun encode(latitude: Double, longitude: Double, precision: Int = 9): String {
        var latMin = -90.0
        var latMax = 90.0
        var lonMin = -180.0
        var lonMax = 180.0
        var isEven = true
        var bit = 0
        var ch = 0
        val hash = StringBuilder()

        while (hash.length < precision) {
            if (isEven) {
                val mid = (lonMin + lonMax) / 2
                if (longitude > mid) {
                    ch = ch or (1 shl (4 - bit))
                    lonMin = mid
                } else {
                    lonMax = mid
                }
            } else {
                val mid = (latMin + latMax) / 2
                if (latitude > mid) {
                    ch = ch or (1 shl (4 - bit))
                    latMin = mid
                } else {
                    latMax = mid
                }
            }

            isEven = !isEven
            if (bit < 4) {
                bit += 1
            } else {
                hash.append(base32[ch])
                bit = 0
                ch = 0
            }
        }

        return hash.toString()
    }
}

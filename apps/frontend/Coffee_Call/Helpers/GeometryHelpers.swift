// GeometryHelpers.swift
import Foundation
import CoreLocation

/// Calculates the great‑circle distance between two geographic coordinates using the haversine formula.
/// - Returns: Distance in kilometres.
public func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let earthRadius = 6371.0 // km
    let dLat = (lat2 - lat1) * .pi / 180.0
    let dLon = (lon2 - lon1) * .pi / 180.0
    let a = sin(dLat/2) * sin(dLat/2) +
            cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0) *
            sin(dLon/2) * sin(dLon/2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return earthRadius * c
}

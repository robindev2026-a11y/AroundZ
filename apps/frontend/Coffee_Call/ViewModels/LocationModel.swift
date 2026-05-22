// LocationModel.swift
import Foundation


/// Decodes a `CLLocation` into human‑readable components.
struct LocationModel: Codable {
    let city: String?
    let state: String?
    let country: String?
    let latitude: Double
    let longitude: Double
    
    /// Human‑readable single line, e.g. "Paris, France".
    var displayString: String {
        var parts: [String] = []
        if let city = city { parts.append(city) }
        if let state = state { parts.append(state) }
        if let country = country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
}

import Foundation
import SwiftUI

struct RadarPerson: Identifiable {
    let id = UUID()
    let initials: String
    let color: Color
    let distance: Double // Normalized 0.0 - 1.0
    let angle: Double // Degrees
    let hasPresence: Bool
    let imageUrl: String? // For high-fidelity photos
}

struct InterestCategory: Identifiable {
    let id: String
    let label: String
    let icon: String
    let count: Int
}

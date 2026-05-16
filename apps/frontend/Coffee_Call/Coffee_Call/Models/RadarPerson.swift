import Foundation
import SwiftUI

struct RadarPerson: Identifiable {
    let id = UUID()
    let initials: String
    let name: String
    let color: Color
    let distance: Double // Normalized 0.0 - 1.0
    let angle: Double // Degrees
    let hasPresence: Bool
    var imageUrl: String?
    var interests: [String] = []
}

struct InterestCategory: Identifiable {
    let id: String
    let label: String
    let icon: String
    let count: Int
    var color: Color? = .brandPrimary
}

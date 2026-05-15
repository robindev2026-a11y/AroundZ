import Foundation
import SwiftUI

struct RadarPerson: Identifiable {
    let id = UUID()
    let initials: String
    let color: Color
    let distance: Double // km
    let angle: Double // degrees
    let hasPresence: Bool
    
    // Derived spatial position for the radar
    // We'll normalize distance to a range that fits the UI
}

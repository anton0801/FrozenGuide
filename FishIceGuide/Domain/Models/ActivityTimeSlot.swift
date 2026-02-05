import Foundation

struct ActivityTimeSlot: Identifiable {
    let id = UUID()
    let timeLabel: String
    let fishActivities: [String: Fish.ActivityLevel] // Fish ID: Activity Level
}

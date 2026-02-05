import Foundation
import Combine

class ActivityViewModel: ObservableObject {
    @Published var activitySlots: [ActivityTimeSlot] = []
    
    func generateActivityTable(from fishes: [Fish]) {
        activitySlots = [
            ActivityTimeSlot(
                timeLabel: "Morning\n6AM - 10AM",
                fishActivities: Dictionary(uniqueKeysWithValues: fishes.map { ($0.id, $0.activityMorning) })
            ),
            ActivityTimeSlot(
                timeLabel: "Day\n10AM - 4PM",
                fishActivities: Dictionary(uniqueKeysWithValues: fishes.map { ($0.id, $0.activityDay) })
            ),
            ActivityTimeSlot(
                timeLabel: "Evening\n4PM - 8PM",
                fishActivities: Dictionary(uniqueKeysWithValues: fishes.map { ($0.id, $0.activityEvening) })
            )
        ]
    }
}

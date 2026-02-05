import Foundation

struct Tip: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let category: TipCategory
    let iconName: String
    
    enum TipCategory: String, Codable, CaseIterable {
        case safety = "Safety on Ice"
        case bestPractices = "Best Practices"
        case beginnerTips = "Beginner Tips"
    }
}

import Foundation

struct Bait: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: BaitType
    let category: BaitCategory
    let iconName: String
    let imageURL: String?
    
    let targetFish: [String]
    let winterEffectiveness: Int
    let summerEffectiveness: Int
    let description: String
    let detailedTips: String
    
    let colorOptions: [String]
    let sizeOptions: [String]
    let priceRange: PriceRange
    
    let depthRange: String
    let retrieveSpeed: String
    let waterClarity: [String]
    let bestTimeOfDay: [String]
    
    let actionType: String
    let hookingTechnique: String
    let commonErrors: [String]
    let videoURL: String?
    
    enum BaitType: String, Codable, CaseIterable {
        case artificial = "Artificial"
        case natural = "Natural"
    }
    
    enum BaitCategory: String, Codable, CaseIterable {
        case jig = "Jigs"
        case spoon = "Spoons"
        case softPlastic = "Soft Plastics"
        case liveBait = "Live Bait"
        case insects = "Insects"
    }
    
    struct PriceRange: Codable, Hashable {
        let min: Double
        let max: Double
    }
}
